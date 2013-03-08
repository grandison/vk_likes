class LikeMachine

  def initialize(vkontakte)
    @browser = vkontakte.browser
    @user_id = vkontakte.user_id
    authorize
  end

  def authorize
    page = @browser.get("http://vk.com/like.machine")
    params = JSON.parse(page.body.match(/var params = ({.+});/)[1])
    @auth_key = params["auth_key"]
  end

  def earn_likes(vk_object)
    like_params = Vkontakte.parse_vk_object(vk_object)
    @browser.get("http://likemachine.holycow.ru/?owner=#{like_params["owner_id"]}&offer=#{like_params["type"]}_#{like_params["owner_id"]}_#{like_params["item_id"]}&viewer_id=#{@user_id}&auth_key=#{@auth_key}&hash=28874682&x=404&y=216&method=check&_=#{Time.now.to_i * 1000 + 774}")
  end

  def get_balance
    page = @browser.get("http://likemachine.holycow.ru/?viewer_id=#{@user_id}&auth_key=#{@auth_key}&method=offers&_=#{Time.now.to_i * 1000 + 435}")
    page.body.match(/offersInit\(\{\}\, (\d+)/)[1].to_i / 10.0
  end

  def order_likes(link, count)
  end
end