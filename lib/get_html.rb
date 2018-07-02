module GetHtml
  def download_document(url)
    doc = nil
    count = 3
    begin
      if count > 0
        count -= 1
        Timeout::timeout(3){
          doc = Nokogiri::HTML(open(url, allow_redirections: :all))
        }
      end
    rescue => e
      retry
    end
    return doc
  end
end