module Update
  class Umpires

    include GetHtml

    def update(season)
      year = season.year
      url = "https://www.covers.com/pageLoader/pageLoader.aspx?page=/data/mlb/umpires/umpires.html"
      doc = download_document(url)
      puts url
      return unless doc

      elements = doc.css("td")
      elements.each do |element|
        next unless element.children[1]
        link = 'https://www.covers.com' + element.children[1]['href']
        text = element.children[1].text
        text = text.split(',')[0].upcase
        text = text.split("'")[0]
        puts link
        puts text
        link = link.gsub('2019', year.to_s)
        page = download_document(link)
        next unless page
        page = page.css("#LeftCol-wss table")
        count = page[0].css("tr:nth-child(2) td:nth-child(2)")[0]
        next unless count
        count = count.text.squish
        so = page[1].css("tr:nth-child(1) td:nth-child(4)")[0].text.squish
        bb = page[1].css("tr:nth-child(2) td:nth-child(4)")[0].text.squish
        sw = page[1].css("tr:nth-child(3) td:nth-child(4)")[0].text.squish
        puts so
        puts bb
        puts sw
        umpire = Umpire.where("year = ? AND statfox LIKE '%" + text + "%'", year)[0]
        if umpire
          umpire.update(
            covers: link,
            so: so,
            bb: bb,
            sw: sw,
            count: count
          )
        end
      end
    end

  end
end
