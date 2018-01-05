require 'nokogiri'
require 'net/http'
require 'tmpdir'
require 'logger'

module NeedImg
  def self.need_coffee(options = {})
    logger = options[:logger] || default_logger
    uri = URI('http://api.flickr.com/services/feeds/photos_public.gne?tags=morningcoffee')
    logger.info 'Finding coffee for You'
    body = Net::HTTP.get_response(uri).body
    feed = Nokogiri::XML(body)
    image_url = feed.css('link[rel=enclosure]').to_a.sample['href']
    image_uri = URI(image_url)
    logger.info 'Downloading'
    open(File.join(Dir.pwd, File.basename(image_uri.path)), 'w') do |f|
      data = Net::HTTP.get_response(URI(image_url)).body
      f.write(data)
      logger.info "Coffee written to #{f.path}"
      return f.path
    end
  end

  def self.default_logger
    log = Logger.new($stdout)
    log.formatter = ->(severity, datetime, progname, msg) {
      "#{severity} -- #{msg}\n"
    }
    log
  end

end

NeedImg.need_coffee