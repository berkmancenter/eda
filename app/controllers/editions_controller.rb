class EditionsController < ApplicationController
    before_filter :authenticate_user!, only: [:new, :create, :edit, :update]
    before_filter :load_edition, only: [:edit, :update, :show, :destroy]
    before_filter :check_edition_owner, only: [:show, :edit, :update, :destroy]

    def index
        if user_signed_in?
            @editions = Edition.for_user(current_user)
        else
            @editions = Edition.is_public
        end
    end

    def show
        redirect_to edition_works_path(@edition)
    end

    def new
        @edition = Edition.new
    end

    def edit
    end

    def update
        @edition.update_attributes(params[:edition])
        if @edition.save
            flash[:notice] = t :edition_successfully_updated
            redirect_to edition_works_path(@edition)
        else
            flash[:alert] = t :form_error, count: @edition.errors.count
            render :edit
        end
    end

    def create
        @edition = Edition.new(params[:edition])
        @edition.owner = current_user
        if @edition.save
            if session[:from_other_edition]
                @image_set = ImageSet.find(session[:from_other_edition][:from_image_set_id]).matching_node_in(@edition.image_set)
                puts @image_set.inspect
                exit
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
            else
                flash[:notice] = t :edition_successfully_created
                redirect_to edition_works_path(@edition)
            end
        else
            flash[:alert] = t :form_error, count: @edition.errors.count
            render :new
        end
    end

    def destroy
        if @edition.destroy
            flash[:notice] = t :edition_successfully_deleted
        end
        redirect_to editions_path
    end
end
