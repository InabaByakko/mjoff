class RoundController < ApplicationController
	
	######################################################################
	# すべてのアクションの前に、開催フラグが立っていることを確認
	before_filter :open_check
	def open_check
		if !Application.is_open 
			error "まだ開催していません！！！"
			render :action => "index"
			return false
		end
		return true
	end
	
	def index		
		# 参加人数チェック
		@users = TwitterUser.where(:open_time => Application.open_time).to_a
		if @users.count < 4
			error "エントリー人数が4人に満たないため開催できません。"
		end
		
		# 直近の指定した回数分の半荘IDを取得
		round_id_list = UserRoundResults.get_round_id_list(Application.open_time, Application.show_rounds).pluck(:round_id)
		
		# 半荘結果取得
		@rounds = []
		round_id_list.each do |rid|
			@rounds.push( UserRoundResults.where(:open_time => Application.open_time).
			where(:round_id => rid).order("seat ASC").to_a)
		end
	end
	
	def show
	end
	
	def new		
		# 参加人数チェック
		@users = TwitterUser.where(:open_time => Application.open_time).to_a
		if @users.count < 4
			error "エントリー人数が4人に満たないため開催できません。"
		end
		
		# 半荘結果作成
		@rounds = []
		for i in 0..3
			@rounds[i] = UserRoundResults.new
			@rounds[i].seat = i
			@rounds[i].open_time = Application.open_time
		end
	end
	
	def create		
		# 参加人数チェック
		@users = TwitterUser.where(:open_time => Application.open_time).to_a
		if @users.count < 4
			error "エントリー人数が4人に満たないため開催できません。"
		end
		
		# 半荘結果作成
		@rounds = []
		for i in 0..3
			@rounds[i] = UserRoundResults.new
			@rounds[i].set(params[:user_round_results][i.to_s].to_hash, i, Application.open_time)
		end
		round_id = UserRoundResults.get_last_round(Application.open_time) + 1

		is_valid = UserRoundResults.valid?(@rounds)
		if is_valid == true
			UserRoundResults.set_ranks(@rounds)
			UserRoundResults.pay_rank_score(@rounds)
			UserRoundResults.set_plus_minus(@rounds)
			@rounds.each do |r|
				r.round_id = round_id
				r.save
			end
			redirect_to :action => "index"
		else
			case is_valid
			when UserRoundResults::ERR_NOT_FOUR_USER
				@input_error = "入力が４人ではありません"
			when UserRoundResults::ERR_HAS_SAME_USER
				@input_error = "同じ名前のプレイヤーがいます"
			when UserRoundResults::ERR_GENTEN_OVER
				@input_error = "点数合計が配給原点を超えています"
			end
			@rounds.each do |r|
				r.score /= 100
			end
			render :action => "new"
		end
	end
	
	def edit
		
	end
	
	def update
		
	end
	
	def destroy
		UserRoundResults.where(:open_time => Application.open_time, :round_id => params[:id]).destroy_all
		redirect_to :action => "index"
	end
	
	def error(message)
		@has_error = true
		@error_mes = message
	end
end
