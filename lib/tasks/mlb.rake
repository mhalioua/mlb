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
    Season.where("year = 2018").order("year DESC").each { |season| season.update_batters }
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

  task update_games: :environment do
    [GameDay.yesterday, GameDay.today, GameDay.tomorrow].each { |game_day| game_day.update_games }
  end

  task pitcher_box_score: :environment do
    GameDay.yesterday.pitcher_box_score
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

  task basic: [:create_season, :create_teams, :create_player, :update_player, :update_fangraphs, :update_game_status]

  task daily: [:create_player, :update_batters, :update_pitchers]

  task hourly: [:update_weather, :update_forecast, :update_games, :pitcher_box_score]

  task ten: [:create_matchups]

  task add: :environment do
    require 'csv'

    filename = File.join Rails.root, 'csv' , "Workbook.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Workbook.create(Home_Team:row['Home_Team'], TEMP:row['TEMP'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['BARo'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'], table:"Workbook")
      count = count + 1
    end
    puts count

    filename = File.join Rails.root, 'csv', "colo.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Workbook.create(Home_Team:row['Home_Team'], TEMP:row['temp'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['Baro'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'], table:"colo")
      count = count + 1
    end
    puts count

    filename = File.join Rails.root, 'csv', "houston.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Workbook.create(Home_Team:row['Home_Team'], TEMP:row['TEMP'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['BARo'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'], table:"houston")
      count = count + 1
    end
    puts count

    filename = File.join Rails.root, 'csv', "tampa.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Workbook.create(Home_Team:row['Home_Team'], TEMP:row['TEMP'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['BARo'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'], table:"tampa")
      count = count + 1
    end
    puts count

    filename = File.join Rails.root, 'csv' , "colowind.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Workbook.create(Home_Team:row['Home_Team'], TEMP:row['temp'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['Baro'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'], table:"colowind", M:row['M'], N:row['N'])
      count = count + 1
    end
    puts count

    filename = File.join Rails.root, 'csv', "wind.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Workbook.create(Home_Team:row['Home_Team'], TEMP:row['TEMP'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['BARo'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'], table:"wind", M:row['M'], N:row['N'])
      count = count + 1
    end
    puts count
  end
end