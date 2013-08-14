class ApplicationController < ActionController::Base
    protect_from_forgery
    after_filter :store_location

    def check_edition_owner
        unless current_user == @edition.owner
            flash[:alert] = t :cannot_edit_edition
            session[:previous_url] = request.fullpath
            redirect_to new_edition_path
        end
    end

    def load_edition
        @edition = Edition.find(params[:edition_id])
    end

    def set_users_current_edition
        return unless @edition
        if user_signed_in? 
            current_user.current_edition = @edition
            current_user.save!
        end
        session[:current_edition] = @edition.id
    end

    def create_revision_from_session(in_edition)
        revises_work = Work.find(session[:work_revision][:revises_work_id])
        revision = revises_work.dup
        text = revises_work.text

        logger.info("LOOK HERE: #{text}")

        revision.text = text
        if in_edition.is_child? && in_edition.parent == revises_work.edition
            revision.revises_work = revises_work
        end
        revision.edition = in_edition
        revision.save!
        session.delete(:work_revision)
        revision
    end

    def store_location
        if ![new_user_session_path, new_user_registration_path].include?(request.fullpath) && !request.xhr?
            session[:previous_url] = request.fullpath 
        end
    end

    def after_sign_in_path_for(resource)
        session[:previous_url] || root_path
    end

    def with_format(format, &block)
        old_formats = formats
        begin
            self.formats = [format]
            return block.call
        ensure
            self.formats = old_formats
        end
    end
end
