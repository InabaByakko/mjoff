class RecordController < ApplicationController
  def user
		uid = TwitterUser.select(:id).where(screen_name:  params[:screen_name])
		
		# 指定したユーザーの半荘IDを取得
		round_id_list =UserRoundResults.where(user_id: uid).select(:round_id)
		
		@rounds = []
		round_id_list.each do |rid|
			@rounds.push( UserRoundResults.where(:round_id => rid).order("seat ASC").to_a)
		end
  end
end
