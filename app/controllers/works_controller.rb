class WorksController < ApplicationController
    before_filter :load_edition, :except => :search

    def index
        @works = @edition.works.order('number, variant')
    end

    def show
        @work = Work.includes(:line_modifiers, :stanzas => [:lines]).find(params[:id])
    end

    def search
        if params[:q]
            @works = Work.search{ fulltext params[:q] }.results
        end
    end

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end
end
