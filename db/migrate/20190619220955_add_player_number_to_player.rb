class AddPlayerNumberToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :player_number, :integer
  end
end
