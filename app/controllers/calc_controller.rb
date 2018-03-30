class CalcController < ApplicationController
  include CalcHelper
  require 'date'

  def input
    @post = params
    @teams = Team.all
    @team_dropdown = []
    @type_dropdown = []
    @index_dropdown1 = []
    @index_dropdown2 = []
    @wunderground =[]
    @weather = []
    @teams.each do |team|
      team_element = [team.name, team.name]
      @team_dropdown << team_element
    end
    @type_dropdown << [1, 'Wunderground']
    @type_dropdown << [2, 'Weather']
    @team_dropdown = @team_dropdown.sort
    if @post['form_stadium']
      element = @teams.find{|x| x.name == @post['form_stadium'] }
      @wunderground = stadium_weather(element.id)
      @weather = stadium_weather(element.id)
    else
      @wunderground = stadium_weather(1)
      @weather = stadium_weather(1)
    end
    @type = 1
    @stadium = []
    @weathers = []
    @type = @post['type'].to_i if @post['type']
    @wunderground.each_with_index do |weather, index|
      weather_element = [index, weather.time]
      @index_dropdown1 << weather_element
    end
    @weather.each_with_index do |weather, index|
      weather_element = [index, weather.time]
      @index_dropdown1 << weather_element
    end
    @index = 1
    if @type === 1
      @index = @post['index1'] ? @post['index1'] : 0
      @weathers = @wunderground
    else
      @index = @post['index2'] ? @post['index2'] : 0
      @weathers = @weather
    end

    @stadium.push(@weathers[@index])
    if @weathers[@index+1]
      @stadium.push(@weathers[@index+1])
    else
      @stadium.push(@weathers[@index])
    end

    if @weathers[@index+2]
      @stadium.push(@weathers[@index+2])
    else
      @stadium.push(@weathers[@index])
    end

  end
end
