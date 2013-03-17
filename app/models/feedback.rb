class Feedback < ActiveRecord::Base
  attr_accessible :email, :name, :text
  validates :email, :name, :text, :presence => true

  before_create :send_email

  def send_email
    Mailer.send_feedback(email, name, text).deliver
  end
end
