require 'yaml'
require 'digest/md5'
require 'net/http'
require 'mechanize'
require 'json'
require 'antigate'
require 'cgi'

class Vkontakte
  attr_accessor :browser, :login, :password, :user_id, :access_token

  def initialize(login, password)
    @login = login
    @password = password
    @antigate = Antigate.wrapper("fb3357d9289354c7e36ff7edca07e0cf")
    @browser = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    @browser.follow_meta_refresh = true
    authorize
  end

  def like(vk_object)
    like_params = self.class.parse_vk_object(vk_object)
    type,owner_id,item_id = like_params["type"], like_params["owner_id"], like_params["item_id"]
    uri = URI.parse("https://api.vkontakte.ru/method/likes.add")

    args = {format: "JSON", type: type, owner_id: owner_id, item_id: item_id, access_token: @access_token}
    response = do_request("https://api.vkontakte.ru/method/likes.add", args)
    json_response = JSON.parse(response.body)

    p json_response

    if captcha_sid = json_response["error"] && json_response["error"]["captcha_sid"]
      captcha_url = json_response["error"]["captcha_img"]
      captcha_text = @antigate.recognize(captcha_url, "jpg")[1]
      args['captcha_sid'] = captcha_sid
      args['captcha_key'] = captcha_text
      response = do_request("https://api.vkontakte.ru/method/likes.add", args)
      json_response = JSON.parse(response.body)
      p json_response
    end
  end

  def do_request(url, args)
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(args)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  end

  def self.parse_vk_object(vk_object)
    _,type,owner_id,item_id = vk_object.match(/([a-z]+)(-?\d+)_(\d+)/).to_a
    type = "post" if type == "wall"
    return {"type" => type, "owner_id" => owner_id, "item_id" => item_id}
  end

  private

  def authorize
    page = @browser.post('http://login.vk.com/', {'email' => @login, 'pass' => @password, 'act' => 'login'})
    if page.body =~ /security_check/
      hash = JSON.parse(page.body.match(/var params = {.+hash: '(.+)';/)[1])
      params = {:act => "security_check", :code => login.last(4), :to => '', :al_page => '3', :hash => hash}
      @browser.post("http://vk.com/login.php", params)
    end
    page = @browser.get("https://oauth.vk.com/authorize?client_id=3454314&scope=1048575&response_type=token")
    url = page.body.match(/location\.href = "(.+)"/)[1]
    page = @browser.get(url)
    params = CGI::parse(page.uri.to_s.split("#")[1])
    @user_id = params["user_id"].first
    @access_token = params["access_token"].first
  end

end