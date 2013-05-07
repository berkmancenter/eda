class StaticPagesController < ApplicationController
  def home
  end

  def about
  end

  def layout
    @work = Work.find(34)
  end
end
