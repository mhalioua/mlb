module Create
  class Seasons
    def create
      2015.upto(2018) do |year|
      	Season.find_or_create_by(year: year)
      end
    end
  end
end