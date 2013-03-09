class Account < ActiveRecord::Base
  attr_accessible :login, :password
  has_many :like_apps

  validate :login_to_vk
  after_create :create_apps

  def login_to_vk
    begin
      vkontakte
    rescue Mechanize::ResponseCodeError
      errors.add(:base, "Login,password combination is wrong")
    end
  end

  def vkontakte
    @vkontakte ||= Vkontakte.new(login,password)
  end

  def create_apps
    LikeApp::LIKE_APPS.keys.each do |like_app_name|
      like_apps.create(:name => like_app_name)
    end
  end

  def self.earn_likes
    Account.find_each do |u|
      u.delay.earn_likes
    end
  end

  def earn_likes
    olike = Olike.new(vkontakte)
    poiskvs = PoiskVs.new(vkontakte)
    likemachine = LikeMachine.new(vkontakte)

    i = 0
    times = LikeApp::LIKES_IN_DAY
    while (i < times) do
      vk_object = olike.get_vk_object
      next unless vk_object
      vkontakte.like(vk_object)
      
      olike.earn_likes(vk_object)
      poiskvs.earn_likes(vk_object)
      likemachine.earn_likes(vk_object)  

      i += 1
      sleep(1)
    end
    like_apps.each do |like_app|
      like_app.get_likes_count
    end
  end
end
