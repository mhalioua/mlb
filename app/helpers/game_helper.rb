module GameHelper
  def batter_class(predicted)
    if predicted
      "predicted batter"
    else
      "batter"
    end
  end

  def handedness_header(left)
    if left
      "LHP"
    else
      "RHP"
    end
  end

  def handedness(left)
    if left
      "L"
    else
      "R"
    end
  end

  def bullpen_day_name(num)
    num += 1
    day = Date.parse("#{@game_day.year}-#{@game_day.month}-#{@game_day.day}").wday
    return Date::DAYNAMES[day-num]
  end

  def wind_data(name, first_wind, second_wind, third_wind)
    first_wind_speed, first_wind_dir = split_wind(first_wind)
    second_wind_speed, second_wind_dir = split_wind(second_wind)
    third_wind_speed, third_wind_dir = split_wind(third_wind)

    search_string = []
    winds = []
    if name == 'Rockies'
      search_string.push('"table" = ' + "'colowind'")
    else
      search_string.push('"table" = ' + "'wind'")
    end

    search_string.push("Home_Team = '#{name}'")
    wind = get_wind('average runs in this stadium', search_string, 0)
    winds.push(wind)

    search_string.push("N >= 0 AND N <= 5")
    wind = get_wind('average runs in this stadium with 0-5mph winds', search_string, 0)
    winds.push(wind)

    first_wind_speed, second_wind_speed = swap(first_wind_speed, second_wind_speed) if first_wind_speed > second_wind_speed
    first_wind_speed, third_wind_speed = swap(first_wind_speed, third_wind_speed) if first_wind_speed > third_wind_speed
    second_wind_speed, third_wind_speed = swap(second_wind_speed, third_wind_speed) if second_wind_speed > third_wind_speed

    if third_wind_speed > 5
      filter_min = 6
      filter_max = 13

      if first_wind_speed < 6
        if second_wind_speed < 6
          filter_value = third_wind_speed
        else
          filter_value = second_wind_speed
        end
      else
        filter_value = first_wind_speed
      end

      filter_value = filter_value.to_i

      if filter_value > 6
        filter_min = filter_value - 1
        filter_max = filter_value + 6
      end

      wind_directions = ["NNW", "North", "NNE", "NE", "ENE", "East", "ESE", "SE", "SSE", "South", "SSW", "SW", "WSW", "West", "WNW", "NW", "NNW", "N"]
      currect_directions = []
      real_directions = []

      if wind_directions.include?(first_wind_dir)
        index = wind_directions.index(first_wind_dir)
        currect_directions.push(index-1)
        currect_directions.push(index)
        real_directions.push(index)
        currect_directions.push(index+1)
      end

      if wind_directions.include?(second_wind_dir)
        index = wind_directions.index(second_wind_dir)
        currect_directions.push(index-1)
        currect_directions.push(index)
        real_directions.push(index)
        currect_directions.push(index+1)
      end

      if wind_directions.include?(third_wind_dir)
        index = wind_directions.index(third_wind_dir)
        currect_directions.push(index-1)
        currect_directions.push(index)
        real_directions.push(index)
        currect_directions.push(index+1)
      end

      currect_directions = currect_directions.uniq

      search_string = []
      if name == 'Rockies'
        search_string.push('"table" = ' + "'colowind'")
      else
        search_string.push('"table" = ' + "'wind'")
      end
      search_string.push("Home_Team = '#{name}'")
      search_string.push("N >= #{filter_min} AND N <= #{filter_max}")

      search_string_original = search_string
      wind = get_wind("average runs in this stadium with #{filter_min}-#{filter_max}mph winds", search_string, 1)
      winds.push(wind)

      directions = [ 'North', 'NNE', 'NE', 'ENE', 'East', 'ESE', 'SE', 'SSE', 'South', 'SSW', 'SW', 'WSW', 'West', 'WNW', 'NW', 'NNW']
      parks = ['ARI', 'ATL', 'BAL', 'BOS', 'CHC', 'CHW', 'CIN', 'CLE', 'COL', 'DET', 'HOU', 'KCR', 'LAA', 'LAD', 'MIA', 'MIL', 'MIN', 'NYM', 'NYY', 'OAK', 'PHI', 'PIT', 'SDP', 'SFG', 'SEA', 'STL', 'TEX', 'TOR', 'WSN']

      wind_directions.each_with_index do |direction, index|
        search_string = search_string_original
        search_string.push("M = '#{wind_directions[index]}'")

        additional_wind = ''
        team = Team.find_by(name: name)
        if directions.include?(wind_directions[index]) && parks.include?(team.espn_abbr)
          additional_wind =  @@re[team.espn_abbr][wind_directions[index]]
        end

        direction = 2
        if real_directions.include?(index)
          direction = 1
        elsif currect_directions.include?(index)
          direction = 0
        end

        wind = get_wind("average runs in this stadium with #{filter_min}-#{filter_max}mph, going #{wind_directions[index]} (#{additional_wind})", search_string, direction)
        winds.push(wind)
      end
    else
      winds[1][6] = 1
    end
    return winds
  end

  def swap(first, second)
    return second, first
  end

  def split_wind(wind)
    wind = wind.to_s
    wind = wind.gsub("mph ", "")
    wind = wind.gsub(/[[:space:]]+/," ")
    index = wind.index(" ")
    wind_speed = index ? wind[0..index-1].to_i : 0
    wind_dir = index ? wind[index+1..wind.length] : "Variable"
    return wind_speed, wind_dir
  end

  def get_wind(header_string, search_string, flag)
    query = Workbook.where(search_string.join(" AND "))

    return [
      header_string,
      query.average(:R).to_f.round(2),
      query.average(:Total_Hits).to_f.round(2),
      query.count(:R),
      query.average(:Total_Walks).to_f.round(2),
      query.average(:home_runs).to_f.round(2),
      flag
    ]
  end

  @@re = Hash[
    'ARI' => Hash[
      'North' => '',
      'NNE' => '',
      'NE' => '',
      'ENE' => '',
      'East' => '',
      'ESE' => '',
      'SE' => '',
      'SSE' => '',
      'South' => '',
      'SSW' => '',
      'SW' => '',
      'WSW' => '',
      'West' => '',
      'WNW' => '',
      'NW' => '',
      'NNW' => ''
    ],
    'ATL' => Hash[
      'North' => 'LO',
      'NNE' => 'LO',
      'NE' => 'CO/ro',
      'ENE' => 'RO',
      'East' => 'RO/lr',
      'ESE' => 'LR/ro',
      'SE' => 'LR',
      'SSE' => 'LI/LR',
      'South' => 'LI',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI',
      'West' => 'RI/RL',
      'WNW' => 'RL/ri',
      'NW' => 'RL/lo',
      'NNW' => 'LO/rl'
    ],
    'BAL' => Hash[
      'North' => 'LO',
      'NNE' => 'LO',
      'NE' => 'CO/ro',
      'ENE' => 'RO',
      'East' => 'RO/lr',
      'ESE' => 'LR/ro',
      'SE' => 'LR',
      'SSE' => 'LI/LR',
      'South' => 'LI',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI',
      'West' => 'RI/RL',
      'WNW' => 'RL/ri',
      'NW' => 'RL/lo',
      'NNW' => 'LO/rl'
    ],
    'BOS' => Hash[
      'North' => 'LO',
      'NNE' => 'LO',
      'NE' => 'CO/ro',
      'ENE' => 'RO',
      'East' => 'RO/lr',
      'ESE' => 'LR/RO',
      'SE' => 'LR/li',
      'SSE' => 'LI/LR',
      'South' => 'LI',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI',
      'West' => 'RI/rl',
      'WNW' => 'RL/ri',
      'NW' => 'RL/lo',
      'NNW' => 'LO/RL'
    ],
    'CHC' => Hash[
      'North' => 'LO',
      'NNE' => 'LO',
      'NE' => 'CO/ro',
      'ENE' => 'RO',
      'East' => 'RO/lr',
      'ESE' => 'LR/RO',
      'SE' => 'LR',
      'SSE' => 'LI/LR',
      'South' => 'LI',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI',
      'West' => 'RI/rl',
      'WNW' => 'RL/ri',
      'NW' => 'RL',
      'NNW' => 'RL/LO'
    ],
    'CHW' => Hash[
      'North' => 'RI/rl',
      'NNE' => 'RL/RI',
      'NE' => 'RL/lo',
      'ENE' => 'LO/rl',
      'East' => 'LO',
      'ESE' => 'LO',
      'SE' => 'CO',
      'SSE' => 'RO',
      'South' => 'RO/lr',
      'SSW' => 'RO/lr',
      'SW' => 'LR',
      'WSW' => 'LI/LR',
      'West' => 'LI',
      'WNW' => 'LI',
      'NW' => 'CI',
      'NNW' => 'RI'
    ],
    'CIN' => Hash[
      'North' => 'RI/rl',
      'NNE' => 'RL/RI',
      'NE' => 'RL/lo',
      'ENE' => 'LO/rl',
      'East' => 'LO',
      'ESE' => 'LO',
      'SE' => 'CO',
      'SSE' => 'RO',
      'South' => 'RO/lr',
      'SSW' => 'RO/lr',
      'SW' => 'LR',
      'WSW' => 'LI/LR',
      'West' => 'LI',
      'WNW' => 'LI',
      'NW' => 'CI',
      'NNW' => 'RI'
    ],
    'CLE' => Hash[
      'North' => 'CO',
      'NNE' => 'RO',
      'NE' => 'RO/lr',
      'ENE' => 'RO/lr',
      'East' => 'LR/li',
      'ESE' => 'LR',
      'SE' => 'LR/LI',
      'SSE' => 'LI',
      'South' => 'CI',
      'SSW' => 'RI',
      'SW' => 'RL/RI',
      'WSW' => 'RL',
      'West' => 'RL/lo',
      'WNW' => 'RL/LO',
      'NW' => 'LO/rl',
      'NNW' => 'LO'
    ],
    'COL' => Hash[
      'North' => 'CO',
      'NNE' => 'RO',
      'NE' => 'RO',
      'ENE' => 'RO/lr',
      'East' => 'LR',
      'ESE' => 'LR/LI',
      'SE' => 'LI',
      'SSE' => 'LI',
      'South' => 'CI',
      'SSW' => 'RI',
      'SW' => 'RI',
      'WSW' => 'RI/RL',
      'West' => 'RL',
      'WNW' => 'RL/LO',
      'NW' => 'LO',
      'NNW' => 'LO'
    ],
    'DET' => Hash[
      'North' => 'RI',
      'NNE' => 'RI/rl',
      'NE' => 'RL/RI',
      'ENE' => 'RL',
      'East' => 'RL/LO',
      'ESE' => 'LO/rl',
      'SE' => 'LO',
      'SSE' => 'CO',
      'South' => 'RO',
      'SSW' => 'RO',
      'SW' => 'RO/LR',
      'WSW' => 'LR/ro',
      'West' => 'LR/LI',
      'WNW' => 'LI/lr',
      'NW' => 'LI',
      'NNW' => 'RI'
    ],
    'HOU' => Hash[
      'North' => '',
      'NNE' => '',
      'NE' => '',
      'ENE' => '',
      'East' => '',
      'ESE' => '',
      'SE' => '',
      'SSE' => '',
      'South' => '',
      'SSW' => '',
      'SW' => '',
      'WSW' => '',
      'West' => '',
      'WNW' => '',
      'NW' => '',
      'NNW' => ''
    ],
    'KCR' => Hash[
      'North' => 'LO/rl',
      'NNE' => 'LO',
      'NE' => 'CO',
      'ENE' => 'RO',
      'East' => 'RO',
      'ESE' => 'RO/LR',
      'SE' => 'LR',
      'SSE' => 'LR/LI',
      'South' => 'LI/lr',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI',
      'West' => 'RI',
      'WNW' => 'RI/RL',
      'NW' => 'RL',
      'NNW' => 'RL/LO'
    ],
    'LAA' => Hash[
      'North' => 'LO/rl',
      'NNE' => 'LO',
      'NE' => 'CO',
      'ENE' => 'RO',
      'East' => 'RO',
      'ESE' => 'RO/LR',
      'SE' => 'LR',
      'SSE' => 'LR/LI',
      'South' => 'LI/lr',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI',
      'West' => 'RI',
      'WNW' => 'RI/RL',
      'NW' => 'RL',
      'NNW' => 'RL/LO'
    ],
    'LAD' => Hash[
      'North' => 'LO',
      'NNE' => 'LO',
      'NE' => 'RO',
      'ENE' => 'RO',
      'East' => 'RO/LR',
      'ESE' => 'LR/ro',
      'SE' => 'LR/li',
      'SSE' => 'LR/LI',
      'South' => 'LI',
      'SSW' => 'LI/CI',
      'SW' => 'CI',
      'WSW' => 'RI',
      'West' => 'RI/RL',
      'WNW' => 'RL',
      'NW' => 'RL/lo',
      'NNW' => 'LO/rl'
    ],
    'MIA' => Hash[
      'North' => 'RI',
      'NNE' => 'RL/RI',
      'NE' => 'RL',
      'ENE' => 'LO/rl',
      'East' => 'LO',
      'ESE' => 'LO',
      'SE' => 'CO',
      'SSE' => 'RO',
      'South' => 'RO',
      'SSW' => 'RO/lr',
      'SW' => 'LR',
      'WSW' => 'LI/LR',
      'West' => 'LI',
      'WNW' => 'LI',
      'NW' => 'CI',
      'NNW' => 'RI'
    ],
    'MIL' => Hash[
      'North' => 'RI/rl',
      'NNE' => 'RL/RI',
      'NE' => 'RL/lo',
      'ENE' => 'LO/rl',
      'East' => 'LO',
      'ESE' => 'LO',
      'SE' => 'CO',
      'SSE' => 'RO',
      'South' => 'RO/lr',
      'SSW' => 'RO/lr',
      'SW' => 'LR',
      'WSW' => 'LI/LR',
      'West' => 'LI',
      'WNW' => 'LI',
      'NW' => 'CI',
      'NNW' => 'RI'
    ],
    'MIN' => Hash[
      'North' => 'RL',
      'NNE' => 'RL/lo',
      'NE' => 'LO',
      'ENE' => 'LO',
      'East' => 'CO',
      'ESE' => 'RO',
      'SE' => 'RO',
      'SSE' => 'LR/RO',
      'South' => 'LR',
      'SSW' => 'LR/LI',
      'SW' => 'LI',
      'WSW' => 'LI',
      'West' => 'CI',
      'WNW' => 'RI',
      'NW' => 'RI',
      'NNW' => 'RL/RI'
    ],
    'NYM' => Hash[
      'North' => 'LO/CO',
      'NNE' => 'RO',
      'NE' => 'RO/lr',
      'ENE' => 'RO/LR',
      'East' => 'LR/RO',
      'ESE' => 'LR',
      'SE' => 'LI/LR',
      'SSE' => 'LI',
      'South' => 'CI/LI',
      'SSW' => 'RI',
      'SW' => 'RI/rl',
      'WSW' => 'RI/RL',
      'West' => 'RL/ri',
      'WNW' => 'RL',
      'NW' => 'LO/rl',
      'NNW' => 'LO'
    ],
    'NYY' => Hash[
      'North' => 'RL/lo',
      'NNE' => 'RL/LO',
      'NE' => 'LO',
      'ENE' => 'CO',
      'East' => 'RO',
      'ESE' => 'RO',
      'SE' => 'RO/lr',
      'SSE' => 'LR/ro',
      'South' => 'LI/LR',
      'SSW' => 'LI/lr',
      'SW' => 'LI',
      'WSW' => 'CI',
      'West' => 'RI',
      'WNW' => 'RI',
      'NW' => 'RI/RL',
      'NNW' => 'RL/ri'
    ],
    'OAK' => Hash[
      'North' => 'LO/rl',
      'NNE' => 'LO',
      'NE' => 'LO/co',
      'ENE' => 'RO/co',
      'East' => 'RO',
      'ESE' => 'RO/LR',
      'SE' => 'LR',
      'SSE' => 'LR/LI',
      'South' => 'LI/lr',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI/CI',
      'West' => 'RI',
      'WNW' => 'RI/RL',
      'NW' => 'RL/RI',
      'NNW' => 'RL/LO'
    ],
    'PHI' => Hash[
      'North' => 'CO/lo',
      'NNE' => 'CO',
      'NE' => 'RO',
      'ENE' => 'RO/LR',
      'East' => 'LR/ro',
      'ESE' => 'LR',
      'SE' => 'LI/lr',
      'SSE' => 'LI',
      'South' => 'CI',
      'SSW' => 'RI',
      'SW' => 'RI',
      'WSW' => 'RI/RL',
      'West' => 'RL/ri',
      'WNW' => 'RL/lo',
      'NW' => 'LO/rl',
      'NNW' => 'LO'
    ],
    'PIT' => Hash[
      'North' => 'RI/rl',
      'NNE' => 'RL/RI',
      'NE' => 'RL/lo',
      'ENE' => 'LO/rl',
      'East' => 'LO',
      'ESE' => 'LO',
      'SE' => 'CO',
      'SSE' => 'RO',
      'South' => 'RO/lr',
      'SSW' => 'RO/lr',
      'SW' => 'LR',
      'WSW' => 'LI/LR',
      'West' => 'LI',
      'WNW' => 'LI',
      'NW' => 'CI',
      'NNW' => 'RI'
    ],
    'SDP' => Hash[
      'North' => 'CO',
      'NNE' => 'RO',
      'NE' => 'RO/lr',
      'ENE' => 'RO/LR',
      'East' => 'LR/li',
      'ESE' => 'LR/LI',
      'SE' => 'LI',
      'SSE' => 'LI',
      'South' => 'CI',
      'SSW' => 'RI',
      'SW' => 'RI/rl',
      'WSW' => 'RI/RL',
      'West' => 'RL/lo',
      'WNW' => 'RL/LO',
      'NW' => 'LO/rl',
      'NNW' => 'LO'
    ],
    'SFG' => Hash[
      'North' => 'CO',
      'NNE' => 'RO',
      'NE' => 'RO/lr',
      'ENE' => 'RO/LR',
      'East' => 'LR/li',
      'ESE' => 'LR/LI',
      'SE' => 'LI',
      'SSE' => 'LI',
      'South' => 'CI',
      'SSW' => 'RI',
      'SW' => 'RI/rl',
      'WSW' => 'RI/RL',
      'West' => 'RL/lo',
      'WNW' => 'RL/LO',
      'NW' => 'LO/rl',
      'NNW' => 'LO'
    ],
    'SEA' => Hash[
      'North' => 'RL',
      'NNE' => 'RL/lo',
      'NE' => 'LO',
      'ENE' => 'LO',
      'East' => 'CO',
      'ESE' => 'RO',
      'SE' => 'RO',
      'SSE' => 'RO/LR',
      'South' => 'LR',
      'SSW' => 'LI/LR',
      'SW' => 'LI',
      'WSW' => 'LI',
      'West' => 'CI',
      'WNW' => 'RI',
      'NW' => 'RI',
      'NNW' => 'RI/RL'
    ],
    'STL' => Hash[
      'North' => 'LO/rl',
      'NNE' => 'LO',
      'NE' => 'LO/co',
      'ENE' => 'RO/co',
      'East' => 'RO',
      'ESE' => 'RO/LR',
      'SE' => 'LR',
      'SSE' => 'LR/LI',
      'South' => 'LI/lr',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI/CI',
      'West' => 'RI',
      'WNW' => 'RI/RL',
      'NW' => 'RL/RI',
      'NNW' => 'RL/LO'
    ],
    'TEX' => Hash[
      'North' => 'LO/rl',
      'NNE' => 'LO',
      'NE' => 'LO/co',
      'ENE' => 'RO/co',
      'East' => 'RO',
      'ESE' => 'RO/LR',
      'SE' => 'LR',
      'SSE' => 'LR/LI',
      'South' => 'LI/lr',
      'SSW' => 'LI',
      'SW' => 'CI',
      'WSW' => 'RI/CI',
      'West' => 'RI',
      'WNW' => 'RI/RL',
      'NW' => 'RL/RI',
      'NNW' => 'RL/LO'
    ],
    'TOR' => Hash[
      'North' => 'CO',
      'NNE' => 'RO',
      'NE' => 'RO',
      'ENE' => 'RL/lr',
      'East' => 'LR',
      'ESE' => 'LR/LI',
      'SE' => 'LI',
      'SSE' => 'LI',
      'South' => 'CI',
      'SSW' => 'RI',
      'SW' => 'RI',
      'WSW' => 'RI/RL',
      'West' => 'RL',
      'WNW' => 'RL/LO',
      'NW' => 'LO',
      'NNW' => 'LO'
    ],
    'WSN' => Hash[
      'North' => 'LO',
      'NNE' => 'LO/co',
      'NE' => 'CO/ro',
      'ENE' => 'RO',
      'East' => 'RO/LR',
      'ESE' => 'LR/ro',
      'SE' => 'LR',
      'SSE' => 'LI/LR',
      'South' => 'LI',
      'SSW' => 'LI/CO',
      'SW' => 'RI',
      'WSW' => 'RI',
      'West' => 'RI/RL',
      'WNW' => 'RL/ri',
      'NW' => 'RL/lo',
      'NNW' => 'LO/rl'
    ]
  ]
end
