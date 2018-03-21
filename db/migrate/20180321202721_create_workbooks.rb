class CreateWorkbooks < ActiveRecord::Migration[5.1]
  def change
    create_table :workbooks do |t|
      t.float :TEMP
      t.float :DP
      t.float :HUMID
      t.float :BARo
      t.float :R
      t.float :Total_Hits
      t.float :Total_Walks
      t.float :home_runs
      t.string :type

      t.timestamps
    end
  end
end
