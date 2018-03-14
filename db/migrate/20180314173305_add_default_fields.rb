class AddDefaultFields < ActiveRecord::Migration[5.1]
  def change
  	change_column_default(:batter_stats, :woba, 0)
  	change_column_default(:batter_stats, :ops, 0)
  	change_column_default(:batter_stats, :ab, 0)
  	change_column_default(:batter_stats, :so, 0)
  	change_column_default(:batter_stats, :bb, 0)
  	change_column_default(:batter_stats, :sb, 0)
  	change_column_default(:batter_stats, :fb, 0.0)
  	change_column_default(:batter_stats, :gb, 0.0)
  	change_column_default(:batter_stats, :ld, 0.0)
  	change_column_default(:batter_stats, :wrc, 0)
  	change_column_default(:batter_stats, :obp, 0)
  	change_column_default(:batter_stats, :slg, 0)

  	change_column_default(:pitcher_stats, :whip, 0.0)
  	change_column_default(:pitcher_stats, :ip, 0.0)
  	change_column_default(:pitcher_stats, :so, 0)
  	change_column_default(:pitcher_stats, :bb, 0)
  	change_column_default(:pitcher_stats, :fip, 0)
  	change_column_default(:pitcher_stats, :xfip, 0.0)
  	change_column_default(:pitcher_stats, :kbb, 0.0)
  	change_column_default(:pitcher_stats, :woba, 0)
  	change_column_default(:pitcher_stats, :ops, 0)
  	change_column_default(:pitcher_stats, :era, 0.0)
  	change_column_default(:pitcher_stats, :fb, 0.0)
  	change_column_default(:pitcher_stats, :gb, 0.0)
  	change_column_default(:pitcher_stats, :ld, 0.0)
  	change_column_default(:pitcher_stats, :h, 0)
  	change_column_default(:pitcher_stats, :siera, 0.0)
  end
end