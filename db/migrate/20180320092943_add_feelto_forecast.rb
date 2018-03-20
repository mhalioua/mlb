class AddFeeltoForecast < ActiveRecord::Migration[5.1]
  def change
  	add_column :weathers, :feel, :string
  end
end
