require 'httparty'
require 'net/ping'

class Proxy
  attr_accessor :host, :port

  def initialize
    doc = Nokogiri.HTML(HTTParty.get("http://www.getproxy.jp/en/russia"))
    proxy_list = doc.css("#mytable .white td[1]").map &:text
    proxy = proxy_list.shuffle.find{|proxy| connectable?(proxy) } || proxy_list.sample
    p proxy
    @host, @port = proxy.split(":")
  end

  def connectable?(proxy)
    host, port = proxy.split(':')
    return Net::Ping::TCP.new(host, port).ping
  end
end