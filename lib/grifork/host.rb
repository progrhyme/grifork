class Grifork::Host
  attr :hostname, :ipaddress
  class Uninitializable < StandardError; end

  def initialize(host = {})
    case host
    when String
      @hostname  = host
    when Hash
      @hostname  = host[:hostname]
      @ipaddress = host[:ipaddress]
    else
      raise Uninitializable, "Unknow type! #{host.inspect}"
    end
  end
end
