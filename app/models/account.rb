class Account < ActiveRecord::Base
  attr_accessible :login, :password, :earned_at, :likes_done, :phone_number
  has_many :like_apps, :dependent => :destroy

  validate :login_to_vk
  after_create :create_apps

  scope :sort_by_likes_count, joins(:like_apps).group("accounts.id").order("SUM(like_apps.likes_count) DESC")

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
    reload
    logger.debug("Start earning likes for #{login}")
    if earned_at.blank? || (earned_at < 1.day.ago)
      update_attributes(:earned_at => Time.now, :likes_done => 0)
    end
    return false if likes_done >= LikeApp::LIKES_IN_DAY
    olike = Olike.new(vkontakte)
    poiskvs = PoiskVs.new(vkontakte)
    likemachine = LikeMachine.new(vkontakte)

    i,j = 0,0
    times = LikeApp::LIKES_IN_DAY
    max_tries_count = 1000
    while (i < times && j < max_tries_count) do
      j += 1
      vk_object = olike.get_vk_object
      p vk_object
      next unless vk_object
      vkontakte.like(vk_object)
      increment!(:likes_done)

      olike.earn_likes(vk_object)
      poiskvs.earn_likes(vk_object)
      likemachine.earn_likes(vk_object)  

      i += 1
      sleep(5)
    end
    like_apps.each do |like_app|
      like_app.get_likes_count
    end
  end

  def self.order_likes(url, likes_count)
    ordered_likes_count = 0
    while ordered_likes_count < likes_count
      Account.sort_by_likes_count.each do |acc|
        ordered_likes_count += acc.order_likes(url, likes_count - ordered_likes_count)
        return ordered_likes_count if (ordered_likes_count >= likes_count) 
      end
    end
    LikeApp.delay.get_likes_count
    ordered_likes_count
  end

  def order_likes(url, likes_count)
    ordered_likes_count = 0
    like_apps.each do |like_app|
      ordered_likes_count += like_app.order_likes(url, likes_count - ordered_likes_count)
      return ordered_likes_count if (ordered_likes_count >= likes_count)
    end
    ordered_likes_count
  end

end
