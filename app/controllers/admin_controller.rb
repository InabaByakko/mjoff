class AdminController < ApplicationController
	http_basic_authenticate_with :name => Admin.name, :password => Admin.pass
	
	def userlist
		@users = TwitterUser.where(:open_time => Application.open_time)
		@meeting = Meeting.where(:open_time => Application.open_time).first
	end
	
	def enter		
		updates = []
		if [:enter_update].is_a?(Hash)
			params[:enter_update].each do |key, value|
				if value == "1"
					updates.push(key)
				end
			end
			if !updates.empty?
				TwitterUser.where(:open_time => Application.open_time).
					where(:id => updates).
					update_all("entry_time = '#{Time.now.strftime("%H:%M:%S")}'")
			end
		end
		
		if params[:meeting_enter_update] == "1"
			Meeting.where(:open_time => Application.open_time).update_all("enter_time = '#{Time.now.strftime("%H:%M:%S")}'")
		end
		
		redirect_to :action => "enter"
	end
end
