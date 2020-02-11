module GetHtml
  def download_document_watir(url)
    doc = nil
    begin
        #Timeout::timeout(10){
          puts "a"
          browser = Watir::Browser.new(:chrome, {:chromeOptions => {:args => ['--headless']}})
          puts "b"
          browser.goto url
          sleep 10
          puts "c"
          doc = Nokogiri::HTML.parse(browser.html)
          browser.close
        #}
    rescue => e
      retry
    end
    return doc
  end
  def download_document(url)
    doc = nil
    count = 3
    begin
      if count > 0
        count -= 1
        Timeout::timeout(10){
          doc = Nokogiri::HTML(open(url, allow_redirections: :all))
        }
      end
    rescue => e
      retry
    end
    return doc
  end
end