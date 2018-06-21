class CreateWeatherFirsts < ActiveRecord::Migration[5.1]
  def change
    create_table :weather_firsts do |t|
    	t.string :Date
    	t.string :Time
    	t.string :Away_Team
    	t.string :Home_Team
    	t.integer :Away_Money_Line
    	t.integer :Home_Money_Line
    	t.string :D2
    	t.string :Away_Total
    	t.float :TEMP
    	t.float :DP
    	t.integer :HUMID
    	t.float :BARo
    	t.string :Direction
    	t.float :Speed
    	t.float :Average
    	t.integer :Total_Hits
    	t.integer :Total_Walks
    	t.integer :Total_Walks_Hits
    	t.integer :Total_Bases
    	t.integer :Away_Inning_1
    	t.integer :h9
    	t.integer :h8
    	t.integer :h7
    	t.integer :h6
    	t.integer :h5
    	t.string :h4
    	t.string :h3
    	t.string :h2
    	t.string :h1
    	t.string :Home_Inning_1
    	t.integer :a9
    	t.integer :a8
    	t.integer :a7
    	t.integer :a6
    	t.integer :a5
    	t.string :a4
    	t.string :A3
    	t.string :A2
    	t.string :A1
    	t.string :A0
    	t.integer :home_runs
    	t.integer :stolen_bases
    	t.string :Away_Starter_First_Name
    	t.string :Away_Starter_Last_Name
    	t.string :Away_Starter_Handedness
    	t.string :Home_Starter_First_Name
    	t.string :Home_Starter_Last_Name
    	t.string :Home_Starter_Handedness
    	t.float :LD_PA
    	t.float :GB_PA
    	t.float :FB_PA
    	t.float :SO_PA
    	t.float :LD_BABIP
    	t.float :GB_BABIP
    	t.float :FB_BABIP
    	t.integer :game_id
      t.timestamps
    end
  end
end
