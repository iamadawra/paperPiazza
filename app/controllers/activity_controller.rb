class ActivityController < ApplicationController
  def feed
    @activities = Activity.all
  end
end
