class AddMlbIdToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :mlb_id, :string
  end
end
