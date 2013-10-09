class ReadingListsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :load_reading_list, :except => [:index, :create]
    before_filter :check_reading_list_owner, except: [:index, :create]

    include TheSortableTreeController::Rebuild

    def index
        @reading_lists = current_user.reading_lists
    end

    def show
        @reading_list = @reading_list.self_and_descendants
        if request.xhr?
            render 'reading_lists/ajax_show'
        else
            render 'reading_lists/show'
        end
    end
    
    def edit
    end

    def update
        @reading_list.works = Work.find(params[:reading_list][:works].reject(&:blank?))
        @reading_list.save!
        redirect_to reading_list_path(@reading_list)
    end

    def create
        if current_user.reading_lists.create(params[:reading_list])
            flash[:notice] = t :reading_list_successfully_created
        else
            flash[:alert] = t :error_creating_reading_list
        end
        redirect_to my_reading_lists_path
    end

    def sortable_model
        WorkSet
    end

    private

    def load_reading_list
        @reading_list = current_user.reading_lists.find(params[:id])
    end

    def check_reading_list_owner
        unless current_user == @reading_list.owner
            flash[:alert] = t :cannot_view_reading_list
            session[:previous_url] = request.fullpath
            redirect_to session[:two_urls_back] || root_path
        end
    end
end
