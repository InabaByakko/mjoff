class TweetController < ApplicationController
	def confirm
		@round = UserRoundResults.where(:id => params[:id]).first
		@user = TwitterUser.where(:id => @round.user_id).first
		
		if @round.tweeted
			session[:live_error] = "すでにツイート済です。"
			redirect_to :controller => "round", :action => "index"
			return
		end
		
		# メッセージ作成
		@tweet_message = "第#{Application.open_time}回麻雀オフの#{@round.round_id}対局目にて、#{@round.score}点で#{@round.rank}位でした"
		if @round.score >= 35000
			@tweet_message += "！大勝！！！"
		elsif @round.score <= 5000
			@tweet_message += "。やられました・・・。"
		else
			@tweet_message += "。"
		end
		if @round.yakuman > 0
			@tweet_message += "　さらに、役満を#{@round.yakuman}回和了！"
		end
	end

	def get_qr
		@round = UserRoundResults.where(:open_time => params[:open_time], :round_id => params[:round_id], :user_id => params[:tweet_user]).first
		if @round.nil?
			error "指定された半荘データは存在しません。"
			return
		end

		@user = TwitterUser.where(:id => @round.user_id).first
		
		url = url_for(:controller => "record", :action => "show", :open_time => params[:open_time], :round_id => params[:round_id], :tweet_user => @user.screen_name)
		@barcode = QR.new(url)
	end
	
	def update
		@round = UserRoundResults.where(:id => params[:id]).first
		@user = TwitterUser.where(:id => @round.user_id).first
		
		if @round.tweeted
			session[:live_error] = "すでにツイート済です。"
			redirect_to :controller => "round", :action => "index"
			return
		end
		
		# twitter apiに接続
		client = Twitter::REST::Client.new do |config|
			config.consumer_key = TwitterSettings.consumer_key
			config.consumer_secret = TwitterSettings.consumer_secret
			config.access_token = @user.access_token
			config.access_token_secret = @user.access_secret
		end
		
		begin
			client.update(params[:tweet_message])
			@round.tweeted = true
			@round.save
		rescue
			session[:live_error] = "ツイート中に問題が発生したようです。"
		end
		
		redirect_to :controller => "round", :action => "index"
	end
end
