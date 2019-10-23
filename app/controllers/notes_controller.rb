class NotesController < ApplicationController
    before_action :authenticate_user!
    before_action :load_image_set

    def create
      @note = @sett.notes.new(params[:note])
      @note.owner = current_user
      if request.xhr?
        if @note.save!
          # return the updated html list
          render( partial: 'image_sets/notes_list', locals: { sett: @sett, notes: current_user.notes_for( @sett ) } )
        else
          render :text => 'false'
        end
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

    def destroy
      @note = Note.find(params[:id])
      @note.destroy

      if request.xhr?
        # return the updated html list
        render( partial: 'image_sets/notes_list', locals: { sett: @sett, notes: current_user.notes_for( @sett ) } )
      else
        redirect_to :back
      end
    end

    private
    
    def load_image_set
        @sett = ImageSet.find(params[:image_set_id])
    end
end
