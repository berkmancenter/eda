class ImageSetsController < ApplicationController
    before_filter :authenticate_user!, only: :rebuild
    before_filter :load_edition
    before_filter :load_image_set, except: :index
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
            render "image_sets/works"
        else
            render
        end
    end
    
    private

    def load_image_set
        @image_set = ImageSet.find(params[:id])
    end
end

