class ApplicationController < ActionController::Base
    protect_from_forgery
    after_filter :store_location
    before_filter :recreate_search_from_session
    #helper_method :image_set_path_from_work

    def check_edition_owner
        unless current_user == @edition.owner
            flash[:alert] = t :cannot_edit_edition
            session[:previous_url] = request.fullpath
            redirect_to session[:two_urls_back] || new_edition_path
        end
    end

    def load_edition
        edition_id = params[:edition_id] || params[:id]
        @edition = Edition.find(edition_id)
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
        revision.text = text
        if in_edition.is_child? && in_edition.parent == revises_work.edition
            revision.revises_work = revises_work
        end
        revision.edition = in_edition
        revision.image_set = revises_work.image_set.duplicate
        revision.save!
        session.delete(:work_revision)
        revision
    end

    def recreate_search_from_session
        return unless session[:search_results]
        @search = session[:search_results]
        session.delete(:search_results)
    end

    def store_location
        if ![new_user_session_path, new_user_registration_path].include?(request.fullpath) && !request.xhr?
            session[:previous_url] = request.fullpath 
            session[:two_urls_back] = session[:previous_url]
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

    def load_image_set
        @image_set = ImageSet.find(params[:image_set_id])
    end

    def pull_works_for_edition_image_set(edition, image_set)
        all_works = Work.in_editions(Edition.for_user(current_user)).
            in_image(image_set.image).group_by{ |w| w.edition == edition }
        logger.info(all_works.inspect)
        @this_editions_works = all_works[true]
        if @this_editions_works.nil? && edition.is_child?
            @this_editions_works = Work.joins(:edition).where(
                edition: { id: edition.parent.id}
            ).in_image(image_set.image)
        end
        @other_editions_works = all_works[false]
        @variants = @this_editions_works.map{|w| w.variants}.flatten.compact.uniq if @this_editions_works
    end
end
