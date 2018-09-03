class AddLinkToNewWorkbook < ActiveRecord::Migration[5.1]
  def change
    add_column :newworkbooks, :link, :string
  end
end
