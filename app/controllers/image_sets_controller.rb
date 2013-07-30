class ImageSetsController < ApplicationController
    before_filter :load_edition
    before_filter :copy_tree_from_parent, only: :rebuild
    include TheSortableTreeController::Rebuild

    def index
        if image_set = @edition.image_set
            @image_sets = image_set.self_and_descendants
        elsif @edition.parent
            @image_sets = @edition.parent.image_set.self_and_descendants
        end
    end

    def show
        @image_set = ImageSet.find( params[ :id ] )
    end

    private
    
    def load_edition
        @edition = Edition.find( params[ :edition_id ] )
    end

    def copy_tree_from_parent
        if @edition.parent && !@edition.inherited_everything_yet?
            @edition.copy_everything_from_parent!
        end
    end
end

