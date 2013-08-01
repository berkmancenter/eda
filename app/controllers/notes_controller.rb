class NotesController < ApplicationController
    before_filter :authenticate_user!
    before_filter :load_image_set

    def create
        @note = @sett.notes.new(params[:note])
        @note.owner = current_user
        if request.xhr?
            render :text => !!@note.save!
        else
            redirect_to :back
        end
    end

    def update
        @note = Note.find(params[:id])
        @note.update_attributes(params[:note])
        if request.xhr?
            render :text => !!@note.save!
        else
            redirect_to :back
        end
    end

    private
    
    def load_image_set
        @sett = ImageSet.find(params[:image_set_id])
    end
end
