module GetHtml
  def get_page(url)
    browser = Watir::Browser.new

    browser.goto url

    browser.div(:id, 'resultsDiv').divs.each do |div|
      p div
    end

    browser.close
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
