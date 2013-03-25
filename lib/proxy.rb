require 'httparty'
require 'mechanize'

class Proxy
  attr_accessor :host, :port

  def initialize
    @browser = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.open_timeout   = 5
      agent.read_timeout   = 5
    }
    @browser.follow_meta_refresh = true
    doc          = Nokogiri.HTML(HTTParty.get("http://www.getproxy.jp/en/russia"))
    proxy_list   = doc.css("#mytable .white td[1]").map &:text
    proxy        = proxy_list.shuffle.find{|proxy| connectable?(proxy) } || proxy_list.sample
    @host, @port = proxy.split(":")
  end

  def connectable?(proxy)
    host, port = proxy.split(':')
    @browser.set_proxy(host, port)
    begin
      @browser.get("http://olike.ru")
    rescue
      return false
    end
    return true
  end
end