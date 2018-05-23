class ChangeTotalType < ActiveRecord::Migration[5.1]
  def change
  	change_column :prevgames, :away, :float
  	change_column :prevgames, :home, :float
  	change_column :prevgames, :total, :float
  end
end
