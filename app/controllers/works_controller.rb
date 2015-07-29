class WorksController < ApplicationController
    include WorkHelper

    before_filter :authenticate_user!, only: [:edit, :update, :choose_edition]
    before_filter :load_edition, except: [:index, :browse, :search, :choose_edition, :metadata]
    before_filter :load_image_set, only: [:new, :edit, :destroy, :update]
    before_filter :load_work, only: [:edit, :update, :destroy, :add_to_reading_list, :metadata]
    before_filter :move_to_editable_edition, only: [:new, :create, :edit, :update]

    def browse
        @works = Work.starts_with(params[:first_letter]).reorder('title, number, variant')
        if request.xhr?
            render 'works/list', layout: false
        else
            render 'works/index'
        end
    end

    def index
        if params[:edition_id]
            load_edition
            @works = @edition.all_works
        else
            @works = Work.where(edition_id: Edition.for_user(current_user))
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
            format.tei{
                response.headers['Content-Disposition'] = "attachment; filename=\"#{@work.full_id}.tei.xml\""
                render layout: false
            }
        end
    end

    def new
        @work = Work.new
        setup_image_set_view_variables
        render 'image_sets/works', layout: !request.xhr?
    end

    def create
        # Creating as a revision
        if session[:from_other_edition]
            @image_set = @edition.image_set.leaves_containing(ImageSet.find(session[:from_other_edition][:from_image_set_id]).image).first
            # Add the image if it's missing somehow
            if @image_set.nil?
                @edition.image_set << ImageSet.find(session[:from_other_edition][:from_image_set_id]).image
                @image_set = @edition.image_set.leaves_containing(ImageSet.find(session[:from_other_edition][:from_image_set_id]).image).first
            end
            if session[:from_other_edition][:from_work_id]
                revises_work = Work.find(session[:from_other_edition][:from_work_id])
                if @edition.is_child? &&
                    @edition.parent == revises_work.edition &&
                    work = @edition.works.find_by_revises_work_id(revises_work.id)
                    flash[:alert] = t :revision_already_exists
                    redirect_to edit_edition_image_set_work_path(@edition, @image_set, work)
                else
                    revision = create_revision_from_session(@edition)
                    redirect_to edit_edition_image_set_work_path(@edition, @image_set, revision)
                end
            else
                session.delete(:from_other_edition)
                redirect_to new_edition_image_set_work_path(@edition, @image_set)
            end
        # Creating a brand new work
        else
            load_image_set
            if params[:work][:tei]
                #begin
                    parsed_tei = TEIImporter.new.import(params[:work][:tei].read)
                #rescue
                #    flash[:alert] = I18n.t(:malformed_tei)
                #    redirect_to edition_image_set_path(@edition, @image_set)
                #    return
                #end
                @work = parsed_tei
                @work.edition = @edition
            else
                @work = @edition.works.new(params[:work])
            end
            if @work.number_variant_is_unique
                if @work.save
                    @work.image_set << @image_set.image
                    @work.sync_text_and_image_set(@image_set)
                    @work.save!
                    flash[:notice] = t :work_successfully_created
                    redirect_to edition_image_set_path(@edition, @image_set)
                else
                    flash[:alert] = t :form_error, count: @work.errors.count
                    setup_image_set_view_variables
                    render 'image_sets/works'
                end
            else
                flash[:alert] = I18n.t('work_not_unique', { number: @work.number, variant: @work.variant })
                redirect_to new_edition_image_set_work_path(@edition, @image_set)
            end
        end
    end

    def edit
        @image_sets = @work.image_set.leaves
    end

    def update
        if params[:work][:tei]
            begin
                parsed_tei = TEIImporter.new.import(params[:work][:tei].read, @work)
            rescue
                flash[:alert] = I18n.t(:malformed_tei)
                redirect_to edit_edition_image_set_work_path(@edition, @image_set, @work)
                return
            end
            @work = parsed_tei
        else
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
        end

        if @work.number_variant_is_unique
            if @work.save
                flash[:notice] = t :work_successfully_updated
                if params[:commit] == t(:continue_to_next_image)
                    @image_set = ImageSet.find(params[:next_image])
                    redirect_to edit_edition_image_set_work_path(@edition, @image_set, @work)
                else
                    redirect_to edition_image_set_path(@edition, @image_set)
                end
            else
                flash[:alert] = t :form_error, count: @work.errors.count
                setup_image_set_view_variables
                render 'image_sets/works', layout: !request.xhr?
            end
        else
            flash[:alert] = I18n.t('work_not_unique', { number: @work.number, variant: @work.variant })
            redirect_to edit_edition_image_set_work_path(@edition, @image_set, @work)
        end
    end

    def destroy
        @work.destroy
        flash[:notice] = t :work_successfully_deleted
        redirect_to edition_image_set_path(@edition, @image_set)
    end

    def search
        if request.xhr?
            render partial: 'works/search_results_list', layout: false
        else
            render
        end
    end

    def metadata
        render layout: !request.xhr?
    end

    def choose_edition
        @edition = Edition.new
        if session[:from_other_edition] && session[:from_other_edition][:from_work_id]
            load_work
            @edition.parent = Work.find(session[:from_other_edition][:from_work_id]).edition
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
            flash[:notice] = t :cannot_edit_edition
            session[:from_other_edition] = { from_image_set_id: @image_set.id }
            if @work
                session[:from_other_edition][:from_work_id] = @work.id
                redirect_to choose_edition_work_path(@work)
            else
                redirect_to choose_edition_new_works_path
            end
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
