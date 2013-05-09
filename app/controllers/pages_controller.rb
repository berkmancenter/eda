class PagesController < ApplicationController
    before_filter :load_edition

    def index
        @pages = @edition.pages
    end

    def show
        @page = Page.find(params[:id])
        @work = @page.work
        @image = @page.image_group_image.image
    end

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end
end
