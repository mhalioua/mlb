namespace :mlb do
  task create_season: :environment do
    Season.create_seasons
  end

  task create_teams: :environment do
    Team.create_teams
  end

  task create_player: :environment do
    Player.create_players
  end

  task update_player: :environment do
    Player.update_players
  end

  task update_batters: :environment do
    Season.where("year < 2018").order("year DESC").each { |season| season.update_batters }
  end

  task update_pitchers: :environment do
    Season.where("year < 2018").map { |season| season.update_pitchers }
  end

  task create_games: :environment do
    Season.where("year = 2017").map { |season| season.create_games }
  end

  task create_matchups: :environment do
    GameDay.yesterday.create_matchups
  end

  task update_games: :environment do
    GameDay.today.update_games
  end

  task pitcher_box_score: :environment do
    GameDay.yesterday.pitcher_box_score
  end
end