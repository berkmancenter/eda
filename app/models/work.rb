# == Schema Information
#
# Table name: works
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  date             :datetime
#  number           :integer
#  variant          :string(255)
#  secondary_source :boolean
#  metadata         :text
#  edition_id       :integer
#  image_set_id     :integer
#  revises_work_id  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Work < ApplicationRecord
    belongs_to :edition, optional: true
    belongs_to :revises_work, class_name: 'Work', optional: true
    belongs_to :image_set, dependent: :destroy, optional: true

    has_many :sets, as: :nestable, class_name: 'WorkSet'
    has_many :stanzas, -> { order('position') }, dependent: :destroy
    has_many :lines, -> { order('number') }, through: :stanzas, dependent: :destroy
    has_many :line_modifiers, dependent: :destroy
    has_many :divisions, dependent: :destroy
    has_many :emendations, dependent: :destroy
    has_many :alternates, dependent: :destroy
    has_many :revisions, dependent: :destroy
    has_many :appearances, class_name: 'WorkAppearance', dependent: :destroy

    attr_accessible :date, :metadata, :number, :title, :variant, :text, :secondary_source

    validates :date, :number, :title, :variant, length: { maximum: 200 }
    validates :number, numericality: { only_integer: true }

    after_initialize :setup_defaults
    before_create :setup_work
    default_scope { order(:number, :variant) }
    scope :starts_with, lambda { |first_letter| where('title ILIKE ?', "#{first_letter}%") }

    serialize :metadata

    include WorkHelper
    include ImagesHelper
    include Rails.application.routes.url_helpers

    searchable do
        integer :edition_id
        text(:number) { |work| "#{work.number} #{work.full_id} #{work.edition.work_number_prefix}#{work.number}" }
        text :title
        text :lines, stored: true do
            lines.map{|l| l.text }
        end
        text :metadata do
            metadata_permitted = if metadata.is_a? Hash
                                   metadata
                                 else
                                   metadata.permit!.to_h
                                 end

            metadata_permitted.reduce('') do |all, m|
                value = m.last.is_a?(Array) ? m.last.join(' ') : m.last.to_s
                value = ActionController::Base.helpers.strip_tags(value)
                "#{all} #{value}"
            end
        end
    end

    def title
        read_attribute(:title) || (lines.first.text unless lines.empty?)
    end

    def line(number)
        Line.find_by_number(number)
    end

    def full_id
        "#{edition.work_number_prefix if edition}#{number}#{variant}"
    end

    def full_title
        "#{full_id} - #{title}"
    end

    def next
        edition.works.where('number > ? OR (number = ? AND variant > ?)', number, number, varaint).order(:number, :variant).first
    end

    def previous
        edition.works.where('number < ? OR (number = ? AND variant < ?)', number, number, varaint).order(:number, :variant).last
    end

    def variants
        edition.works.where('number = ? AND variant != ?', number, variant)
    end

    def apps_at_address(line, char_index)
        (divisions + emendations + revisions + alternates).select do |apparatus|
            apparatus.line_num == line && apparatus.start_address == char_index
        end
    end

    def sync_text_and_image_set(edition_image_set)
        image_sets_before_current = edition_image_set.root.leaves_before(
            edition_image_set
        )

        image_sets_after_current = edition_image_set.root.leaves_after(
            edition_image_set
        )

        image_set.destroy
        image_set = ImageSet.create

        image_sets_before_current.each do |i_image_set|
            image_set << i_image_set.image
        end

        image_set << edition_image_set.image

        image_sets_after_current.each do |i_image_set|
            image_set << i_image_set.image
        end
        self.image_set = image_set
    end

    def clear_holder_info
        metadata['holder_code'] = nil
        metadata['holder_subcode'] = nil
        metadata['holder_id'] = nil
    end

    def holder_code=(code)
        if metadata['holder_code']
            self.metadata['holder_code'] << code
        else
            self.metadata['holder_code'] = [code]
        end
    end

    def holder_subcode=(subcode)
        if metadata['holder_subcode']
            self.metadata['holder_subcode'] << subcode
        else
            self.metadata['holder_subcode'] = [subcode]
        end
    end

    def holder_id=(id)
        if metadata['holder_id']
            self.metadata['holder_id'] << id
        else
            self.metadata['holder_id'] = [id]
        end
    end

    def fascicle=(fascicle)
        self.metadata['fascicle'] = fascicle
    end

    def note=(note)
        if metadata['notes']
            self.metadata['notes'] << note
        else
            self.metadata['notes'] = [note]
        end
    end


    def fascicle_position=(position)
        self.metadata['fascicle_position'] = position
    end

    def has_image?
        image_set.all_images.any?{|i| i.url && !i.url.empty?}
    end

    def self.in_image(image)
        # This assumes work image sets contain only one level
        # INNER JOIN setts AS s2 ON s1.id = s2.parent_id
        ids = Rails.cache.fetch("wrks_in_img-#{image.work_assoc_cache_key}") do
          self.unscoped do
            self.joins("INNER JOIN setts AS s1 ON s1.id = works.image_set_id AND s1.type = 'ImageSet'
                  INNER JOIN setts AS s2 ON (s2.ancestry = CAST(s1.id AS text) OR s2.ancestry = (s1.ancestry || '/' || s1.id))
                  INNER JOIN images ON s2.nestable_id = images.id AND s2.nestable_type = 'Image'").
                  where(images: { id: ( image.id unless image.nil? ) }).pluck(:id)
          end
        end
        where(id: ids)
    end

    def self.in_editions(editions)
        includes(:edition).where(editions: { id: editions})
    end

    def text
        # Shut up, I know.
        controller = ApplicationController.new
        controller.with_format(:txt) do
            controller.render_to_string(
                partial: 'works/transcriptions/show',
                locals: { work: self }
            )
        end
    end

    def text=(text)
        line_modifiers.delete_all
        stanza = Stanza.new(position: 0)
        new_stanzas = []
        page_break_pattern = /^((\*\s*){3,}|(-\s*){3,}|(_\s*){3,})$/
        stanza_break_pattern = /^\s*$/
        line_number = 0
        text.lines.each_with_index do |line, i|
            if line.match(page_break_pattern)
                address = text.lines.to_a[i - 1].length - 1
                self.divisions << Division.new(
                    start_line_number: line_number,
                    end_line_number: line_number,
                    start_address: address,
                    end_address: address,
                    subtype: 'page_or_column',
                )
            elsif line.match(stanza_break_pattern)
                new_stanzas << stanza
                stanza = Stanza.new(position: new_stanzas.count)
            else
                line_number += 1
                stanza.lines.new(number: line_number, text: line.strip)
            end
        end
        new_stanzas << stanza
        self.stanzas = new_stanzas
    end

    def number_variant_is_unique
        count = edition.works.where(number: number, variant: variant).count
        (!new_record? && count == 1) || (new_record? && count == 0)
    end

    def self.find_by_full_id(id)
        match = id.match(/^(?<prefix>[A-Z]+([0-9]*-)?)(?<number>\d+)(?<variant>[A-Z](\.[0-9])?)?/)
        edition = Edition.find_by_work_number_prefix(match[:prefix])
        return unless edition
        works = edition.works
        works = works.where(number: match[:number])
        works = works.where(variant: match[:variant]) if match[:variant]
        works.first
    end

    protected

    def metadata_size
        if metadata.to_yaml.size > 10000
            errors.add(:metadata, I18n.t('errors.messages.too_big'))
        end
    end

    private

    def setup_defaults
        if self.has_attribute?(:metadata)
        self.metadata ||= {}
        end
    end

    def setup_work
        self.image_set = ImageSet.create if self.image_set.nil?
    end
end
