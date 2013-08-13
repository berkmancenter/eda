class WorksController < ApplicationController
    before_filter :authenticate_user!, only: [:edit, :update, :choose_edition]
    before_filter :load_work, only: [:edit, :update, :add_to_reading_list, :choose_edition]
    before_filter :load_edition, except: [:index, :search, :choose_edition]
    before_filter :move_to_editable_edition, only: [:edit, :update]

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
        if @edition && session[:work_revision]
            revises_work = Work.find(session[:work_revision][:revises_work_id])
            if @edition.is_child? &&
                @edition.parent == revises_work.edition &&
                work = @edition.works.find_by_revises_work_id(revises_work.id)
                flash[:alert] = t :revision_already_exists
                redirect_to edit_edition_work_path(@edition, work)
            else
                revision = create_revision_from_session(@edition)
                redirect_to edit_edition_work_path(@edition, revision)
            end
        else
            @work = @edition.works.create(params[:work])
        end
    end

    def edit
        render :layout => !request.xhr?
    end

    def update
        if @work.update_attributes(params[:work])
            redirect_to edition_work_path(@edition, @work)
        end
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

    def choose_edition
        @edition = Edition.new
    end

    def add_to_reading_list
        @reading_list = ReadingList.find(params[:reading_list_id])
        @reading_list.add_work(@work)
        render text: !!@reading_list.save!
    end

    private

    def move_to_editable_edition
        unless current_user == @edition.owner
            flash[:alert] = t :cannot_edit_edition
            session[:work_revision] = { revises_work_id: @work.id }
            redirect_to choose_edition_work_path(@work)
        end
    end


    def load_work
        @work = Work.find(params[:id])
    end

    def setup_child_edition
        if @edition.parent && !@edition.inherited_everything_yet?
            @edition.copy_everything_from_parent!
        end
    end
end
