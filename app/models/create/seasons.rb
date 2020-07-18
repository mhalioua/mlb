module Create
  class Seasons
    def create
      2016.upto(2020) do |year|
      	Season.find_or_create_by(year: year)
      end
    end
  end
end