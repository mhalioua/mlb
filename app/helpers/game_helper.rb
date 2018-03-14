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
end
