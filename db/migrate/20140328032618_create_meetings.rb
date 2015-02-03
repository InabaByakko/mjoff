class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings,:primary_key => 'open_time' do |t|
      t.time :enter_time
      t.integer :reserved_table
      
      t.timestamps
    end
  end
end
