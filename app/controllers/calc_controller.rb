class CalcController < ApplicationController
  include CalcHelper
  require 'date'

  def input
    @post = params
    @teams = Team.all
    @team_dropdown = []
    @type_dropdown = []
    @index_dropdown = []
    @wunderground =[]
    @weather = []
    @weathers = []
    @stadium = []
    @teams.each do |team|
      team_element = [team.name, team.name]
      @team_dropdown << team_element
    end
    @team_dropdown = @team_dropdown.sort

    @type_dropdown << ['Wunderground', 1]
    @type_dropdown << ['Weather', 2]

    time = Time.now.hour - 3
    (0...12).each do |index|
      time_format = DateTime.now.change({hour: time})
      weather_element = [time_format.strftime('%I:%M %p'), index]
      @index_dropdown << weather_element
      time = time + 1
    end

    if @post['form_stadium']
      element = @teams.find{|x| x.name == @post['form_stadium'] }
      zipcode = element.zipcode
      zipcode = 'M5V1J1' if element.id == 4
      @wunderground = wunderground_weather(element.zipcode)
      @weather = weather_weather(element.zipcode)
    end

    @type = 1
    @type = @post['type'].to_i if @post['type']

    if @type === 1
      @weathers = @wunderground
    else
      @weathers = @weather
    end

    @index = 0
    @index = @post['index'].to_i if @post['index']

    (0..2).each do |element|
      weather_element = @weathers[@index]
      if @type == 2
        weather_element[:dew] = @wunderground[@index][:dew]
        weather_element[:pressure] = @wunderground[@index][:pressure]
      end
      @stadium.push(@weathers[@index])
      @index = @index + 1 if @weathers[@index+1]
    end
  end
end
