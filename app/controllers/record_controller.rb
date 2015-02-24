class RecordController < ApplicationController
  def user
		@users = TwitterUser.all.to_a
		p @users.sort{|a,b| b.open_time <=> a.open_time }
		@display_user = @users.sort{|a,b| b.open_time <=> a.open_time }.find{|u| u[:screen_name].casecmp(params[:screen_name]) == 0}
		if @display_user.nil?
			error "指定されたユーザーは過去に麻雀オフに参加していません。"
			return
		end
		@rounds = []
		uids = TwitterUser.select(:id).where(screen_name:  params[:screen_name]).to_a
		
		# 指定したユーザーの半荘IDを取得
		round_id_list =UserRoundResults.where("user_id IN (?)", uids).select(:round_id)
		
		round_id_list.each do |rid|
			@rounds.push( UserRoundResults.where(:round_id => rid.round_id).order("seat ASC").to_a)
		end
  end
end
