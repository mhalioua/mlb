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

  task update_game_status: :environment do
    (1..700).each do |index|
      game_day = GameDay.today.previous_days(index)
      if game_day
        game_day.update_weather
        game_day.update_games
        game_day.pitcher_box_score
      end
    end
  end

  task update_batters: :environment do
    Season.where("year = 2018").map { |season| season.update_batters }
  end

  task update_pitchers: :environment do
    Season.where("year = 2018").map { |season| season.update_pitchers }
  end

  task create_games: :environment do
    Season.where("year <= 2018").map { |season| season.create_games }
  end

  task create_matchups: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each { |game_day| game_day.create_matchups }
  end

  task prev_pitchers: :environment do
    [GameDay.today].each { |game_day| game_day.prev_pitchers }
  end

  task pitcher_informations: :environment do
    [GameDay.today].each { |game_day| game_day.pitcher_informations }
  end

  task update_games: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each { |game_day| game_day.update_games }
  end

  task pitcher_box_score: :environment do
    GameDay.yesterday.pitcher_box_score
  end

  task batter_box_score: :environment do
    GameDay.yesterday.batter_box_score
  end

  task update_weather: :environment do
    [GameDay.yesterday, GameDay.today].each { |game_day| game_day.update_weather }
  end

  task update_forecast: :environment do
    [GameDay.today, GameDay.tomorrow].each { |game_day| game_day.update_forecast }
  end

  task update_forecast_check: :environment do
    GameDay.today.update_forecast_check
  end

  task update_batters_scout: :environment do
    Season.where("year = 2018").map { |season| season.update_batters_scout }
  end

  task update_pitchers_scout: :environment do
    Season.where("year = 2018").map { |season| season.update_pitchers_scout }
  end

  task play_by_play: :environment do
    GameDay.yesterday.play_by_play
  end

  task play_by_play_previous: :environment do
    (8..20).each do |index|
      game_day = GameDay.today.previous_days(index)
      game_day.play_by_play
    end
  end

  task basic: [:create_season, :create_teams, :create_player, :update_player, :update_fangraphs, :update_game_status]

  task daily: [:create_player, :update_batters, :update_pitchers, :update_pitchers_scout, :update_batters_scout]

  task hourly: [:update_forecast, :update_games, :pitcher_box_score, :batter_box_score, :update_weather, :play_by_play]

  task ten: [:create_matchups, :prev_pitchers, :pitcher_informations]

end