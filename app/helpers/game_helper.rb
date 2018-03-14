module GameHelper
  def batter_class(predicted)
    if predicted
      "predicted batter"
    else
      "batter"
    end
  end
end
