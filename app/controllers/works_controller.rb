class WorksController < ApplicationController
    before_filter :authenticate_user!, only: [:edit, :update]
    before_filter :load_work, only: [:edit, :update, :add_to_reading_list]
    before_filter :load_edition, except: [:index, :search]
    before_filter :check_edition_owner, only: [:edit, :update]
    before_filter :setup_child_edition, only: :update

    def index
        if params[:edition_id]
            load_edition
            @works = @edition.all_works
        elsif params[:first_letter]
            @works = Work.starts_with(params[:first_letter])
        else
            @works = Work.all
        end
        render :layout => !request.xhr?
    end

    def show
        @work = @edition.all_works.includes(:line_modifiers, :stanzas => [:lines]).find(params[:id])
        respond_to do |format|
            format.html
            format.txt{ render layout: false }
        end
    end

    def new
        @work = Work.new
    end

    def create
        @work = @edition.works.create(params[:work])
        # TODO: Create page
    end

    def edit
        render :layout => !request.xhr?
    end

    def update
        if @work.edition == @edition.parent
            parent_work = @work
            @work = parent_work.dup
            @work.edition = @edition
            @work.revises_work = parent_work
        end
        @work.update_attributes(params[:work])
        @work.save!
        @edition.replace_work_in_pages!(parent_work, @work) if @work.edition == @edition.parent
        redirect_to edition_work_path(@edition, @work)
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

    def add_to_reading_list
        @reading_list = ReadingList.find(params[:reading_list_id])
        @reading_list.add_work(@work)
        render text: !!@reading_list.save!
    end

    private

    def load_work
        @work = Work.find(params[:id])
    end

    def setup_child_edition
        if @edition.parent && !@edition.inherited_everything_yet?
            @edition.copy_everything_from_parent!
        end
    end
end
