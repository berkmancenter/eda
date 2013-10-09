class CollectionsController < ApplicationController
    include TheSortableTreeController::ExpandNode

    def index
        @collections = Collection.scoped
    end
    def show
        @collection = Collection.find(param[:id])
    end

    def sortable_model
        ImageSet
    end
end
