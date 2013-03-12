class Olike
  def initialize(vkontakte)
    @browser = vkontakte.browser.clone
    proxy = Proxy.new
    @browser.set_proxy(proxy.host, proxy.port)
    @login = vkontakte.login
    @password = vkontakte.password
    login
  end

  def login
    page = @browser.get("http://olike.ru")
    page = page.forms[0].submit
    if (f = page.form_with(:id => "login_submit"))
      f.email = @login
      f.password = @password
      page = f.submit
    end
    while url = page.body.match(/location\.href ?+= ?+["'](.+)["']/).try(:[], 1)
      page = @browser.get(url)
    end
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