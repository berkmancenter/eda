class ReadingListsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :load_reading_list, :except => [:index, :create]

    def index
        @reading_lists = current_user.reading_lists
    end

    def show
    end
    
    def edit
    end

    def update
        @reading_list.works = Work.find(params[:reading_list][:works].reject(&:blank?))
        @reading_list.save!
        redirect_to reading_list_path(@reading_list)
    end

    def create
        @reading_list = current_user.reading_lists.create(params[:reading_list])
        redirect_to reading_lists_path
    end

    private

    def load_reading_list
        @reading_list = current_user.reading_lists.find(params[:id])
    end
end
