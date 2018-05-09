class AddPreviousToResult < ActiveRecord::Migration[5.1]
  def change
    add_column :results, :home_pitcher_game_first_ip, :float
    add_column :results, :home_pitcher_game_first_bb, :integer
    add_column :results, :home_pitcher_game_first_h, :integer
    add_column :results, :home_pitcher_game_first_r, :integer

    add_column :results, :home_pitcher_game_second_ip, :float
    add_column :results, :home_pitcher_game_second_bb, :integer
    add_column :results, :home_pitcher_game_second_h, :integer
    add_column :results, :home_pitcher_game_second_r, :integer

    add_column :results, :home_pitcher_game_opp_first_ip, :float
    add_column :results, :home_pitcher_game_opp_first_bb, :integer
    add_column :results, :home_pitcher_game_opp_first_h, :integer
    add_column :results, :home_pitcher_game_opp_first_r, :integer

    add_column :results, :home_pitcher_game_opp_second_ip, :float
    add_column :results, :home_pitcher_game_opp_second_bb, :integer
    add_column :results, :home_pitcher_game_opp_second_h, :integer
    add_column :results, :home_pitcher_game_opp_second_r, :integer


    add_column :results, :away_pitcher_game_first_ip, :float
    add_column :results, :away_pitcher_game_first_bb, :integer
    add_column :results, :away_pitcher_game_first_h, :integer
    add_column :results, :away_pitcher_game_first_r, :integer

    add_column :results, :away_pitcher_game_second_ip, :float
    add_column :results, :away_pitcher_game_second_bb, :integer
    add_column :results, :away_pitcher_game_second_h, :integer
    add_column :results, :away_pitcher_game_second_r, :integer

    add_column :results, :away_pitcher_game_opp_first_ip, :float
    add_column :results, :away_pitcher_game_opp_first_bb, :integer
    add_column :results, :away_pitcher_game_opp_first_h, :integer
    add_column :results, :away_pitcher_game_opp_first_r, :integer

    add_column :results, :away_pitcher_game_opp_second_ip, :float
    add_column :results, :away_pitcher_game_opp_second_bb, :integer
    add_column :results, :away_pitcher_game_opp_second_h, :integer
    add_column :results, :away_pitcher_game_opp_second_r, :integer
  end
end
