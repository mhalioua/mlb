class AddGameidToNewworkbook < ActiveRecord::Migration[5.1]
  def change
    add_column :newworkbooks, :game_id, :integer
  end
end
