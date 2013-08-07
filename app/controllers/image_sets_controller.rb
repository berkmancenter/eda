class ImageSetsController < ApplicationController
    before_filter :authenticate_user!, only: :rebuild
    before_filter :load_edition
    before_filter :load_image_set, except: :index
    before_filter :check_edition_owner, only: :rebuild
    before_filter :copy_tree_from_parent, only: :rebuild
    before_filter :set_users_current_edition

    include TheSortableTreeController::Rebuild

    def index
        if user_signed_in?
            @image_sets = ImageSet.in_editions(Edition.for_user(current_user))
        else 
            @image_sets = ImageSet.in_editions(Edition.is_public)
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

        if leaf?
            @works = Work.from_image(@image_set.image)
            @image = @image_set.image
            render "image_sets/works"
        else
            render
        end
    end

    def show
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

