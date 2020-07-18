module Update
  class Transactions

    include GetHtml

    def update
      teams = Team.all
      teams.each do |team|
        url = "https://www.mlb.com/#{team.mlb_abbr}/roster/transactions"
        puts url

        doc = download_document(url)
        next unless doc

        transactions = doc.css("tbody tr")
        if transactions.length >= 20
          elements = transactions[-20..-1]
        else
          elements = transactions
        end
        elements.each do |transaction|
          date = transaction.children[1].text
          description = transaction.children[3].text
          Transaction.find_or_create_by(team_id: team.id, date: date, description: description)
        end
      end
    end
  end
end
