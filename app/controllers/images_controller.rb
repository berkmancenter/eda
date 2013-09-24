require 'open-uri'
class ImagesController < ApplicationController
    before_filter :load_edition, only: [:index, :show]
    include ImagesHelper

    def index
        @images = @edition.images
    end

    def show
        if user_signed_in?
            current_user.current_edition = @edition
            current_user.save!
        end
        session[:current_edition] = @edition.id
        @page = Page.find(params[:id])
        @work = @page.work
        unless user_signed_in? && @note = current_user.note_for(@page.image_set)
            @note = @page.image_set.notes.new if @page.image_set
        end

        respond_to do |format|
            format.html do 
                render
            end
            format.txt do
                render layout: false
            end
        end
    end

    def download
        @image = Image.find(params[:id])
        if @image.nil?
            flash[:alert] = t(:image_not_found)
            redirect_to :back
        else
            temp_zip = Tempfile.new("zip-file")
            temp_image = Tempfile.new("image-file")
            temp_metadata = Tempfile.new("metadata-file")

            temp_image.binmode
            temp_image.write(open(large_jpg_url(@image)).read)
            temp_image.rewind

            temp_metadata.write(@image.credits)
            temp_metadata.rewind

            Zip::OutputStream.open(temp_zip.path) do |zip|
                zip.put_next_entry('image.jpg')
                zip.write(temp_image.read)
                zip.put_next_entry('metadata.txt')
                zip.write(temp_metadata.read)
            end
            send_file temp_zip.path, :type => 'application/zip', :disposition => 'attachment', :filename => "#{@image.url}.zip"
        end
    end
end
