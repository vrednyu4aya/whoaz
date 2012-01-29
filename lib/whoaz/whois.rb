module Whoaz
  class Whois
    attr_accessor :name, :organization, :address, :phone, :fax, :email, :nameservers

    def initialize(domain)
      post_domain = domain.split('.', 2)
      raise InvalidDomain, "Invalid domain specified" unless
        [MAIN_TLD, REGIONAL_TLD].any? {|a| a.include? post_domain.last}

      url = URI WHOIS_URL
      req = Net::HTTP::Post.new(url.path, 'Referer' => WHOIS_REFERER)
      req.set_form_data('lang' => 'en', 'domain' => post_domain.first, 'dom' => ".#{post_domain.last}")
      res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req)}

      if res.code.to_i == 200
        doc = Nokogiri::HTML(res.body)
      else
        raise ServerError, "Server responded with code #{res.code}"
      end

      if doc.at_xpath('//table[4]/tr/td[2]/table[2]/tr[3]/td').try(:text).try(:strip) == 'This domain is free.'
        @free = true
      end

      if @name.nil? && @organization.nil?
        if doc.at_xpath('//table[4]/tr/td[2]/table[2]/td/p').
            try(:text).try(:strip) == 'Using of domain names contains less than 3 symbols is not allowed'
          raise DomainNameError, "Whois query for this domain name is not supported."
        end
      end

      doc.xpath('//table[4]/tr/td[2]/table[2]/td/table/tr').each do |registrant|
        @organization = registrant.at_xpath('td[2]/table/tr[1]/td[2]').try(:text)
        @name         = registrant.at_xpath('td[2]/table/tr[2]/td[2]').try(:text)
        @address      = registrant.at_xpath('td[3]/table/tr[1]/td[2]').try(:text)
        @phone        = registrant.at_xpath('td[3]/table/tr[2]/td[2]').try(:text)
        @fax          = registrant.at_xpath('td[3]/table/tr[3]/td[2]').try(:text)
        @email        = registrant.at_xpath('td[3]/table/tr[4]/td[2]').try(:text)
      end

      doc.xpath('//table[4]/tr/td[2]/table[2]/td/table/tr/td[4]/table').each do |nameserver|
        @nameservers = [
          nameserver.at_xpath('tr[2]/td[2]').try(:text),
          nameserver.at_xpath('tr[3]/td[2]').try(:text),
          nameserver.at_xpath('tr[4]/td[2]').try(:text),
          nameserver.at_xpath('tr[5]/td[2]').try(:text),
          nameserver.at_xpath('tr[6]/td[2]').try(:text),
          nameserver.at_xpath('tr[7]/td[2]').try(:text),
          nameserver.at_xpath('tr[8]/td[2]').try(:text),
          nameserver.at_xpath('tr[9]/td[2]').try(:text)
        ]
      end

      @nameservers.try(:compact!)
      @name, @organization = @organization, nil if @name.nil?
    end

    def free?
      @free ? true : false
    end

    def registered?
      !free?
    end
  end
end