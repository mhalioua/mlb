class AddPostponeToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :postpone, :boolean, default: false
  end
end