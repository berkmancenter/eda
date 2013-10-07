class ImageSetsController < ApplicationController
    before_filter :authenticate_user!, only: :rebuild
    before_filter :load_edition, except: [:index]
    before_filter :load_image_set, only: [:show, :update, :edit, :destroy]
    before_filter :check_edition_owner, only: :rebuild

    include TheSortableTreeController::Rebuild
    include TheSortableTreeController::ExpandNode

    def index
        load_edition
        @image_sets = @edition.image_set.children.includes(:nestable)
    end

    def collections
        @image_sets = Collection.scoped
    end

    def show
        unless user_signed_in? && @note = current_user.note_for(@image_set)
            @note = @image_set.notes.new
        end

        if @image_set.leaf?
            pull_works_for_edition_image_set(@edition, @image_set)
            @next_image = @image_set.root.leaf_after(@image_set)
            @previous_image = @image_set.root.leaf_before(@image_set)
            render "image_sets/works"
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

