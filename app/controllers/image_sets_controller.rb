class ImageSetsController < ApplicationController
    before_filter :authenticate_user!, only: :rebuild
    before_filter :load_edition
    before_filter :load_image_set, only: [:show, :update, :edit, :destroy]
    before_filter :check_edition_owner, only: :rebuild
    before_filter :set_users_current_edition

    include TheSortableTreeController::Rebuild
    include TheSortableTreeController::ExpandNode

    def index
        @image_sets = @edition.image_set.self_and_descendants.includes(:nestable)
    end

    def show
        unless user_signed_in? && @note = current_user.note_for(@image_set)
            @note = @image_set.notes.new
        end

        if @image_set.leaf?
            pull_works_for_edition_image_set(@edition, @image_set)
            @next_image = @image_set.root.leaf_after(@image_set)
            @previous_image = @image_set.root.leaf_before(@image_set)

            if @this_editions_works.nil? || @this_editions_works.empty?
                redirect_to edition_image_set_url(@edition, @next_image)
            else
            render "image_sets/works"
            end
        else
            render
        end
    end

    def new
        @image_set = ImageSet.new
    end

    def create
        @image_set = ImageSet.new(params[:image_set])
        @image_set.move_to_child_of @edition.image_set
        if @image_set.save
            flash[:notice] = t :successful_creation
            redirect_to edition_image_sets_path(@edition)
        else
            flash[:alert] = t :form_error, count: @image_set.errors.count
            render :new
        end
    end

    def edit
    end

    def update
        @image_set.update_attributes(params[:image_set])
        if @image_set.save
            flash[:notice] = t :successful_update
            redirect_to edition_image_sets_path(@edition)
        else
            flash[:alert] = t :form_error, count: @image_set.errors.count
            redirect_to edit_edition_image_set_path(@edition, @image_set)
        end
    end

    def destroy
    end
    
    private

    def load_image_set
        @image_set = ImageSet.find(params[:id])
    end
end

