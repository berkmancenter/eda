class WorkSetsController < ApplicationController
    before_action :authenticate_user!, only: :rebuild
    before_action :load_edition
    before_action :check_edition_owner, only: :rebuild
    include ::TheSortableTreeController::Rebuild

    def index
        @work_sets = @edition.work_set.self_and_descendants
    end

    def show
        @work_set = WorkSet.find( params[ :id ] )
    end
end

