class RecordController < ApplicationController
  def user
		@users = TwitterUser.all.to_a
		@rounds = []
		uids = TwitterUser.select(:id).where(screen_name:  params[:screen_name]).to_a
		# TODO: 存在しないscreen_nameを指定したときエラー画面
		
		# 指定したユーザーの半荘IDを取得
		round_id_list =UserRoundResults.where("user_id IN (?)", uids).select(:round_id)
		
		round_id_list.each do |rid|
			@rounds.push( UserRoundResults.where(:round_id => rid.round_id).order("seat ASC").to_a)
		end
  end
end
