class CreatePlaybyplays < ActiveRecord::Migration[5.1]
  def change
    create_table :playbyplays do |t|
      t.belongs_to  :game

      t.integer     :ll_ab
      t.integer     :ll_h
      t.integer     :ll_bb
      t.integer     :ll_hr
      t.integer     :ll_k

      t.integer     :lr_ab
      t.integer     :lr_h
      t.integer     :lr_bb
      t.integer     :lr_hr
      t.integer     :lr_k

      t.integer     :rl_ab
      t.integer     :rl_h
      t.integer     :rl_bb
      t.integer     :rl_hr
      t.integer     :rl_k

      t.integer     :rr_ab
      t.integer     :rr_h
      t.integer     :rr_bb
      t.integer     :rr_hr
      t.integer     :rr_k

      t.timestamps
    end
  end
end
