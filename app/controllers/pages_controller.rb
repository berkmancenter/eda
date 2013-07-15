class PagesController < ApplicationController
    before_filter :load_edition

    def index
        @pages = @edition.pages
    end

    def show
        if user_signed_in?
            current_user.current_edition = @edition
            current_user.save!
        end
        session[:current_edition] = @edition.id
        @page = Page.find(params[:id])
        @work = @page.work
        if @page.image_group_image
        @image = @page.image_group_image.image
            if user_signed_in? 
                unless @note = current_user.note_for(@image)
                    @note = @image.notes.new
                end
            end
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

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end
end
