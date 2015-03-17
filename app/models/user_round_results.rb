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
		sorted_rounds[0].score += Application.fourth_to_first_score
		sorted_rounds[1].score += Application.third_to_second_score
		sorted_rounds[2].score -= Application.third_to_second_score
		sorted_rounds[3].score -= Application.fourth_to_first_score
	end
	
	#####################################################
	# プラマイ計算
	def self.set_plus_minus(rounds)
		sorted_rounds = rounds.sort_by {|r| r.rank }
		# 1位だけ最後にまとめて計算するため避けておく
		first = sorted_rounds.shift
		# 2位以下の収支計算
		sum = 0
		sorted_rounds.each do |round|
			round.plus_minus = ((round.score - Application.standard_score) / 1000).round
			sum += round.plus_minus
		end
		# 計算した残りを1位に加算
		first.plus_minus = sum.abs
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
