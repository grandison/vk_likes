require 'nokogiri'

class PoiskVs
  def initialize(vkontakte)
    @user_id = vkontakte.user_id
    @browser = vkontakte.browser
    authorize
  end

  def authorize
    page = @browser.get("http://vk.com/poiskvs")
    params = JSON.parse(page.body.match(/var params = ({.+});/)[1])
    @auth_key = params["auth_key"]
    @sid = params["sid"]
    @secret = params["secret"]
    @access_token = params["access_token"]
    @viewer_type = params["viewer_type"]
    @ad_info = params["ad_info"]
    @lc_name = params["lc_name"]
  end

  def earn_likes(vk_object)
    @browser.post("http://poiskvs.kartadruzey.ru/do_offer?entity=#{vk_object}&viewer_sex=m&viewer_id=#{@user_id}&auth_key=#{@auth_key}&client_id=190")
  end

  def get_balance
    page = @browser.get("http://poiskvs.kartadruzey.ru/?api_url=http://api.vk.com/api.php&api_id=1980776&api_settings=394271&viewer_id=#{@user_id}&viewer_type=#{@viewer_type}&sid=#{@sid}&secret=#{@secret}&access_token=#{@access_token}&user_id=#{@user_id}&group_id=0&is_app_user=1&auth_key=#{@auth_key}&language=0&parent_language=0&ad_info=#{@ad_info}&referrer=user_apps&lc_name=#{@lc_name}&hash=uid%3D#{@user_id}")
    page.body.match(/\"prepaid\": (\d+)/)[1].to_i / 40.0
  end

  def order_likes(link, count)
    old_balance = get_balance
    vk_object = link.match(/(wall|photo|video)([0-9-]+_[0-9]+)/)[0]
    @browser.post("http://poiskvs.kartadruzey.ru/save_offer?entity=#{vk_object}&num=#{count}&viewer_sex=m&viewer_id=#{@user_id}&auth_key=#{@auth_key}&client_id=484")
    old_balance - get_balance
  end
end