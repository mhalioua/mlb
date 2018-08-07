class AddTHitsToWorkbook < ActiveRecord::Migration[5.1]
  def change
    add_column :workbooks, :t_HITS, :float
  end
end
