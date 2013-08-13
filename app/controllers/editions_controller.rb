class EditionsController < ApplicationController
    before_filter :authenticate_user!, only: [:new, :create]
    def index
        if user_signed_in?
            @editions = Edition.for_user(current_user)
        else
            @editions = Edition.is_public
        end
    end

    def new
        @edition = Edition.new
    end

    def create
        @edition = Edition.new(params[:edition])
        @edition.owner = current_user
        @edition.save!
        if session[:work_revision]
            revision = create_revision_from_session(@edition)
            redirect_to edit_edition_work_path(@edition, revision)
        else
            redirect_to edition_works_path(@edition)
        end
    end
end
