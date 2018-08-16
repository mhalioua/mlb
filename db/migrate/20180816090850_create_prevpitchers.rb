class CreatePrevpitchers < ActiveRecord::Migration[5.1]
  def change
    create_table :prevpitchers do |t|
      t.belongs_to :game, index: true
      t.boolean    :away

      t.integer   :start_index
      t.string    :date
      t.string    :time
      t.string    :opp_team_abbr

      t.float      :ip
      t.integer    :bb
      t.integer    :h
      t.integer    :r
      t.string     :home_team_abbr

      t.string    :temp
      t.string    :dp
      t.string    :wind_speed
      t.string    :wind_dir
      t.string    :d2
      t.string    :pressure
      t.string    :hum

      t.string    :total_count_count
      t.string    :total_avg_1_avg_1
      t.string    :total_avg_2
      t.string    :total_hits_avg
      t.string    :home_runs_avg
      t.string    :lower_one
      t.string    :lower_one_count
      t.string    :home_total_runs1_avg
      t.string    :home_total_runs2_avg
      t.string    :home_count
      t.string    :home_one
      t.string    :home_one_count

      t.string    :opposite_throwhand
      t.string    :opposite_name
      t.float     :opposite_ip
      t.integer   :opposite_bb
      t.integer   :opposite_h
      t.integer   :opposite_r

      t.timestamps
    end
  end
end
