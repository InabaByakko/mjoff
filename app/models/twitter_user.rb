class TwitterUser < ActiveRecord::Base
	# screennameと開催回でDBを探し、なければ新規作成する
	def self.find_or_new_by_screen_name_and_open_time(screen_name, open_time)
		user = find_by(:screen_name => screen_name, :open_time => open_time)
		if !user
			user = TwitterUser.new()
		end
		return user
	end
	
	# TwitterAPI出力結果から初期値をセット
	def set_init_data(profile, access_token, open_time)
		self.username = profile.name
		self.screen_name = profile.screen_name
		self.icon_src = profile.profile_image_url.to_s
		self.open_time = open_time
		self.access_token = access_token.token
		self.access_secret = access_token.secret
	end
end
