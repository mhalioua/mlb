class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :abbr
      t.integer :fangraph_id
      t.string :zipcode
      t.integer :timezone
      t.timestamps
    end
  end
end
