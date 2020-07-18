module Update
  class Umpires

    include GetHtml

    def update(season)
      year = season.year
      url = "https://www.covers.com/sport/baseball/mlb/umpires"
      doc = download_document(url)
      puts url
      return unless doc

      elements = doc.css(".covers-RefereeTable a")
      elements.each do |element|
        link = 'https://www.covers.com' + element['href']
        text = element.text
        text = text.split(',')[0].upcase
        text = text.split("'")[0]
        puts link
        puts text
        link = link.gsub('2020', year.to_s)
        page = download_document(link)
        next unless page
        page = page.css('table.covers-CoversMatchups-Table td')
        count = page[3].text.squish
        so = page[25].text.squish
        bb = page[27].text.squish
        sw = page[29].text.squish
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
