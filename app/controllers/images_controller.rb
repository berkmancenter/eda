class ImagesController < ApplicationController
    before_filter :load_edition

    def index
        @images = @edition.images
    end

    def show
        if user_signed_in?
            current_user.current_edition = @edition
            current_user.save!
        end
        session[:current_edition] = @edition.id
        @page = Page.find(params[:id])
        @work = @page.work
        unless user_signed_in? && @note = current_user.note_for(@page.image_set)
            @note = @page.image_set.notes.new if @page.image_set
        end

        if params[ :q ]
          @search = Work.search do
            #with( :edition_id, @edition.id )
            fulltext params[ :q ] do
              fields( :lines, :title => 2.0 )
            end
          end
        end

        render
    end
end
