class StaticPagesController < ApplicationController
  def home
  end

  def about
  end

  def layout
    @page = Page.find(8511)
    @work = @page.work
    @image = @page.image_group_image.image
  end
end
