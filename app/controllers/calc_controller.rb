class CalcController < ApplicationController
  include CalcHelper
  require 'date'

  def input
    @post = params
    @teams = Team.all
    @team_dropdown = []
    @teams.each do |team|
      team_element = [team.name, team.name]
      @team_dropdown << team_element
    end
    @team_dropdown = @team_dropdown.sort
    if @post['authenticity_token']
      if @post['form_stadium']
        element = @teams.find{|x| x.name == @post['form_stadium'] }
        zipcode = element.zipcode
        if element.id == 4
          zipcode = "M5V1J1"
        end
        @stadium = stadium_weather(zipcode)
      end
    end
  end
end
