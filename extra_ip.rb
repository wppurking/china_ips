class Apnic
  def fetch_apnic(debug: false)
    @file ||= if debug
      File.open('apnic_debug').read
    else
      HTTParty.get('http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest', headers: {"Accept-Encoding" => "gzip"}).body
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


a = Apnic.new.fetch_apnic(debug: true)
puts a.off_china_list


