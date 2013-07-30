class EditionsController < ApplicationController
    before_filter :authenticate_user!, only: [:new, :create]
    def index
        @editions = Edition.all
    end

    def new
        @edition = Edition.new
    end

    def create
        @edition = Edition.new(params[:edition])
        @edition.owner = current_user
        @edition.save!
        redirect_to edition_works_path(@edition)
    end
end
