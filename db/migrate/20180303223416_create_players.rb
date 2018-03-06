class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.belongs_to :team,  index: true
      t.string   :name
      t.string   :identity
      t.integer  :fangraph_id
      t.string   :bathand
      t.string   :throwhand
      t.interger :age
      t.timestamps
    end
  end
end
