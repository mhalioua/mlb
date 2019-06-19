module Update
  class Transactions

    include GetHtml

    def update
      teams = Team.all
      teams.each do |team|
        url = "http://m.#{team.mlb_abbr}.mlb.com/roster/transactions"
        puts url

        doc = download_document(url)
        next unless doc

        transactions = doc.css("tbody tr")
        transactions.last(20).each do |transaction|
          date = transaction.children[0].text
          description = transaction.children[1].text
          Transaction.find_or_create_by(date: date, description: description)
        end
      end
    end
  end
end
