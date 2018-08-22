class AddKToHitters < ActiveRecord::Migration[5.1]
  def change
    add_column :hitters, :k, :integer
  end
end
