class LikeApp < ActiveRecord::Base
  attr_accessible :acount_id, :likes_count, :name
  belongs_to :account
  after_create :get_likes_count

  LIKE_APPS = {
    "poisk_vs" => PoiskVs,
    "olike" => Olike
  }

  LIKES_IN_DAY = 300

  def like_app
    @like_app ||= LIKE_APPS[name].new(account.vkontakte)
  end

  def get_likes_count
    update_attribute(:likes_count, like_app.get_balance)
  end
end
