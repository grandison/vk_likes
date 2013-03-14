class OrdersController < ApplicationController
  def new
    @likes_count = LikeApp.sum(:likes_count)
    @order = Order.new
  end

  def create
    @order = Order.new(params[:order])
    if @order.save
      redirect_to(root_path, :notice => "All good")
    else
      render :new
    end
  end
end
