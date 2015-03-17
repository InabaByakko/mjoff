class UserRoundResults < ActiveRecord::Migration
  def change
		change_column :user_round_results, :plus_minus, :float
  end
end
