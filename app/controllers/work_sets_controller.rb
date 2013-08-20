class WorkSetsController < ApplicationController
    before_filter :authenticate_user!, only: :rebuild
    before_filter :load_edition
    before_filter :check_edition_owner, only: :rebuild
    before_filter :setup_child_edition, only: :rebuild
    include TheSortableTreeController::Rebuild

    def index
        @work_sets = @edition.work_set.self_and_descendants
    end

    def show
        @work_set = WorkSet.find( params[ :id ] )
    end
end

