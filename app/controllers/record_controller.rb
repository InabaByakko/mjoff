class RecordController < ApplicationController
  def user
		@users = TwitterUser.all.to_a
		@display_user = @users.sort{|a,b| b.open_time <=> a.open_time }.find{|u| u[:screen_name].casecmp(params[:screen_name]) == 0}
		if @display_user.nil?
			error "指定されたユーザーは過去に麻雀オフに参加していません。"
			return
		end
		@rounds = []
		uids = TwitterUser.select(:id).where(screen_name:  params[:screen_name]).to_a
		
		# 指定したユーザーの半荘IDを取得
		round_id_list = UserRoundResults.select(:open_time, :round_id).where("user_id IN (?)", uids)
		if params[:open_time].nil?
			if Application.is_open
				round_id_list = round_id_list.where("open_time <> ?", Application.open_time)
			end
		else
			if Application.is_open and params[:open_time].to_i == Application.open_time
				error "開催期間中は当日の過去半荘データはみられません。"
			else
				round_id_list = round_id_list.where(open_time:  params[:open_time])
			end
		end
		
		round_id_list.each do |r|
			@rounds.push( UserRoundResults.where(open_time: r.open_time).where(round_id: r.round_id).order("seat ASC").to_a)
		end
		
		unless params[:open_time].nil?
			render action: 'user_time'
		end
  end
	
	def show
		@users = TwitterUser.where(:open_time => params[:open_time]).to_a
		@rounds = UserRoundResults.where("open_time = ? AND round_id = ?", params[:open_time], params[:round_id]).order("seat ASC")
		
		if @rounds.empty?
			error "指定された半荘結果は登録されていません。"
		end
		
		# 開催期間中は公開している半荘データしか表示しないようにする
		if Application.is_open and params[:open_time].to_i == Application.open_time.to_i
			latest_round_id = UserRoundResults.get_last_round(Application.open_time)
			if params[:round_id].to_i <= latest_round_id.to_i - Application.show_rounds.to_i
				error "開催期間中は当日の過去半荘データはみられません。"
			end
		end
	end
end
