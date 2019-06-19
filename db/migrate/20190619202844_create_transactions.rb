class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.string :date
      t.string :description

      t.timestamps
    end
  end
end
