class TwitterUser < ActiveRecord::Migration
  def change
		add_column :twitter_users, :entry_time, :time
		add_column :twitter_users, :is_student, :boolean 
  end
end
