class CollectionsController < ApplicationController
    include TheSortableTreeController::ExpandNode

    def index
        @collections = Collection.roots.order(:name)
    end
    def show
        @collection = Collection.find(params[:id])
    end

    def sortable_model
        ImageSet
    end
end
