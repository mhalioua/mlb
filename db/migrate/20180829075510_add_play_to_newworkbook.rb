class AddPlayToNewworkbook < ActiveRecord::Migration[5.1]
  def change
    add_column :newworkbooks, :ll_ab, :integer
    add_column :newworkbooks, :ll_h,  :integer
    add_column :newworkbooks, :ll_bb, :integer
    add_column :newworkbooks, :ll_hr, :integer
    add_column :newworkbooks, :ll_k,  :integer

    add_column :newworkbooks, :lr_ab, :integer
    add_column :newworkbooks, :lr_h,  :integer
    add_column :newworkbooks, :lr_bb, :integer
    add_column :newworkbooks, :lr_hr, :integer
    add_column :newworkbooks, :lr_k,  :integer

    add_column :newworkbooks, :rl_ab, :integer
    add_column :newworkbooks, :rl_h,  :integer
    add_column :newworkbooks, :rl_bb, :integer
    add_column :newworkbooks, :rl_hr, :integer
    add_column :newworkbooks, :rl_k,  :integer

    add_column :newworkbooks, :rr_ab, :integer
    add_column :newworkbooks, :rr_h,  :integer
    add_column :newworkbooks, :rr_bb, :integer
    add_column :newworkbooks, :rr_hr, :integer
    add_column :newworkbooks, :rr_k,  :integer
  end
end
