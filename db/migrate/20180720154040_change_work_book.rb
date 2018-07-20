class ChangeWorkBook < ActiveRecord::Migration[5.1]
  def change
    add_column :workbooks, :D2, :string
    add_column :workbooks, :Away_Starter_First_Name, :string
    remove_column :workbooks, :Home_Total
    remove_column :workbooks, :table
    remove_column :workbooks, :P
    remove_column :workbooks, :Q
    remove_column :workbooks, :BF

    add_column :workbooks, :t_HITS_SUM, :integer
    add_column :workbooks, :t_HRS, :float
    add_column :workbooks, :t_HRS_SUM, :integer
    add_column :workbooks, :hits1, :integer
    add_column :workbooks, :hits2, :integer
    add_column :workbooks, :hits3, :integer
    add_column :workbooks, :hits4, :integer
    add_column :workbooks, :hits5, :integer
    add_column :workbooks, :hits6, :integer
    add_column :workbooks, :hits7, :integer
    add_column :workbooks, :hits8, :integer
    add_column :workbooks, :hits9, :integer
    add_column :workbooks, :home_runs1, :integer
    add_column :workbooks, :home_runs2, :integer
    add_column :workbooks, :home_runs3, :integer
    add_column :workbooks, :home_runs4, :integer
    add_column :workbooks, :home_runs5, :integer
    add_column :workbooks, :home_runs6, :integer
    add_column :workbooks, :home_runs7, :integer
    add_column :workbooks, :home_runs8, :integer
    add_column :workbooks, :home_runs9, :integer
    add_column :workbooks, :game_id, :string
  end
end
