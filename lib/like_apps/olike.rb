class Olike
  def initialize(vkontakte)
    @browser = vkontakte.browser
    login
  end

  def login
    page = @browser.get("https://oauth.vk.com/authorize?client_id=3419461&redirect_uri=http://undefied.ru/olikelogin.php&scope=friends,wall,offline&display=page")
    url = page.body.match(/href='(.+)&/)[1]
    @browser.get(url)
  end

  def get_vk_object
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
    page = @browser.get("http://olike.ru/buy_likes.php")
    page = page.form_with(:action => "") do |f|
      f.linkname = "LikeMe"
      f.linkpage = link
      f.budget = count
    end.submit
  end
end