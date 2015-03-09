
class RankingController < ApplicationController
  def index
		# 開催中なら、前回開催のランキングへリダイレクト
		if Application.is_open
			redirect_to action: :total, open_time: Application.open_time - 1
		else
			# 未開催で、募集中（半荘レコードが空）なら前回のランキングへ
			if UserRoundResults.where(open_time: Application.open_time).length == 0
				redirect_to action: :total, open_time: Application.open_time - 1
			end
			redirect_to action: :total, open_time: Application.open_time 
		end
  end

  def total
    if params[:open_time].nil?
      error "開催回が指定されていません。"
    end
    if Application.is_open and params[:open_time] == Application.open_time
      error "開催中の回のランキングは見られません。"
    end
    
    @users = TwitterUser.where(open_time: params[:open_time]).to_a
    if @users.empty?
      error "指定された回は未開催です。" 
    end
    
		# プラマイスコアの高い順に並べ替える（出力は[[:user_id, :sum_plus_minus], ...]）
    @rank = UserRoundResults.select(:user_id).group(:user_id).where(open_time: params[:open_time]).sum(:plus_minus).sort{|(userA,scoreA),(userB,scoreB)| scoreB <=> scoreA }
  end
end
