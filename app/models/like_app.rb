class LikeApp < ActiveRecord::Base
  attr_accessible :acount_id, :likes_count, :name
  belongs_to :account
  after_create :get_likes_count

  LIKE_APPS = {
    "poisk_vs" => PoiskVs,
    "olike" => Olike
  }

  LIKES_IN_DAY = 300

  def self.get_likes_count
    find_each do |like_app| 
      like_app.delay.get_likes_count 
    end
  end

  def like_app
    @like_app ||= LIKE_APPS[name].new(account.vkontakte)
  end

  def get_likes_count
    update_attribute(:likes_count, like_app.get_balance)
  end

  def order_likes(url, likes_count)
    like_app.order_likes(url, likes_count)
  end
end
