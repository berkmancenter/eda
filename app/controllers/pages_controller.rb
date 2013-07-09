class PagesController < ApplicationController
    before_filter :load_edition

    def index
        @pages = @edition.pages
    end

    def show
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
        render
    end

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end
end
