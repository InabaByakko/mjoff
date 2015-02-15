class RecordController < ApplicationController
  def user
		# 指定したユーザーの半荘IDを取得
		round_id_list =UserRoundResults.where(screen_name: params[:screen_name]).select(:round_id)
		
		@rounds = []
		round_id_list.each do |rid|
			@rounds.push( UserRoundResults.where(:round_id => rid).order("seat ASC").to_a)
		end
  end
end
