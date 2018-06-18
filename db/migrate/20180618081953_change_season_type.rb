class ChangeSeasonType < ActiveRecord::Migration[5.1]
  def change
  	change_column :scouts, :season, :string
  end
end
