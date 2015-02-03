class CreateTwitterUsers < ActiveRecord::Migration
  def change
    create_table :twitter_users do |t|
			t.string :username, :limit => 20, :null => false
			t.string :screen_name, :limit => 15, :null => false
			t.integer :open_time, :null => false
			t.string :icon_src, :null => false
			t.string :access_token, :null => false
			t.string :access_secret, :null => false
			
      t.timestamps
    end
  end
end
