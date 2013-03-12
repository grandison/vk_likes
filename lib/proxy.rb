require 'httparty'

class Proxy
  attr_accessor :host, :port

  def initialize
    doc = Nokogiri.HTML(HTTParty.get("http://www.getproxy.jp/en/russia"))
    proxy_list = doc.css("#mytable .white td[1]").map &:text
    proxy = proxy_list.sample
    @host, @port = proxy.split(":")
  end
end