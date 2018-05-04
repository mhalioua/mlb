class CreateStadia < ActiveRecord::Migration[5.1]
  def change
    create_table :stadia do |t|
    	t.string	:stadium
		t.string	:time
      	t.timestamps
    end
  end
end
