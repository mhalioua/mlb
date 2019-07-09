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

  task update_fangraphs: :environment do
    Player.update_fangraphs
  end

  task update_batters: :environment do
    Season.where("year = 2019").map {|season| season.update_batters}
  end

  task update_pitchers: :environment do
    Season.where("year = 2019").map {|season| season.update_pitchers}
  end

  task create_games: :environment do
    Season.where("year <= 2019").map {|season| season.create_games}
  end

  task create_matchups: :environment do
    [GameDay.today, GameDay.tomorrow].each {|game_day| game_day.create_matchups}
  end

  task create_bullpen: :environment do
    GameDay.today.create_bullpen
  end

  task prev_pitchers: :environment do
    [GameDay.today].each {|game_day| game_day.prev_pitchers}
  end

  task pitcher_informations: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each {|game_day| game_day.pitcher_informations}
  end

  task update_games: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each {|game_day| game_day.update_games}
  end

  task pitcher_box_score: :environment do
    [GameDay.yesterday, GameDay.today].each {|game_day| game_day.pitcher_box_score}
  end

  task batter_box_score: :environment do
    [GameDay.yesterday, GameDay.today].each {|game_day| game_day.batter_box_score}
  end

  task update_weather: :environment do
    [GameDay.yesterday, GameDay.today].each {|game_day| game_day.update_weather}
  end

  task update_prev: :environment do
    (1..6).each do |index|
      date = Date.new(2019, 6, index)
      game_day = GameDay.find_by(date: date)
      game_day.create_matchups
    end
  end

  task update_forecast: :environment do
    [GameDay.today, GameDay.tomorrow].each {|game_day| game_day.update_forecast}
  end

  task update_forecast_check: :environment do
    GameDay.today.update_forecast_check
  end

  task update_batters_scout: :environment do
    Season.where("year = 2019").map {|season| season.update_batters_scout}
  end

  task update_pitchers_scout: :environment do
    Season.where("year = 2019").map {|season| season.update_pitchers_scout}
  end

  task update_transactions: :environment do
    GameDay.today.update_transactions
  end

  task player_number: :environment do
    teams = Team.all
    teams.each do |team|
      team.player_number
    end
  end

  task play_by_play: :environment do
    [GameDay.yesterday, GameDay.today].each {|game_day| game_day.play_by_play}
  end

  task umpire: :environment do
    Season.where("year = 2019").map {|season| season.umpire}
    Season.where("year = 2018").map {|season| season.umpire}
    Season.where("year = 2017").map {|season| season.umpire}
    Season.where("year = 2016").map {|season| season.umpire}
    Season.where("year = 2015").map {|season| season.umpire}
    Season.where("year = 2014").map {|season| season.umpire}
  end

  task history: :environment do
    date = Date.new(2018, 10, 1)
    game_day = GameDay.find_by(date: date)
    game_day.create_matchups
    game_day.update_games
    game_day.pitcher_box_score
    game_day.batter_box_score
    # game_day.play_by_play
    game_day.prev_pitchers
    game_day.pitcher_informations
    game_day.update_weather
  end

  task basic: [:create_season, :create_teams, :create_player, :update_player, :update_fangraphs]

  task daily: [:create_player, :update_batters, :update_pitchers, :update_pitchers_scout, :update_batters_scout]

  task source: [:create_matchups, :create_bullpen, :update_games, :pitcher_box_score, :batter_box_score, :player_number,
                :umpire, :update_transactions, :play_by_play, :prev_pitchers, :pitcher_informations, :update_forecast, :update_weather]

  task hourly: [:update_games, :pitcher_box_score, :batter_box_score, :play_by_play]

  task ten: [:create_matchups, :create_bullpen, :prev_pitchers, :pitcher_informations]

end