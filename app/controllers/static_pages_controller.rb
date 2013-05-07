class StaticPagesController < ApplicationController
  def home
  end

  def about
  end

  def layout
    @work = Work.first
  end
end
