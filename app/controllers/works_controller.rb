class WorksController < ApplicationController
    before_filter :load_edition, :except => :search

    def index
        @works = @edition.works.order('number, variant')
    end

    def show
        @work = Work.includes(:line_modifiers, :stanzas => [:lines]).find(params[:id])
    end

    def search
        if user_signed_in?
            current_user.current_edition = params[:current_edition]
        else
            session[:current_edition] = params[:current_edition]
        end

        if params[:q]
            @search = Work.search do
                with(:edition_id, params[:current_edition]) if params[:current_edition]
                fulltext params[:q] do
                    fields(:lines, :title => 2.0)
                end
            end
        end
    end

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end
end
