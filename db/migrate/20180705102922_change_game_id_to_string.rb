class ChangeGameIdToString < ActiveRecord::Migration[5.1]
  def change
    change_column :weather_firsts, :game_id, :string
  end
end
