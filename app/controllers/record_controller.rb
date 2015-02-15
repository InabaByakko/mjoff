class RecordController < ApplicationController
  def user
		@rounds = []
		uids = TwitterUser.select(:id).where(screen_name:  params[:screen_name]).to_a
		
		# 指定したユーザーの半荘IDを取得
		round_id_list =UserRoundResults.where("user_id in ?", uids).select(:round_id)
		
		round_id_list.each do |rid|
			@rounds.push( UserRoundResults.where(:round_id => rid).order("seat ASC").to_a)
		end
  end
end
