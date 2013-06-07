class ImageGroupsController < ApplicationController
  before_filter :load_edition

  def index
    @image_groups = @edition.image_groups
  end

  def show
    @image_group = ImageGroup.find( params[ :id ] )
  end

  def load_edition
    @edition = Edition.find( params[ :edition_id ] )
  end
end

