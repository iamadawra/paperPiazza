class TagsController < ApplicationController
  def index
    @tags = Tag.all
    respond_to do |format|
      format.html
      format.json { render :json => @tags.map(&:attributes) }
    end
  end
end