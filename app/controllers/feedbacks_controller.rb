# coding: utf-8
class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new
    if @feedback.update_attributes(params[:feedback])
      redirect_to(root_path, :notice => "Отзыв отправлен")
    else
      render :new
    end
  end
end
