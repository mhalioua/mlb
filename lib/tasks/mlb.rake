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

  task update_batters: :environment do
    Season.where("year = 2020").map {|season| season.update_batters}
  end

  task update_pitchers: :environment do
    Season.where("year = 2020").map {|season| season.update_pitchers}
  end

  task create_games: :environment do
    Season.where("year <= 2020").map {|season| season.create_games}
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

  task update_yesterday: :environment do
    GameDay.yesterday.create_matchups
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

  task test_forecast: :environment do
    include GetHtml
    # game_day = game.game_day
    # home_team = game.home_team
    # time = DateTime.parse(game.game_date).strftime("%I:%M%p").to_time
    # diff = (time - Time.zone.now).to_i / 1.day
    diff = 0

    url = "https://www.accuweather.com/en/us/oakland/94612/hourly-weather-forecast/39606_pc?day=#{diff}"
    doc = download_document(url)
    puts url

    return unless doc
    script = doc.css("script")[2]
    hourlyweathers = script.children[0].text
    hourlyweathers = hourlyweathers[/\[.*\]/]
    hourlyweathers = JSON.parse(hourlyweathers)
    puts hourlyweathers

    # start_index = hourlyweathers.size - 1
    # return if start_index < 0 || (hourlyweathers[0].localTime > time && GameDay.today == game_day)
    # start_index = 0
    # hourlyweathers.each_with_index do |weather, index|
    #   date = weather.localTime
    #   if date > time
    #     break
    #   end
    #   start_index = index
    # end
    #
    # start_index = start_index - 1 if start_index != 0
    # start_index = start_index - 1 if start_index != 0
    # (-1..5).each do |index|
    #   temp = hourlyweathers[start_index].temp
    #   dp = hourlyweathers[start_index].extended.dewPoint
    #   hum = hourlyweathers[start_index].extended.humidity
    #   pressure = hourlyweathers[start_index].children[headers['Pressure']].text.squish
    #   precip = hourlyweathers[start_index].children[headers['Amount']].text.squish
    #   wind = hourlyweathers[start_index].children[headers['Wind']].text.squish
    #   feel = hourlyweathers[start_index].children[headers['Feels Like']].text.squish
    #
    #   time = hourlyweathers[start_index].children[headers['Time']].text.squish
    #   conditions = hourlyweathers[start_index].children[headers['Conditions']].children[1].text.squish
    #   precip_percent = hourlyweathers[start_index].children[headers['Precip']].text.squish
    #   cloud = hourlyweathers[start_index].children[headers['Cloud Cover']].text.squish
    #
    #
    #   wind_index = wind.rindex(' ')
    #   wind_dir = wind[wind_index+1..-1]
    #   if wind_dir == "W"
    #     wind_dir = "West"
    #   elsif wind_dir == "S"
    #     wind_dir = "South"
    #   elsif wind_dir == "N"
    #     wind_dir = "North"
    #   elsif wind_dir == "E"
    #     wind_dir = "East"
    #   end
    #   wind_speed = wind[0..wind_index-1]
    #   weather = game.weathers.create(station: "Forecast", hour: index)
    #   weather.update(temp: temp, dp: dp, hum: hum, pressure: pressure, wind_dir: wind_dir, wind_speed: wind_speed, precip: precip, feel: feel,
    #                  time: time, conditions: conditions, precip_percent: precip_percent, cloud: cloud)
    #
    #   start_index = start_index + 1 if start_index < hourlyweathers.size - 1
    # end
  end

  task basic: [:create_season, :create_teams, :create_player]

  task daily: [:create_player, :update_batters, :update_pitchers, :update_pitchers_scout, :update_batters_scout]

  task source: [:create_matchups, :create_bullpen, :update_games, :pitcher_box_score, :batter_box_score]

  task history: [:umpire, :update_transactions, :play_by_play, :prev_pitchers, :pitcher_informations]

  task weather: [:update_forecast, :update_weather]

  task hourly: [:update_games, :pitcher_box_score, :batter_box_score, :play_by_play]

  task ten: [:create_matchups, :create_bullpen, :prev_pitchers, :pitcher_informations]

end