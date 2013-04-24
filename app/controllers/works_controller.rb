class WorksController < ApplicationController
    before_filter :load_edition

    def index
        @works = @edition.works.order('number, variant')
    end

    def show
        @work = Work.find(params[:id])
    end

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end
end
