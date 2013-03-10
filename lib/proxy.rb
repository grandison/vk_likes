require 'httparty'

class Proxy
  attr_accessor :host, :port

  def initialize
    # proxy_list = HTTParty.get("http://hideme.ru/api/proxylist.txt?country=RU&type=h&out=plain&lang=ru").body.split("\r\n")
    # proxy = proxy_list.sample
    # @host, @port = proxy.split(":")
    @host, @port = "79.143.86.19", "8000"
  end
end