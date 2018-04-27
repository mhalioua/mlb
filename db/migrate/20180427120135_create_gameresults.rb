class CreateGameresults < ActiveRecord::Migration[5.1]
  def change
    create_table :gameresults do |t|
      t.string  :day
      t.string  :month
      t.string  :year
      t.string  :time
      t.string  :away_team
      t.string  :home_team
      t.string  :away_ml
      t.string  :home_ml
      t.string  :away_total
      t.string  :home_total
      t.string  :first_temp
      t.string  :second_temp
      t.string  :third_temp
      t.string  :first_dp
      t.string  :second_dp
      t.string  :third_dp
      t.string  :first_humid
      t.string  :second_humid
      t.string  :third_humid
      t.string  :first_baro
      t.string  :second_baro
      t.string  :third_baro
      t.string  :first_wind_direction
      t.string  :second_wind_direction
      t.string  :third_wind_direction
      t.string  :first_wind_speed
      t.string  :second_wind_speed
      t.string  :third_wind_speed
      t.string  :away_score_first
      t.string  :away_score_second
      t.string  :away_score_third
      t.string  :away_score_forth
      t.string  :away_score_fifth
      t.string  :away_score_sixth
      t.string  :away_score_seventh
      t.string  :away_score_eighth
      t.string  :away_score_nineth
      t.string  :away_score_tenth
      t.string  :home_score_first
      t.string  :home_score_second
      t.string  :home_score_third
      t.string  :home_score_forth
      t.string  :home_score_fifth
      t.string  :home_score_sixth
      t.string  :home_score_seventh
      t.string  :home_score_eighth
      t.string  :home_score_nineth
      t.string  :home_score_tenth
      t.string  :total_hits_both_team
      t.string  :total_walks_both_team
      t.string  :total_doubles_both_team
      t.string  :total_triples_both_team
      t.string  :total_bases_both_team
      t.string  :away_starter_last_game
      t.string  :away_starter_first_name
      t.string  :away_starter_handedness
      t.string  :home_starter_last_name
      t.string  :home_starter_first_name
      t.string  :home_starter_handedness
      t.string  :filtered_average_one
      t.string  :filtered_average_two

      t.string  :game_id
      t.string  :game_date
      t.string  :home_abbr
      t.string  :away_abbr
      t.string  :stadium

      t.timestamps
    end
  end
end
