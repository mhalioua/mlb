class AddStadiumToTeam < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :stadium, :string
  end
end
