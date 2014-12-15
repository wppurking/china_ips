require "httparty"

class Apnic
  include HTTParty

  headers "Accept-Encoding" => "gzip"

  def initialize(debug: false)
    @debug = debug
  end


  def fetch_apnic
    @file ||= if @debug
      File.open('apnic_debug').read
    else
      puts '下载最新的 apnic 文件中.....'
      self.class.get('http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest').body
    end
    self
  end

  def travel_list
    ips = []
    @file.split("\n").each do |line|
      if line.index('apnic') == 0
        args = line.split("|")
        country = args[1].upcase
        net_type = args[2].downcase
        ip_address = args[3]
        yield ips, country, net_type, ip_address
      end
    end
    ips
  end

  def china_list
    travel_list do |ips, country, net_type, ip_address|
      ips << ip_address if country == 'CN' && net_type == 'ipv4' 
    end
  end

  def off_china_list
    travel_list do |ips, country, net_type, ip_address|
      ips << ip_address if country != 'CN' && net_type == 'ipv4' 
    end
  end
end


a = Apnic.new(debug: false).fetch_apnic
puts a.off_china_list


