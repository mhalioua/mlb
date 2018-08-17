class CreatePitcherinformations < ActiveRecord::Migration[5.1]
  def change
    create_table :pitcherinformations do |t|
      t.belongs_to :game, index: true
      t.boolean    :away

      t.string     :ip_two
      t.string     :ip_three
      t.string     :gb_two
      t.string     :gb_three
      t.string     :woba_two
      t.string     :woba_three
      t.string     :fip_two
      t.string     :fip_three
      t.string     :tld_two
      t.string     :tld_three
      t.string     :game_one_blue
      t.string     :game_one_blue_opp
      t.string     :game_two_blue
      t.string     :game_two_blue_opp
      t.string     :game_six_blue
      t.string     :game_six_blue_opp
      t.string     :game_three_blue
      t.string     :game_three_blue_opp
      t.string     :game_four_blue
      t.string     :game_four_blue_opp
      t.string     :game_five_blue
      t.string     :game_five_blue_opp
      t.string     :game_seven_blue
      t.string     :game_seven_blue_opp
      t.string     :sb_two
      t.string     :ab_two
      t.string     :sb_three
      t.string     :ab_three
      t.string     :game_wrc_qu_one
      t.string     :game_wrc_qu_one_opp
      t.string     :game_wrc_qu_two
      t.string     :game_wrc_qu_two_opp
      t.string     :game_wrc_qu_three
      t.string     :game_wrc_qu_three_opp
      t.string     :so_ab_two
      t.string     :so_ab_two_opp
      t.string     :so_ab_three
      t.string     :so_ab_three_opp
      t.string     :ab_bb_two
      t.string     :ab_bb_two_opp
      t.string     :ab_bb_three
      t.string     :ab_bb_three_opp
      t.string     :tld_hitter_one
      t.string     :tld_hitter_two
      t.string     :tld_hitter_three

      t.timestamps
    end
  end
end
