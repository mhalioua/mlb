class CreateInnings < ActiveRecord::Migration[5.1]
  def change
    create_table :innings do |t|
      t.belongs_to :game
      t.string :number
      t.string :away
      t.string :home
      t.timestamps
    end
  end
end
