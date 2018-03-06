namespace :mlb do
  task create_player: :environment do
  	Player.create_players
  end
end