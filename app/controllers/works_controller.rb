class WorksController < ApplicationController

    def index
        if params[:edition_id]
            load_edition
            @works = @edition.works.order(:number, :variant)
        elsif params[:first_letter]
            @works = Work.starts_with(params[:first_letter])
        else
            @works = Work.all
        end
        render :layout => !request.xhr?
    end

    def show
      load_edition
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

    private

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end
end
