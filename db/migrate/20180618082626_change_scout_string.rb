class ChangeScoutString < ActiveRecord::Migration[5.1]
  def change
  	change_column :scouts, :xba, :string
  	change_column :scouts, :xslg, :string
  	change_column :scouts, :xwoba, :string
  	change_column :scouts, :woba, :string
  end
end
