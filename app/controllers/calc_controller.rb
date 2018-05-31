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
    @home_team = nil
    @image_url = ''
    @teams.each do |team|
      team_element = [team.name, team.name]
      @team_dropdown << team_element
    end
    @team_dropdown = @team_dropdown.sort

    @type_dropdown << ['Wunderground', 1]
    @type_dropdown << ['Weather', 2]

    time = Time.now.hour - 3
    (0...12).each do |index|
      time_format = DateTime.now
      if time < 24
        time_format = DateTime.now.change({hour: time})
      else
        time_format = DateTime.now.tomorrow.change({hour: time-24})
      end
      weather_element = [time_format.strftime('%F %I:%M %p'), index]
      @index_dropdown << weather_element
      time = time + 1
    end

    if @post['form_stadium']
      @home_team = @teams.find{|x| x.name == @post['form_stadium'] }
      @wunderground = wunderground_weather(@home_team.zipcode)
      @weather = weather_weather(@home_team.zipcode)
      @image_url = @home_team.id.to_s + ".png"
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

    (0..3).each do |element|
      weather_element = @weathers[@index]
      if @type == 2
        weather_element[:dew] = @wunderground[@index][:dew]
        weather_element[:pressure] = @wunderground[@index][:pressure]
      end
      @stadium.push(@weathers[@index])
      @index = @index + 1 if @weathers[@index+1]
    end
    @index = 0
    @index = @post['index'].to_i if @post['index']
  end
end
