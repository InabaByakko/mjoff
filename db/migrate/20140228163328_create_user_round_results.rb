class CreateUserRoundResults < ActiveRecord::Migration
  def change
    create_table :user_round_results do |t|
			t.integer :user_id, :null => false
			t.integer :open_time, :null => false
			t.integer :round_id, :null => false
			t.integer :seat, :null => false
			t.integer :rank, :null => false
			t.integer :score, :null => false
			t.integer :plus_minus, :null => false
			t.integer :yakuman, :default => 0
			
      t.timestamps
    end
  end
end
