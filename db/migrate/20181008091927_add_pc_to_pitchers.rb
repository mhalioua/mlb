class AddPcToPitchers < ActiveRecord::Migration[5.1]
  def change
    add_column :pitchers, :pc, :integer
  end
end
