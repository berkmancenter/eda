class ApplicationController < ActionController::Base
    protect_from_forgery
    after_action :store_location
    before_action :do_search

    def not_found
        raise ActionController::RoutingError.new('Not Found') unless Rails.env.development?
    end

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
        revises_work = Work.find(session[:from_other_edition]['from_work_id'])
        revision = revises_work.dup
        text = revises_work.text
        revision.text = text
        if in_edition.is_child? && in_edition.parent == revises_work.edition
            revision.revises_work = revises_work
        end
        revision.edition = in_edition
        revision.image_set = revises_work.image_set.duplicate
        revision.save!
        session.delete(:from_other_edition)
        revision
    end

    def do_search(query = nil)
        params[:q] = query unless query.nil?
        sync_search_params_and_session
        return unless params[:q]
        visible_editions = Edition.for_user(current_user).map(&:id)
        if params[:current_edition] && visible_editions.include?(params[:current_edition].to_i)
            edition_ids = [params[:current_edition]]
        else
            edition_ids = visible_editions
        end
        @search = Work.search do
            with(:edition_id).any_of(edition_ids)
            case params[:limit_to_field]
            when 'work_text'
                fulltext params[:q] do
                    fields(:lines, :number, :title => 2.0)
                end
            when 'title'
                fulltext params[:q] do
                    fields(:title)
                end
            when 'work_metadata'
                fulltext params[:q] do
                    fields(:metadata)
                end
            else
                fulltext params[:q] do
                    fields(:lines, :number, :title => 2.0)
                end
            end
            paginate page: 1, per_page: Work.count
        end
        clear_search if query
    end

    def clear_search
        params.delete(:q)
        params.delete(:current_edition)
        params.delete(:limit_to_field)

        session.delete(:q)
        session.delete(:current_edition)
        session.delete(:limit_to_field)
    end

    def sync_search_params_and_session
        return unless params[:q] || session[:q]
        session[:q] = params[:q] if params[:q]
        session[:current_edition] = params[:current_edition] if params[:current_edition]
        session[:limit_to_field] = params[:limit_to_field] if params[:limit_to_field]
        params[:q] = session[:q] if session[:q]
        params[:current_edition] = session[:current_edition] if session[:current_edition]
        params[:limit_to_field] = session[:limit_to_field] if session[:limit_to_field]
        if params[:current_edition] == 'all'
            params.delete(:current_edition)
            session.delete(:current_edition)
        end

        if params[:q].strip.empty?
            @search = nil
            clear_search
        end
    end

    def store_location
        logger.debug("Store location paths: #{request.path} - #{oai_repository_path}")
        return if request.path.starts_with?('/oai/')
        non_stored_locations = [
            oai_repository_path,
            new_user_session_path,
            new_user_registration_path,
            new_user_password_path,
            edit_user_password_path
        ]
        if !non_stored_locations.include?(request.path) && !request.xhr? && request.request_method == 'GET'
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
        @this_editions_works = all_works[true]
        if @this_editions_works.nil? && edition.is_child?
            @this_editions_works = Work.joins(:edition).where(
                editions: { id: edition.parent.id}
            ).in_image(image_set.image)
        end
        @other_editions_works = all_works[false]
        @variants = @this_editions_works.map{|w| w.variants}.flatten.compact.uniq if @this_editions_works
    end

    protected

    def render_not_found
      render file: "#{Rails.root}/public/404", layout: false, status: 404
    end
end
