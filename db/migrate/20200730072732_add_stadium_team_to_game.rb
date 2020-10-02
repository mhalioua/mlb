class AddStadiumTeamToGame < ActiveRecord::Migration[5.1]
  def change
    add_reference :games, :stadium_team, index: true
  end
end