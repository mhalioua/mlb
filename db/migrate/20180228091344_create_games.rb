class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.belongs_to :game_day
      t.references :away_team
      t.references :home_team

      t.string :away_money_line
      t.string :home_money_line
      t.string :away_total
      t.string :home_total

      t.integer :game_id
      t.string :game_date

      t.string :ump
      t.timestamps
    end
  end
end
