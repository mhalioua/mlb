class AddTeamIdToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :team_id, :integer
  end
end
