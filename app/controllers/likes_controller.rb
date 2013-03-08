class LikesController < ApplicationController
  def index
    @likes_count = LikeApp.sum(:likes_count)
  end
end
