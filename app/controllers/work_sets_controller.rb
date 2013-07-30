class WorkSetsController < ApplicationController
    before_filter :authenticate_user!, only: :rebuild
    before_filter :load_edition
    before_filter :check_edition_owner, only: :rebuild
    before_filter :copy_tree_from_parent, only: :rebuild
    include TheSortableTreeController::Rebuild

    def index
        @work_sets = @edition.work_set.self_and_descendants
    end

    def show
        @work_set = WorkSet.find( params[ :id ] )
    end

    private

    def copy_tree_from_parent
        if @edition.parent && !@edition.inherited_everything_yet?
            @edition.copy_everything_from_parent!
        end
    end
end

