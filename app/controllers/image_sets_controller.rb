class ImageSetsController < ApplicationController
    before_filter :authenticate_user!, only: :rebuild
    before_filter :load_edition
    before_filter :load_image_set, except: :index
    before_filter :check_edition_owner, only: :rebuild
    before_filter :copy_tree_from_parent, only: :rebuild
    before_filter :set_users_current_edition

    include TheSortableTreeController::Rebuild
    include TheSortableTreeController::ExpandNode

    def index
        if user_signed_in?
            @image_sets = ImageSet.in_editions(Edition.for_user(current_user)).map(&:self_and_descendants).flatten
        else 
            @image_sets = ImageSet.in_editions(Edition.is_public).map(&:self_and_descendants).flatten
        end
    end

    def show
        unless user_signed_in? && @note = current_user.note_for(@image_set)
            @note = @image_set.notes.new
        end

        if params[ :q ]
            @search = Work.search do
                #with( :edition_id, @edition.id )
                fulltext params[ :q ] do
                    fields( :lines, :title => 2.0 )
                end
            end
        end

        if @image_set.leaf?
            all_works = Work.includes(:edition).where(
                edition: { id: Edition.for_user(current_user)}
            ).in_image(@image_set.image).group_by{
                |w| w.edition == @edition
            }
            @this_editions_works = all_works[true]
            # TODO: Do this better
            if @this_editions_works.nil? && @edition.is_child?
                @this_editions_works = Work.joins(:edition).where(
                    edition: { id: @edition.parent.id}
                ).in_image(@image_set.image)
            end
            @other_editions_works = all_works[false]
            @variants = @this_editions_works.map{|w| w.variants}.flatten.compact.uniq if @this_editions_works
            @image = @image_set.image
            render "image_sets/works"
        else
            render
        end
    end

    private
    
    def load_image_set
        @image_set = ImageSet.find(params[:id])
    end

    def copy_tree_from_parent
        if @edition.parent && !@edition.inherited_everything_yet?
            @edition.copy_everything_from_parent!
        end
    end
end

