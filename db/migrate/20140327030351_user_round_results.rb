class UserRoundResults < ActiveRecord::Migration
  def change
		add_column :user_round_results, :tweeted, :boolean
  end
end
