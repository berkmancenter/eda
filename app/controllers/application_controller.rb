class ApplicationController < ActionController::Base
    protect_from_forgery
    after_filter :store_location

    def check_edition_owner
        unless current_user == @edition.owner
            flash[:alert] = t :create_own_edition
            redirect_to new_edition_path
        end
    end

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end

    def store_location
        if ![new_user_session_path, new_user_registration_path].include?(request.fullpath) && !request.xhr?
            session[:previous_url] = request.fullpath 
        end
    end

    def after_sign_in_path_for(resource)
        session[:previous_url] || root_path
    end
end
