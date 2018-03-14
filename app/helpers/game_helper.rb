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
end
