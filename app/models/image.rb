# == Schema Information
#
# Table name: images
#
#  id          :integer          not null, primary key
#  url         :text
#  metadata    :text
#  credits     :text
#  full_width  :integer
#  full_height :integer
#  web_width   :integer
#  web_height  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Image < ActiveRecord::Base
    has_many :image_sets, class_name: 'ImageSet', foreign_key: 'nestable_id'
    attr_accessible :credits, :url, :metadata, :web_width, :web_height, :title
    serialize :metadata
    
    include Rails.application.routes.url_helpers

    def published
        # Not published if Amherst or blank
        image = ::Image.find(id)
        !image.blank? && image.collection && image.collection.name != 'Amherst College'
    end

    def blank?
        url.nil? || url.empty?
    end

    def collection
        collection_set = image_sets.find{|s| s.root.is_a? Collection}
        collection_set.root if collection_set
    end

    def oai_dc_identifier
        collection = ::Image.find(id).collection
        leaf = collection.leaves_containing(self).first
        collection_image_set_url(collection, leaf, page: leaf.position_in_level + 1)
    end

    def oai_dc_title
        title
    end

    def sets
        output = OaiRepository.sets.dup.select do |set|
            set[:spec] == 'image' || set[:spec] == "collection:#{collection.name.parameterize}"
        end
        output.map{|o| o.delete(:model); OAI::Set.new(o)}
    end

    def text_credits
      ActionController::Base.helpers.strip_tags(
        self.credits.gsub('<br />', "\n").gsub(
          /<a href="(?<url>[^"]*)" target="_blank">(?<text>[^<]*)<\/a>/,
          "\\k<text>\n\\k<url>"
        )
      )
    end
end
