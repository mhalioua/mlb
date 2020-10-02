class AddStadiumTeamToGame < ActiveRecord::Migration[5.1]
  def change
    add_reference :games, :stadium_team, foreign_key: true
  end
end