class Olike
  def initialize(vkontakte)
    @browser = vkontakte.browser.clone
    proxy = Proxy.new
    @browser.set_proxy(proxy.host, proxy.port)
    @login = vkontakte.login
    @password = vkontakte.password
    login(vkontakte)
  end

  def login(vkontakte)
    @browser.get("http://olike.ru")
    page = @browser.post("http://olike.ru/reservelogin.php", {:vkk => "http://vk.com/#{vkontakte.username}"})
    status = page.parser.css("big").first.text
    vkontakte.set_status(status)
    page = page.forms[0].submit
    vkontakte.set_status("")
  end

  def get_vk_object
    @browser.get("http://olike.ru")
    page = @browser.get("http://olike.ru/redirectlot.php")
    uri = page.uri.to_s
    match = uri.match(/http\:\/\/vk\.com\/(.+)/)
    match && match[1]
  end

  def earn_likes(vk_object)
    @browser.get("http://olike.ru/API/api.php?func=checkmylike")
  end

  def get_balance
    page = @browser.get("http://olike.ru/API/api.php?func=balance")
    page.body.to_f
  end

  def order_likes(link, count)
    old_balance = get_balance
    page = @browser.get("http://olike.ru/buy_likes.php")
    page = page.form_with(:action => "") do |f|
      f.linkname = "LikeMe"
      f.linkpage = link
      f.budget = count
    end.submit
    old_balance - get_balance
  end
end