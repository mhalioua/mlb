module GameHelper

  def add_innings(ip_array)
    sum = 0
    decimal = 0
    ip_array.each do |i|
      decimal += (i.to_f - i.to_i)
      sum += i.to_i
    end
    thirds = (decimal*10).round
    sum += thirds/3
    return sum += (thirds%3).to_f/10
  end

  def weather_time(game_date, hour)
    (DateTime.parse(game_date) + (hour - 1).hours).strftime("%I:%M%p")
  end

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

  def wind_validation(wind)
    if wind === 'N'
      return 'North'
    elsif wind === 'E'
      return 'East'
    elsif wind === 'W'
      return 'West'
    elsif wind === 'S'
      return 'South'
    else
      return wind
    end
  end

  def wind_data(name, first_wind, second_wind, third_wind, additional)
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

    search_string.push('"Home_Team" = ' + "'#{name}'")
    wind = get_wind('average runs in this stadium', search_string, 0)
    winds.push(wind)

    search_string.push('"N" >= 1 AND "N" <= 5')
    wind = get_wind('average runs in this stadium with 1-5mph winds', search_string, 0)
    winds.push(wind)

    first_wind_speed, second_wind_speed = swap(first_wind_speed, second_wind_speed) if first_wind_speed > second_wind_speed
    first_wind_speed, third_wind_speed = swap(first_wind_speed, third_wind_speed) if first_wind_speed > third_wind_speed
    second_wind_speed, third_wind_speed = swap(second_wind_speed, third_wind_speed) if second_wind_speed > third_wind_speed

    avg = ((first_wind_speed + second_wind_speed + third_wind_speed) / 3.to_f).ceil
    filter_min = avg - 3
    filter_max = avg + 4

    if (third_wind_speed - first_wind_speed) >= 8
      filter_min = first_wind_speed
      filter_max = third_wind_speed
    elsif first_wind_speed >= 10
      filter_min = avg - 4
    elsif third_wind_speed <= 7
      filter_min = avg - 2
      filter_max = avg + 3
    end

    filter_min = filter_min + additional
    filter_max = filter_max + additional

    wind_directions = ["NNW", "North", "NNE", "NE", "ENE", "East", "ESE", "SE", "SSE", "South", "SSW", "SW", "WSW", "West", "WNW", "NW"]
    currect_directions = []
    real_directions = []
    first_wind_dir = wind_validation(first_wind_dir)
    second_wind_dir = wind_validation(second_wind_dir)
    third_wind_dir = wind_validation(third_wind_dir)

    if wind_directions.include?(first_wind_dir)
      index = wind_directions.index(first_wind_dir)
      currect_directions.push((index+15)%16)
      currect_directions.push(index)
      real_directions.push(index)
      currect_directions.push((index+1)%16)
    end

    if wind_directions.include?(second_wind_dir)
      index = wind_directions.index(second_wind_dir)
      currect_directions.push((index+15)%16)
      currect_directions.push(index)
      real_directions.push(index)
      currect_directions.push((index+1)%16)
    end

    if wind_directions.include?(third_wind_dir)
      index = wind_directions.index(third_wind_dir)
      currect_directions.push((index+15)%16)
      currect_directions.push(index)
      real_directions.push(index)
      currect_directions.push((index+1)%16)
    end

    currect_directions = currect_directions.uniq

    search_string = []
    if name == 'Rockies'
      search_string.push('"table" = ' + "'colowind'")
    else
      search_string.push('"table" = ' + "'wind'")
    end
    search_string.push('"Home_Team" = ' + "'#{name}'")
    search_string.push('"N" >= ' + "#{filter_min}" + ' AND "N" <= ' + "#{filter_max}")

    search_string_original = search_string.dup
    wind = get_wind("average runs in this stadium with #{filter_min}-#{filter_max}mph winds", search_string, 1)
    winds.push(wind)

    directions = [ 'North', 'NNE', 'NE', 'ENE', 'East', 'ESE', 'SE', 'SSE', 'South', 'SSW', 'SW', 'WSW', 'West', 'WNW', 'NW', 'NNW']
    parks = ['ARI', 'ATL', 'BAL', 'BOS', 'CHC', 'CHW', 'CIN', 'CLE', 'COL', 'DET', 'HOU', 'KCR', 'LAA', 'LAD', 'MIA', 'MIL', 'MIN', 'NYM', 'NYY', 'OAK', 'PHI', 'PIT', 'SDP', 'SFG', 'SEA', 'STL', 'TEX', 'TOR', 'WSN']

    wind_directions.each_with_index do |direction, index|
      search_string = search_string_original.dup
      search_string.push('"M" = ' + "'#{direction}'")

      additional_wind = ''
      team = Team.find_by(name: name)
      if directions.include?(direction) && parks.include?(team.baseball_abbr)
        additional_wind =  @@re[team.baseball_abbr][direction]
      end

      flag = 2
      if real_directions.include?(index)
        flag = 1
      elsif currect_directions.include?(index)
        flag = 0
      end

      wind = get_wind("average runs in this stadium with #{filter_min}-#{filter_max}mph, going #{direction} (#{additional_wind})", search_string, flag)
      winds.push(wind)
    end
    return winds
  end

  def wind_data_prev(name, first_wind, second_wind, third_wind)
    first_wind_speed, first_wind_dir = split_wind(first_wind)
    second_wind_speed, second_wind_dir = split_wind(second_wind)
    third_wind_speed, third_wind_dir = split_wind(third_wind)

    search_string = []
    winds = []

    search_string.push('"Home_Team" = ' + "'#{name}'")
    wind = get_wind('average runs in this stadium', search_string, 0)
    winds.push(wind)

    search_string.push('"N" >= 1 AND "N" <= 5')
    wind = get_wind('average runs in this stadium with 1-5mph winds', search_string, 0)
    winds.push(wind)

    first_wind_speed, second_wind_speed = swap(first_wind_speed, second_wind_speed) if first_wind_speed > second_wind_speed
    first_wind_speed, third_wind_speed = swap(first_wind_speed, third_wind_speed) if first_wind_speed > third_wind_speed
    second_wind_speed, third_wind_speed = swap(second_wind_speed, third_wind_speed) if second_wind_speed > third_wind_speed

    avg = ((first_wind_speed + second_wind_speed + third_wind_speed) / 3.to_f).ceil
    filter_min = avg - 3
    filter_max = avg + 4

    if (third_wind_speed - first_wind_speed) >= 8
      filter_min = first_wind_speed
      filter_max = third_wind_speed
    elsif first_wind_speed >= 10
      filter_min = avg - 4
    elsif third_wind_speed <= 7
      filter_min = avg - 2
      filter_max = avg + 3
    end

    wind_directions = ["NNW", "North", "NNE", "NE", "ENE", "East", "ESE", "SE", "SSE", "South", "SSW", "SW", "WSW", "West", "WNW", "NW"]
    currect_directions = []
    real_directions = []
    first_wind_dir = wind_validation(first_wind_dir)
    second_wind_dir = wind_validation(second_wind_dir)
    third_wind_dir = wind_validation(third_wind_dir)

    if wind_directions.include?(first_wind_dir)
      index = wind_directions.index(first_wind_dir)
      currect_directions.push(index-1)
      currect_directions.push(index)
      real_directions.push(index)
      currect_directions.push((index+1)%16)
    end

    if wind_directions.include?(second_wind_dir)
      index = wind_directions.index(second_wind_dir)
      currect_directions.push(index-1)
      currect_directions.push(index)
      real_directions.push(index)
      currect_directions.push((index+1)%16)
    end

    if wind_directions.include?(third_wind_dir)
      index = wind_directions.index(third_wind_dir)
      currect_directions.push(index-1)
      currect_directions.push(index)
      real_directions.push(index)
      currect_directions.push((index+1)%16)
    end

    currect_directions = currect_directions.uniq

    search_string = []
    search_string.push('"Home_Team" = ' + "'#{name}'")
    search_string.push('"N" >= ' + "#{filter_min}" + ' AND "N" <= ' + "#{filter_max}")

    search_string_original = search_string.dup
    wind = get_wind("average runs in this stadium with #{filter_min}-#{filter_max}mph winds", search_string, 1)
    winds.push(wind)

    directions = [ 'North', 'NNE', 'NE', 'ENE', 'East', 'ESE', 'SE', 'SSE', 'South', 'SSW', 'SW', 'WSW', 'West', 'WNW', 'NW', 'NNW']
    parks = ['ARI', 'ATL', 'BAL', 'BOS', 'CHC', 'CHW', 'CIN', 'CLE', 'COL', 'DET', 'HOU', 'KCR', 'LAA', 'LAD', 'MIA', 'MIL', 'MIN', 'NYM', 'NYY', 'OAK', 'PHI', 'PIT', 'SDP', 'SFG', 'SEA', 'STL', 'TEX', 'TOR', 'WSN']

    wind_directions.each_with_index do |direction, index|
      search_string = search_string_original.dup
      search_string.push('"M" = ' + "'#{direction}'")

      additional_wind = ''
      team = Team.find_by(name: name)
      if directions.include?(direction) && parks.include?(team.baseball_abbr)
        additional_wind =  @@re[team.baseball_abbr][direction]
      end

      flag = 2
      if real_directions.include?(index)
        flag = 1
      elsif currect_directions.include?(index)
        flag = 0
      end

      wind = get_wind("average runs in this stadium with #{filter_min}-#{filter_max}mph, going #{direction} (#{additional_wind})", search_string, flag)
      winds.push(wind)
    end
    return winds
  end

  def wind_data_match(name, first_wind, second_wind, third_wind)
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

    search_string.push('"Home_Team" = ' + "'#{name}'")

    query = Workbook.where(search_string.join(" AND ")).to_a
    count = Workbook.where(search_string.join(" AND ")).count(:R)

    wind = [
      'average runs in this stadium',
      (query.map {|stat| stat.R.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      (query.map {|stat| stat.Total_Hits.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      count
    ]
    winds.push(wind)

    first_wind_speed, second_wind_speed = swap(first_wind_speed, second_wind_speed) if first_wind_speed > second_wind_speed
    first_wind_speed, third_wind_speed = swap(first_wind_speed, third_wind_speed) if first_wind_speed > third_wind_speed
    second_wind_speed, third_wind_speed = swap(second_wind_speed, third_wind_speed) if second_wind_speed > third_wind_speed

    avg = ((first_wind_speed + second_wind_speed + third_wind_speed) / 3.to_f).ceil
    filter_min = avg - 3
    filter_max = avg + 4

    if (third_wind_speed - first_wind_speed) >= 8
      filter_min = first_wind_speed
      filter_max = third_wind_speed
    elsif first_wind_speed >= 10
      filter_min = avg - 4
    elsif third_wind_speed <= 7
      filter_min = avg - 2
      filter_max = avg + 3
    end

    currect_directions = []
    first_wind_dir = wind_validation(first_wind_dir)
    second_wind_dir = wind_validation(second_wind_dir)
    third_wind_dir = wind_validation(third_wind_dir)

    currect_directions.push(first_wind_dir)
    currect_directions.push(second_wind_dir)
    currect_directions.push(third_wind_dir)

    search_string.push('"N" >= ' + "#{filter_min}" + ' AND "N" <= ' + "#{filter_max}")

    search_string_original = search_string.dup
    query = Workbook.where(search_string.join(" AND ")).to_a
    count = Workbook.where(search_string.join(" AND ")).count(:R)
    wind = [
      "average runs in this stadium with #{filter_min}-#{filter_max}mph winds",
      (query.map {|stat| stat.R.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      (query.map {|stat| stat.Total_Hits.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      count
    ]
    winds.push(wind)

    currect_directions.each_with_index do |direction, index|
      search_string = search_string_original.dup
      search_string.push('"M" = ' + "'#{direction}'")
      query = Workbook.where(search_string.join(" AND ")).to_a
      count = Workbook.where(search_string.join(" AND ")).count(:R)
      wind = [
        "average runs in this stadium with #{filter_min}-#{filter_max}mph, going #{direction}",
        (query.map {|stat| stat.R.to_f }.sum / (count == 0 ? 1 : count)).round(2),
        (query.map {|stat| stat.Total_Hits.to_f }.sum / (count == 0 ? 1 : count)).round(2),
        count
      ]
      winds.push(wind)
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
    query = Workbook.where(search_string.join(" AND ")).to_a
    count = Workbook.where(search_string.join(" AND ")).count(:R)
    line_count = Workbook.where(search_string.join(" AND ")).count(:total_line)

    return [
      header_string,
      (query.map {|stat| stat.R.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      (query.map {|stat| stat.Total_Hits.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      count,
      (query.map {|stat| stat.Total_Walks.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      (query.map {|stat| stat.home_runs.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      flag,
      (query.map {|stat| stat.total_line.to_f }.sum / (line_count == 0 ? 1 : line_count)).round(2),
      (query.map {|stat| stat.t_HITS.to_f }.sum / (count == 0 ? 1 : count)).round(2),
      (query.map {|stat| stat.t_HRS.to_f }.sum / (count == 0 ? 1 : count)).round(2)
    ]
  end

  def table_type(name)
    search_string = []
    if name == 'Astros'
      search_string.push('"table" = ' + "'houston'")
    elsif name == 'Rays'
      search_string.push('"table" = ' + "'tampa'")
    elsif name == 'Rockies'
      search_string.push('"table" = ' + "'colo'")
    else
      search_string.push('"table" = ' + "'Workbook'")
    end
    return search_string
  end

  def total_data(name)
    search_string = table_type(name)
    result = {}
    search_string_all = search_string.dup
    search_string_all.push('"total_line" is not null ')

    query = Workbook.where(search_string_all.join(" AND "))

    result[:total_avg_1] = query.average(:R).to_f.round(2)
    result[:total_avg_2] = query.average(:Total_Hits).to_f.round(2)
    result[:total_hits_avg] = query.average(:Total_Walks).to_f.round(2)
    result[:home_runs_avg] = query.average(:home_runs).to_f.round(2)

    search_string_dup = search_string.dup

    if name != ""
      search_string.push('"Home_Team" = ' + "'#{name}'")
      search_string_dup.push('"Home_Team" != ' + "'#{name}'")
    end

    query = Workbook.where(search_string.join(" AND "))

    result[:home_total_runs1_avg] = query.average(:R).to_f.round(2)
    result[:home_total_runs2_avg] = query.average(:Total_Hits).to_f.round(2)
    result[:total_hits_park_avg] = query.average(:Total_Walks).to_f.round(2)
    result[:total_hr_park] = query.average(:home_runs).to_f.round(2)

    query = Workbook.where(search_string_dup.join(" AND "))

    result[:home_total_runs1_avg_dup] = query.average(:R).to_f.round(2)
    result[:home_total_runs2_avg_dup] = query.average(:Total_Hits).to_f.round(2)
    result[:total_hits_park_avg_dup] = query.average(:Total_Walks).to_f.round(2)
    result[:total_hr_park_dup] = query.average(:home_runs).to_f.round(2)

    return result
  end

  def true_data(temp_min, temp_max, dew_min, dew_max, humid_min, humid_max, baro_min, baro_max, wind_min, wind_max, wind_dir1, wind_dir2, name)
    search_string = table_type(name)
    search_string_low = table_type(name)
    result = {}
    if temp_max != -1
      search_string.push('"TEMP" >= ' + "'#{temp_min}'" + ' AND "TEMP" <= ' + "'#{temp_max}'")
      search_string_low.push('"TEMP" >= ' + "'#{temp_min}'" + ' AND "TEMP" <= ' + "'#{temp_max}'")
    end
    if dew_max != -1
      search_string.push('"DP" >= ' + "'#{dew_min}'" + ' AND "DP" <= ' + "'#{dew_max}'")
      search_string_low.push('"DP" >= ' + "'#{dew_min + 1}'" + ' AND "DP" <= ' + "'#{dew_max - 1}'")
    end
    if humid_max != -1
      search_string.push('"HUMID" >= ' + "'#{humid_min}'" + ' AND "HUMID" <= ' + "'#{humid_max}'")
      search_string_low.push('"HUMID" >= ' + "'#{humid_min}'" + ' AND "HUMID" <= ' + "'#{humid_max}'")
    end
    if baro_max != -1
      search_string.push('"BARo" >= ' + "'#{baro_min}'" + ' AND "BARo" <= ' + "'#{baro_max}'")
      search_string_low.push('"BARo" >= ' + "'#{baro_min}'" + ' AND "BARo" <= ' + "'#{baro_max}'")
    end

    search_string_all = search_string.dup
    search_string_all.push('"total_line" is not null ')

    query = Workbook.where(search_string_all.join(" AND ")).to_a
    temp_count = query.count

    result[:total_count] = temp_count
    result[:total_avg_1] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_avg_2] = (query.map {|stat| stat.Total_Hits.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_hits_avg] = (query.map {|stat| stat.Total_Walks.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_runs_avg] = (query.map {|stat| stat.home_runs.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_lines_avg] = (query.map {|stat| stat.total_line.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:t_HITS_avg] = (query.map {|stat| stat.t_HITS.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:t_HRS_avg] = (query.map {|stat| stat.t_HRS.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:first_count] = query.select {|stat| stat.R.to_i < 9}.count
    result[:second_count] = query.select {|stat| stat.R.to_i == 9}.count
    result[:third_count] = query.select {|stat| stat.R.to_i > 9}.count

    search_string_low_all = search_string_low.dup
    search_string_low_all.push('"total_line" is not null ')

    query = Workbook.where(search_string_low_all.join(" AND ")).to_a
    temp_count = query.count

    result[:lower_one] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:lower_one_count] = temp_count

    search_string_dup = search_string.dup
    search_string_low_dup = search_string_low.dup
    search_string_wind = search_string.dup
    search_string_low_wind = search_string_low.dup

    if name != ""
      search_string_wind.push('"M" IN ' + "('#{wind_dir1}', '#{wind_dir2}')")
      search_string_low_wind.push('"M" IN ' + "('#{wind_dir1}', '#{wind_dir2}')")
      search_string_wind.push('"N" >= ' + "#{wind_min}" + ' AND "N" <= ' + "#{wind_max}")
      search_string_low_wind.push('"N" >= ' + "#{wind_min}" + ' AND "N" <= ' + "#{wind_max}")

      search_string.push('"Home_Team" = ' + "'#{name}'")
      search_string_low.push('"Home_Team" = ' + "'#{name}'")
      search_string_wind.push('"Home_Team" = ' + "'#{name}'")
      search_string_low_wind.push('"Home_Team" = ' + "'#{name}'")
      search_string_dup.push('"Home_Team" != ' + "'#{name}'")
      search_string_low_dup.push('"Home_Team" != ' + "'#{name}'")
    end

    query = Workbook.where(search_string.join(" AND ")).to_a
    temp_count = query.count
    lines_count = query.count{|x| x.total_line != nil}

    result[:home_total_runs1_avg] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_total_runs2_avg] = (query.map {|stat| stat.Total_Hits.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_hits_park_avg] = (query.map {|stat| stat.Total_Walks.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_hr_park] = (query.map {|stat| stat.home_runs.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_count] = temp_count
    result[:total_lines_park_avg] = (query.map {|stat| stat.total_line.to_f }.sum / (lines_count == 0 ? 1 : lines_count)).round(2)

    query = Workbook.where(search_string_low.join(" AND ")).to_a
    temp_count = query.count

    result[:home_one] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_one_count] = temp_count

    query = Workbook.where(search_string_wind.join(" AND ")).to_a
    temp_count = query.count
    lines_count = query.count{|x| x.total_line != nil}

    result[:home_total_runs1_avg_wind] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_total_runs2_avg_wind] = (query.map {|stat| stat.Total_Hits.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_hits_park_avg_wind] = (query.map {|stat| stat.Total_Walks.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_hr_park_wind] = (query.map {|stat| stat.home_runs.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_count_wind] = temp_count
    result[:total_lines_park_avg_wind] = (query.map {|stat| stat.total_line.to_f }.sum / (lines_count == 0 ? 1 : lines_count)).round(2)

    query = Workbook.where(search_string_low_wind.join(" AND ")).to_a
    temp_count = query.count

    result[:home_one_wind] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_one_count_wind] = temp_count

    query = Workbook.where(search_string_dup.join(" AND ")).to_a
    temp_count_dup = query.count
    lines_count_dup = query.count{|x| x.total_line != nil}

    result[:home_total_runs1_avg_dup] = (query.map {|stat| stat.R.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:home_total_runs2_avg_dup] = (query.map {|stat| stat.Total_Hits.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:total_hits_park_avg_dup] = (query.map {|stat| stat.Total_Walks.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:total_hr_park_dup] = (query.map {|stat| stat.home_runs.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:home_count_dup] = temp_count_dup
    result[:total_lines_park_avg_dup] = (query.map {|stat| stat.total_line.to_f }.sum / (lines_count_dup == 0 ? 1 : lines_count_dup)).round(2)

    query = Workbook.where(search_string_low_dup.join(" AND ")).to_a
    temp_count_dup = query.count

    result[:home_one_dup] = (query.map {|stat| stat.R.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:home_one_count_dup] = temp_count_dup

    return result
  end

  def true_data_prev(temp_min, temp_max, dew_min, dew_max, humid_min, humid_max, baro_min, baro_max, wind_min, wind_max, wind_dir1, wind_dir2, name)
    search_string = []
    search_string_low = []
    result = {}
    if temp_max != -1
      search_string.push('"TEMP" >= ' + "'#{temp_min}'" + ' AND "TEMP" <= ' + "'#{temp_max}'")
      search_string_low.push('"TEMP" >= ' + "'#{temp_min}'" + ' AND "TEMP" <= ' + "'#{temp_max}'")
    end
    if dew_max != -1
      search_string.push('"DP" >= ' + "'#{dew_min}'" + ' AND "DP" <= ' + "'#{dew_max}'")
      search_string_low.push('"DP" >= ' + "'#{dew_min + 1}'" + ' AND "DP" <= ' + "'#{dew_max - 1}'")
    end
    if humid_max != -1
      search_string.push('"humid" >= ' + "'#{humid_min}'" + ' AND "humid" <= ' + "'#{humid_max}'")
      search_string_low.push('"humid" >= ' + "'#{humid_min}'" + ' AND "humid" <= ' + "'#{humid_max}'")
    end
    if baro_max != -1
      search_string.push('"BARO" >= ' + "'#{baro_min}'" + ' AND "BARO" <= ' + "'#{baro_max}'")
      search_string_low.push('"BARO" >= ' + "'#{baro_min}'" + ' AND "BARO" <= ' + "'#{baro_max}'")
    end

    search_string_all = search_string.dup
    search_string_all.push('"total_line" is not null ')

    query = Prevgame.where(search_string_all.join(" AND ")).to_a
    temp_count = query.count

    result[:total_count] = temp_count
    result[:total_avg_1] = (query.map {|stat| stat.total.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_avg_2] = ''
    result[:total_hits_avg] = (query.map {|stat| stat.total_hits_both_team.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_runs_avg] = (query.map {|stat| stat.total_home_runs_both_team.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_lines_avg] = (query.map {|stat| stat.total_line.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)

    search_string_low_all = search_string_low.dup
    search_string_low_all.push('"total_line" is not null ')

    query = Prevgame.where(search_string_low_all.join(" AND ")).to_a
    temp_count = query.count

    result[:lower_one] = (query.map {|stat| stat.total.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:lower_one_count] = temp_count

    search_string_dup = search_string.dup
    search_string_low_dup = search_string_low.dup

    search_string_wind = search_string.dup
    search_string_low_wind = search_string_low.dup

    wind_dir1 = wind_validation(wind_dir1)
    wind_dir2 = wind_validation(wind_dir2)

    if name != ""
      search_string_wind.push('"M" IN ' + "('#{wind_dir1}', '#{wind_dir2}')")
      search_string_low_wind.push('"M" IN ' + "('#{wind_dir1}', '#{wind_dir2}')")
      search_string_wind.push('"N" >= ' + "#{wind_min}" + ' AND "N" <= ' + "#{wind_max}")
      search_string_low_wind.push('"N" >= ' + "#{wind_min}" + ' AND "N" <= ' + "#{wind_max}")

      search_string_wind.push('"Home_Team" = ' + "'#{name}'")
      search_string_low_wind.push('"Home_Team" = ' + "'#{name}'")
      search_string.push('"Home_Team" = ' + "'#{name}'")
      search_string_low.push('"Home_Team" = ' + "'#{name}'")
      search_string_dup.push('"Home_Team" != ' + "'#{name}'")
      search_string_low_dup.push('"Home_Team" != ' + "'#{name}'")
    end

    query = Prevgame.where(search_string_wind.join(" AND ")).to_a
    temp_count = query.count
    lines_count = query.count{|x| x.total_line != nil}

    result[:home_total_runs1_avg_wind] = (query.map {|stat| stat.total.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_total_runs2_avg_wind] = ''
    result[:total_hits_park_avg_wind] = (query.map {|stat| stat.total_hits_both_team.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_hr_park_wind] = (query.map {|stat| stat.total_home_runs_both_team.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_count_wind] = temp_count
    result[:total_lines_park_avg_wind] = (query.map {|stat| stat.total_line.to_f }.sum / (lines_count == 0 ? 1 : lines_count)).round(2)

    query = Prevgame.where(search_string_low_wind.join(" AND ")).to_a
    temp_count = query.count

    result[:home_one_wind] = (query.map {|stat| stat.total.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_one_count_wind] = temp_count

    query = Prevgame.where(search_string.join(" AND ")).to_a
    temp_count = query.count
    lines_count = query.count{|x| x.total_line != nil}

    result[:home_total_runs1_avg] = (query.map {|stat| stat.total.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_total_runs2_avg] = ''
    result[:total_hits_park_avg] = (query.map {|stat| stat.total_hits_both_team.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_hr_park] = (query.map {|stat| stat.total_home_runs_both_team.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_count] = temp_count
    result[:total_lines_park_avg] = (query.map {|stat| stat.total_line.to_f }.sum / (lines_count == 0 ? 1 : lines_count)).round(2)

    query = Prevgame.where(search_string_low.join(" AND ")).to_a
    temp_count = query.count

    result[:home_one] = (query.map {|stat| stat.total.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_one_count] = temp_count

    query = Prevgame.where(search_string_dup.join(" AND ")).to_a
    temp_count_dup = query.count
    lines_count_dup = query.count{|x| x.total_line != nil}

    result[:home_total_runs1_avg_dup] = (query.map {|stat| stat.total.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:home_total_runs2_avg_dup] = ''
    result[:total_hits_park_avg_dup] = (query.map {|stat| stat.total_hits_both_team.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:total_hr_park_dup] = (query.map {|stat| stat.total_home_runs_both_team.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:home_count_dup] = temp_count_dup
    result[:total_lines_park_avg_dup] = (query.map {|stat| stat.total_line.to_f }.sum / (lines_count_dup == 0 ? 1 : lines_count_dup)).round(2)

    query = Prevgame.where(search_string_low_dup.join(" AND ")).to_a
    temp_count_dup = query.count

    result[:home_one_dup] = (query.map {|stat| stat.total.to_f }.sum / (temp_count_dup == 0 ? 1 : temp_count_dup)).round(2)
    result[:home_one_count_dup] = temp_count_dup
    
    return result
  end

  def true_data_pitcher(temp_min, temp_max, dew_min, dew_max, humid_min, humid_max, baro_min, baro_max, name)
    search_string = table_type(name)
    search_string_low = table_type(name)
    result = {}
    if temp_max != -1
      search_string.push('"TEMP" >= ' + "'#{temp_min}'" + ' AND "TEMP" <= ' + "'#{temp_max}'")
      search_string_low.push('"TEMP" >= ' + "'#{temp_min}'" + ' AND "TEMP" <= ' + "'#{temp_max}'")
    end
    if dew_max != -1
      search_string.push('"DP" >= ' + "'#{dew_min}'" + ' AND "DP" <= ' + "'#{dew_max}'")
      search_string_low.push('"DP" >= ' + "'#{dew_min + 1}'" + ' AND "DP" <= ' + "'#{dew_max - 1}'")
    end
    if humid_max != -1
      search_string.push('"HUMID" >= ' + "'#{humid_min}'" + ' AND "HUMID" <= ' + "'#{humid_max}'")
      search_string_low.push('"HUMID" >= ' + "'#{humid_min}'" + ' AND "HUMID" <= ' + "'#{humid_max}'")
    end
    if baro_max != -1
      search_string.push('"BARo" >= ' + "'#{baro_min}'" + ' AND "BARo" <= ' + "'#{baro_max}'")
      search_string_low.push('"BARo" >= ' + "'#{baro_min}'" + ' AND "BARo" <= ' + "'#{baro_max}'")
    end

    search_string_all = search_string.dup
    search_string_all.push('"total_line" is not null ')

    query = Workbook.where(search_string_all.join(" AND ")).to_a
    temp_count = query.count

    result[:total_count] = temp_count
    result[:total_avg_1] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_avg_2] = (query.map {|stat| stat.Total_Hits.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:total_hits_avg] = (query.map {|stat| stat.Total_Walks.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_runs_avg] = (query.map {|stat| stat.home_runs.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)

    search_string_low_all = search_string_low.dup
    search_string_low_all.push('"total_line" is not null ')

    query = Workbook.where(search_string_low_all.join(" AND ")).to_a
    temp_count = query.count

    result[:lower_one] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:lower_one_count] = temp_count

    if name != ""
      search_string.push('"Home_Team" = ' + "'#{name}'")
      search_string_low.push('"Home_Team" = ' + "'#{name}'")
    end

    query = Workbook.where(search_string.join(" AND ")).to_a
    temp_count = query.count

    result[:home_total_runs1_avg] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_total_runs2_avg] = (query.map {|stat| stat.Total_Hits.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_count] = temp_count

    query = Workbook.where(search_string_low.join(" AND ")).to_a
    temp_count = query.count

    result[:home_one] = (query.map {|stat| stat.R.to_f }.sum / (temp_count == 0 ? 1 : temp_count)).round(2)
    result[:home_one_count] = temp_count

    return result
  end

  def prev_data(name)
    result = {}
    query = Prevgame.where('"total_line" is not null ')

    result[:total_avg_1] = query.average(:total).to_f.round(2)
    result[:total_avg_2] = ''
    result[:total_hits_avg] = query.average(:total_hits_both_team).to_f.round(2)
    result[:home_runs_avg] = query.average(:total_home_runs_both_team).to_f.round(2)

    query = Prevgame.where('"Home_Team" = ' + "'#{name}'")

    result[:home_total_runs1_avg] = query.average(:total).to_f.round(2)
    result[:home_total_runs2_avg] = ''
    result[:total_hits_park_avg] = query.average(:total_hits_both_team).to_f.round(2)
    result[:total_hr_park] = query.average(:total_home_runs_both_team).to_f.round(2)

    query = Prevgame.where('"Home_Team" != ' + "'#{name}'")

    result[:home_total_runs1_avg_dup] = query.average(:total).to_f.round(2)
    result[:home_total_runs2_avg_dup] = ''
    result[:total_hits_park_avg_dup] = query.average(:total_hits_both_team).to_f.round(2)
    result[:total_hr_park_dup] = query.average(:total_home_runs_both_team).to_f.round(2)

    return result
  end

  def d2_calc(park, direction)
    directions = [ 'North', 'NNE', 'NE', 'ENE', 'East', 'ESE', 'SE', 'SSE', 'South', 'SSW', 'SW', 'WSW', 'West', 'WNW', 'NW', 'NNW']
    parks = ['ARI', 'ATL', 'BAL', 'BOS', 'CHC', 'CHW', 'CIN', 'CLE', 'COL', 'DET', 'HOU', 'KCR', 'LAA', 'LAD', 'MIA', 'MIL', 'MIN', 'NYM', 'NYY', 'OAK', 'PHI', 'PIT', 'SDP', 'SFG', 'SEA', 'STL', 'TEX', 'TOR', 'WSN']
    
    if directions.include?(direction) && parks.include?(park)
      return @@re[park][direction]
    else
      return ''
    end
  end

  def lr_filter(min, max, direction, name)
    search_string = []
    search_string.push('"Home_Team" = ' + "'#{name}'")
    search_string.push('"Direction" = ' + "'#{direction}'")
    search_string.push('"Speed" >= ' + "'#{min}'")
    result = {}
    if max != 0
      search_string.push('"Speed" <= ' + "'#{max}'")
    end
    query = Newworkbook.where(search_string.join(" AND ")).to_a
    result[:ll_ab] = query.sum(:ll_ab)
    result[:ll_h]  = query.sum(:ll_h)
    result[:ll_bb] = query.sum(:ll_bb)
    result[:ll_hr] = query.sum(:ll_hr)
    result[:lr_ab] = query.sum(:lr_ab)
    result[:lr_h]  = query.sum(:lr_h)
    result[:lr_bb] = query.sum(:lr_bb)
    result[:lr_hr] = query.sum(:lr_hr)
    result[:rl_ab] = query.sum(:rl_ab)
    result[:rl_h]  = query.sum(:rl_h)
    result[:rl_bb] = query.sum(:rl_bb)
    result[:rl_hr] = query.sum(:rl_hr)
    result[:rr_ab] = query.sum(:rr_ab)
    result[:rr_h]  = query.sum(:rr_h)
    result[:rr_bb] = query.sum(:rr_bb)
    result[:rr_hr] = query.sum(:rr_hr)
    return result
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
    'SEA' => Hash[
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
      'North' => 'RI',
      'NNE' => 'RL/RI',
      'NE' => 'RL',
      'ENE' => 'RL/LO',
      'East' => 'LO',
      'ESE' => 'LO',
      'SE' => 'CO',
      'SSE' => 'RO',
      'South' => 'RO',
      'SSW' => 'RO/LR',
      'SW' => 'LR',
      'WSW' => 'LR/LI',
      'West' => 'LI',
      'WNW' => 'LI',
      'NW' => 'CI',
      'NNW' => 'RI'
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
      'SSW' => 'LI/CI',
      'SW' => 'RI',
      'WSW' => 'RI',
      'West' => 'RI/RL',
      'WNW' => 'RL/ri',
      'NW' => 'RL/lo',
      'NNW' => 'LO/rl'
    ]
  ]
end
