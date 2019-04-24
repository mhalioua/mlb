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
    Season.where("year = 2019").map { |season| season.update_batters }
  end

  task update_pitchers: :environment do
    Season.where("year = 2019").map { |season| season.update_pitchers }
  end

  task create_games: :environment do
    Season.where("year <= 2019").map { |season| season.create_games }
  end

  task create_matchups: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each { |game_day| game_day.create_matchups }
  end

  task create_bullpen: :environment do
    GameDay.today.create_bullpen
  end

  task prev_pitchers: :environment do
    [GameDay.today].each { |game_day| game_day.prev_pitchers }
  end

  task pitcher_informations: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each { |game_day| game_day.pitcher_informations }
  end

  task update_games: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each { |game_day| game_day.update_games }
  end

  task pitcher_box_score: :environment do
    [GameDay.yesterday, GameDay.today].each { |game_day| game_day.pitcher_box_score }
  end

  task batter_box_score: :environment do
    [GameDay.yesterday, GameDay.today].each { |game_day| game_day.batter_box_score }
  end

  task update_weather: :environment do
    [GameDay.yesterday, GameDay.today].each { |game_day| game_day.update_weather }
  end

  task update_prev: :environment do
    date = Date.new(2019, 4, 2)
    game_day = GameDay.find_by(date: date)
    game_day.prev_pitchers
    game_day.pitcher_informations
  end

  task update_forecast: :environment do
    [GameDay.today, GameDay.tomorrow].each { |game_day| game_day.update_forecast }
  end

  task update_forecast_check: :environment do
    GameDay.today.update_forecast_check
  end

  task update_batters_scout: :environment do
    Season.where("year = 2019").map { |season| season.update_batters_scout }
  end

  task update_pitchers_scout: :environment do
    Season.where("year = 2019").map { |season| season.update_pitchers_scout }
  end

  task play_by_play: :environment do
    [GameDay.yesterday, GameDay.today].each { |game_day| game_day.play_by_play }
  end

  task basic: [:create_season, :create_teams, :create_player, :update_player, :update_fangraphs]

  task daily: [:create_player, :update_batters, :update_pitchers, :update_pitchers_scout, :update_batters_scout]

  task source: [:ten, :hourly, :update_forecast, :update_weather]

  task hourly: [:update_games, :pitcher_box_score, :batter_box_score, :play_by_play]

  task ten: [:create_matchups, :create_bullpen, :prev_pitchers, :pitcher_informations]

end