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
end
