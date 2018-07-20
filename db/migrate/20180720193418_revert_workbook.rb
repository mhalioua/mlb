class RevertWorkbook < ActiveRecord::Migration[5.1]
  def change
    remove_column :workbooks, :D2
    remove_column :workbooks, :Away_Starter_First_Name
    add_column :workbooks, :Home_Total, :string
    add_column :workbooks, :table, :string
    add_column :workbooks, :P, :float
    add_column :workbooks, :Q, :float
    add_column :workbooks, :BF, :float
  end
end
