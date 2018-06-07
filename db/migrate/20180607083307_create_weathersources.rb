class CreateWeathersources < ActiveRecord::Migration[5.1]
  def change
    create_table :weathersources do |t|
      t.belongs_to :game, index: true
      t.string    :date
      t.integer   :offset

      t.integer   :table_number
      t.integer   :block_number
      t.integer   :row_number

      t.string    :caption
      t.string    :temp
      t.string    :dew
      t.string    :humid
      t.string    :pressure
      t.string    :wind

      t.float     :all_stadium_total_average_one
      t.float     :all_stadium_total_average_two
      t.float     :all_stadium_total_hits_average
      t.float     :all_stadium_home_runs_average
      t.integer   :all_stadium_total_count
      t.float     :all_stadium_min_total_average
      t.integer   :all_stadium_min_total_count
      t.float     :all_stadium_total_lines_average

      t.float     :only_total_average_one
      t.float     :only_total_average_two
      t.float     :only_total_hits_average
      t.float     :only_home_runs_average
      t.integer   :only_total_count
      t.float     :only_min_total_average
      t.integer   :only_min_total_count
      t.float     :only_total_lines_average

      t.float     :only_wind_total_average_one
      t.float     :only_wind_total_average_two
      t.float     :only_wind_total_hits_average
      t.float     :only_wind_home_runs_average
      t.integer   :only_wind_total_count
      t.float     :only_wind_min_total_average
      t.integer   :only_wind_min_total_count
      t.float     :only_wind_total_lines_average

      t.float     :except_total_average_one
      t.float     :except_total_average_two
      t.float     :except_total_hits_average
      t.float     :except_home_runs_average
      t.integer   :except_total_count
      t.float     :except_min_total_average
      t.integer   :except_min_total_count
      t.float     :except_total_lines_average

      t.timestamps
    end
  end
end
