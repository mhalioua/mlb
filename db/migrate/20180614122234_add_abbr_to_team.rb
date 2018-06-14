class AddAbbrToTeam < ActiveRecord::Migration[5.1]
  def change
  	add_column :teams, :mlb_abbr, :string
  end
end
