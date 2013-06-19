class ImageGroupsController < ApplicationController
    before_filter :load_edition
    include TheSortableTreeController::Rebuild

    def index
        @image_groups = @edition.root_image_group.self_and_descendants
    end

    def show
        @image_group = ImageGroup.find( params[ :id ] )
    end

    def load_edition
        @edition = Edition.find( params[ :edition_id ] )
    end
end

