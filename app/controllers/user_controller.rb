##################################################################
# twitter gem doc
# http://rdoc.info/gems/twitter
# http://it.typeac.jp/article/show/7
#

####################################################################
=begin
取得できるメソッド：
https://dev.twitter.com/docs/api/1.1/get/statuses/show/%3Aid
の user
=end 

class UserController < ApplicationController
	 
	def oauth_consumer
	  return OAuth::Consumer.new(TwitterSettings.consumer_key, TwitterSettings.consumer_secret, :site => "https://api.twitter.com")
	end

	#############################################################################
	# エントリーページ（固定ページを表示するだけで何もしない）
	def entry
		
	end
	
	#############################################################################
	# リクエストトークンを作成してTwitter認証ページヘリダイレクト
	def auth
    	callback = TwitterSettings.callback_host + '/user/callback'
		request_token = oauth_consumer.get_request_token(:oauth_callback => callback)
  		# セッションにトークンを保存
  		session[:request_token] = request_token.token
  		session[:request_token_secret] = request_token.secret
  		
  		# 会場で取り回して認証させたいので、毎回ちゃんとログインさせる
  		redirect_to request_token.authorize_url << '&force_login=1'
	end
	
	#############################################################################
	# Twitter認証ページからのコールバックを処理
	def callback
		# 認証キャンセルされた場合は、トップに戻す
		if params.has_key?(:denied)
			redirect_to :action => "entry"
			return
		end
		
		request_token = OAuth::RequestToken.new(oauth_consumer, session[:request_token], session[:request_token_secret])
 
		# OAuthで渡されたtoken, verifierを使って、tokenとtoken_secretを取得
		access_token = nil
		begin
			access_token = request_token.get_access_token(
				{},
				:oauth_token => params[:oauth_token],
				:oauth_verifier => params[:oauth_verifier])
		rescue OAuth::Unauthorized => @exception
			# 本来はエラー画面を表示したほうが良いが、今回はSinatra標準のエラー画面を表示
			redirect_to 'failed'
		end

		 # twitter apiに接続
		client = Twitter::REST::Client.new do |config|
			config.consumer_key = TwitterSettings.consumer_key
			config.consumer_secret = TwitterSettings.consumer_secret
			config.access_token = access_token.token
			config.access_token_secret = access_token.secret
		end
		
		# APIからユーザー情報取得してDBへ保存
		profile = client.user()
		@user = TwitterUser.find_or_new_by_screen_name_and_open_time(profile.screen_name, Application.open_time)
		@user.set_init_data(profile, access_token, Application.open_time)
		@user.save
		
		session[:screen_name] = profile.screen_name
		redirect_to :action => "edit"
	end
	
	#############################################################################
	# 
	def edit
		screen_name = (params[:screen_name] ? params[:screen_name] : session[:screen_name] )
	  @user = TwitterUser.find_by(:screen_name => screen_name, :open_time => Application.open_time)
		if !@user
			redirect_to :action => "entry"
			return
		end
		@from_register = (params[:screen_name] ? 0 : 1)
	end
	
	#############################################################################
	# 
	def update
		screen_name = (params[:screen_name] ? params[:screen_name] : session[:screen_name] )
		@user = TwitterUser.find_by(:screen_name => screen_name, :open_time => Application.open_time)
		
		@user.is_student = params[:is_student]
		@user.save
		
		if params[:from_register]
			redirect_to :action => "complete"
		end
	end
	
	#############################################################################
	# 
	def failed
		
	end
	
	#############################################################################
	# 
	def complete
		# sessionが空ならリダイレクト
		if !session.has_key?(:screen_name) or session[:screen_name].empty?
			redirect_to :action => "entry"
			return
		end
		
		@user = TwitterUser.find_by(:screen_name =>session[:screen_name], :open_time => Application.open_time)
		# 前回までに参加したか？ (スクリーンネームで判断するので変えた人は別人判定されてしまう)
		if Application.open_time > 1
			@is_joined_before = !(TwitterUser.where("screen_name = ? and open_time < ?", session[:screen_name], Application.open_time).empty?)
		else
			@is_joined_before = false
		end
		
		# セッションをクリア
		session[:screen_name] = ""
	end
end
