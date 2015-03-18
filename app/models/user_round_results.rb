class UserRoundResults < ActiveRecord::Base
	ERR_NOT_FOUR_USER = 1;
	ERR_HAS_SAME_USER = 2;
	ERR_GENTEN_OVER = 3;
	
	#####################################################
	# 指定した開催回の半荘IDリストを取得
	def self.get_round_id_list(open_time, limit)
		round = self.where(:open_time => open_time).
			group(:round_id).
			order("round_id DESC")
		if limit > 0
			round = round.limit(limit)
		end
		return self.none if round.select("round_id") == nil
		return round.select("round_id")
	end
	
	#####################################################
	# 指定した開催回の最後の半荘回数を取得
	def self.get_last_round(open_time)
		round = self.where(:open_time => open_time).
			group(:round_id).
			order("round_id DESC")
		return 0 if round.first == nil
		return round.first[:round_id]
	end
	
	#####################################################
	# １半荘分の結果の妥当性チェック
	def self.valid?(rounds)
		if !has_four_user?(rounds)
			return ERR_NOT_FOUR_USER
		end
		if has_same_user?(rounds)
			return ERR_HAS_SAME_USER
		end
		if is_start_score_over?(rounds)
			return ERR_GENTEN_OVER
		end
		return true
	end
	
	#####################################################
	# 同じユーザーIDがないか
	def self.has_same_user?(rounds)
		rounds.each do |round|
			rounds.each do |r|
				if round != r and round.user_id == r.user_id
					return true
				end
			end
		end
		return false
	end
	#####################################################
	# ４人のユーザーか
	def self.has_four_user?(rounds)
		if rounds.length == 4
			rounds.each do |r|
				if r.class != UserRoundResults
					return false
				end
			end
			return true
		end
		return false
	end
	#####################################################
	# 合計が配給原点を超えていないか
	def self.is_start_score_over?(rounds)
		sum = 0
		rounds.each do |r|
			sum += r.score
		end
		if sum > Application.start_score * 4
			return true
		end
		return false
	end

	#####################################################
	# 順位付け
	def self.set_ranks(rounds)
		# 得点が大きい順、点数が同じ時はより大きい順位を付ける
		sorted_rounds = rounds.sort {|r, s| (s.score <=> r.score).nonzero? || (r.seat <=> s.seat) }
		for i in 0..3
			if i >= 1 and sorted_rounds[i].score == sorted_rounds[i-1].score
				sorted_rounds[i].rank = sorted_rounds[i-1].rank
			else
				sorted_rounds[i].rank = i+1
			end
		end
	end
	
	#####################################################
	# ウマ支払い
	def self.pay_rank_score(rounds)
		sorted_rounds = rounds.sort_by {|r| r.rank }
		score_diff = [
			Application.fourth_to_first_score,
			Application.third_to_second_score,
			Application.third_to_second_score * -1,
			Application.fourth_to_first_score * -1
			]
		# 同順位のプレイヤーがいる場合、同じ順位同士でウマを折半し合う
		# 同じ順位を探す　参考；http://kiyotakakubo.hatenablog.com/entry/20110801/1312196444
		same_ranks = sorted_rounds.inject(Hash.new(0)){|h, key| h[key.rank] += 1; h}.map {|k,v| k if v >= 2}.compact
		same_ranks.each do |rank|
			# 同じ順位の人数
			same_count = sorted_rounds.count{|r|r.rank == rank}
			# 同順位のウマ授受の合計
			joined_score = 0
			for i in 0...same_count
				joined_score += score_diff[i + (rank-1)]
			end
			# 人数で割り、100点以下を切り捨てそれを加減点とする
			joined_score = (joined_score / same_count / 100.0).to_i * 100
			for i in 0...same_count
				score_diff[i + (rank-1)] = joined_score
			end
		end
		# ウマ加減
		for i in 0..3
			sorted_rounds[i].score += score_diff[i]
		end
	end
	
	#####################################################
	# プラマイ計算
	def self.set_plus_minus(rounds)
		sorted_rounds = rounds.sort_by {|r| r.rank }
		# 1位だけ最後にまとめて計算するため避けておく
		firsts = sorted_rounds.shift(sorted_rounds.count{|r|r.rank == 1})
		# 2位以下の収支計算
		sum = 0
		sorted_rounds.each do |round|
			# 小数第一位まで丸める
			round.plus_minus = ((round.score - Application.standard_score) / 1000.0).round(1)
			sum += round.plus_minus
		end
		# 計算した残りを1位に加算
		firsts.each do |r|
			r.plus_minus = sum.abs / firsts.length
		end
	end
	
	#####################################################
	# パラメータからセット
	def set(params, seat, open_time)
		self.user_id = params["user_id"].to_i
		self.score = params["score"].to_i * 100
		self.yakuman = params["yakuman"].to_i
		self.seat = seat
		self.open_time = open_time
	end
	
end
