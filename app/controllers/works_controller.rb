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
        @work = @edition.works.create(params[:work])
        # TODO: Create page
    end

    def edit
        render :layout => !request.xhr?
    end

    def update
            @work.update_attributes(params[:work])
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
        if params[:work_edition]
            @edition = current_user.editions.find(params[:work_edition])
            parent_edition = session[:edit_work][:parent_edition]
            parent_work = session[:edit_work][:parent_work]
            setup_child_edition
            @work = parent_work.dup
            @work.edition = @edition
            @work.revises_work = parent_work
            text = (render_to_string partial: 'works/transcriptions/show.txt.erb', locals: { work: parent_work }).gsub(/(<i>|<\/i>)/,'')
            logger.info('THINGS HAPPENING')
            logger.info(text)
            @work.text = text
            @work.save!
            redirect_to edit_edition_work_path(@edition, @work)
        else
            @parent_edition = session[:edit_work][:parent_edition]
            @edition = Edition.new
        end
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
            session[:edit_work] = { parent_edition: @edition, parent_work: @work }
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
