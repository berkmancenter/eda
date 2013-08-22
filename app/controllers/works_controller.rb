class WorksController < ApplicationController
    before_filter :authenticate_user!, only: [:edit, :update, :choose_edition]
    before_filter :load_edition, except: [:index, :search, :choose_edition]
    before_filter :load_image_set, only: [:new, :edit, :destroy, :update]
    before_filter :load_work, only: [:edit, :update, :destroy, :add_to_reading_list, :choose_edition]
    before_filter :move_to_editable_edition, only: [:new, :create, :edit, :update]

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
        @work = Work.includes(:line_modifiers, :stanzas => [:lines]).find(params[:id])
        respond_to do |format|
            format.html do
                if params[:image_set_id]
                    redirect_to edition_image_set_path(@edition, ImageSet.find(params[:image_set_id]))
                else
                    redirect_to image_set_path_from_work(@work)
                end
            end
            format.txt{ render layout: false }
            format.tei{ render layout: false }
        end
    end

    def new
        @work = Work.new
        setup_image_set_view_variables
        render 'image_sets/works', layout: !request.xhr?
    end

    def create
        # Creating as a revision
        if @edition && session[:work_revision]
            revises_work = Work.find(session[:work_revision][:revises_work_id])
            @image_set = @edition.image_set.leaves_containing(ImageSet.find(session[:work_revision][:from_image_set_id]).image).first
            if @edition.is_child? &&
                @edition.parent == revises_work.edition &&
                work = @edition.works.find_by_revises_work_id(revises_work.id)
                flash[:alert] = t :revision_already_exists
                redirect_to edit_edition_image_set_work_path(@edition, @image_set, work)
            else
                revision = create_revision_from_session(@edition)
                redirect_to edit_edition_image_set_work_path(@edition, @image_set, revision)
            end
        # Creating a brand new work
        else
            @work = @edition.works.new(params[:work])
            load_image_set
            if @work.save!
                @work.image_set << @image_set.image
                @work.sync_text_and_image_set(@image_set)
                @work.save!
                flash[:notice] = t :work_successfully_created
            end
            redirect_to edition_image_set_path(@edition, @image_set)
        end
    end

    def edit
        setup_image_set_view_variables
        render 'image_sets/works', layout: !request.xhr?
    end

    def update
        num_work_images = @work.divisions.page_breaks.count + 1
        if params[:commit] == t(:continue_to_next_image)
            on_work_page = @work.image_set.leaves_containing(@image_set.image).first.position_in_level
            params[:work][:text] << t(:page_break) unless (on_work_page + 1) < num_work_images
        end
        @work.update_attributes(params[:work])

        new_num_work_images = @work.divisions.page_breaks.count + 1

        unless new_num_work_images == num_work_images
            @work.sync_text_and_image_set(@image_set)
        end
            
        if @work.save!
            flash[:notice] = t :work_successfully_updated
        end
        if params[:commit] == t(:continue_to_next_image)
            @image_set = ImageSet.find(params[:next_image])
            redirect_to edit_edition_image_set_work_path(@edition, @image_set, @work)
        else
            redirect_to edition_image_set_path(@edition, @image_set)
        end
    end

    def destroy
        @work.destroy
        flash[:notice] = t :work_successfully_deleted
        redirect_to edition_image_set_path(@edition, @image_set)
    end

    def search
        if user_signed_in?
            current_user.current_edition = Edition.find(params[:current_edition])
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
            session[:search_results] = {
                total: @search.total,
                q: @search.query.to_params[:q],
                results: @search.results
            }
       end
        redirect_to request.referrer if request.referrer
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
            session[:work_revision] = { revises_work_id: @work.id, from_image_set_id: @image_set.id }
            logger.info("look: #{session[:work_revision].inspect}")
            redirect_to choose_edition_work_path(@work)
        end
    end

    def setup_image_set_view_variables
        unless user_signed_in? && @note = current_user.note_for(@image_set)
            @note = @image_set.notes.new
        end
        pull_works_for_edition_image_set(@edition, @image_set)
        @next_image = @image_set.root.leaf_after(@image_set)
        @previous_image = @image_set.root.leaf_before(@image_set)
    end

    def load_work
        @work = Work.find(params[:id])
    end
end
