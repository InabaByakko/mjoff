require 'test_helper'

class UserRoundResultsTest < ActiveSupport::TestCase
	fixtures :user_round_results
  # test "the truth" do
  #   assert true
  # end
	
	def get_test_data(offset = 0)
		rounds = UserRoundResults.all
		array = [rounds[0 + offset],rounds[1 + offset],rounds[2 + offset],rounds[3 + offset]]
		return array
	end
	
	test "順位付け" do
		@rounds = get_test_data
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 4, @rounds[0].rank
		assert_equal 2, @rounds[1].rank
		assert_equal 1, @rounds[2].rank
		assert_equal 3, @rounds[3].rank
	end
	
	test "ウマ支払い" do
		@rounds = get_test_data
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		assert_equal 9000, @rounds[0].score
		assert_equal 31000, @rounds[1].score
		assert_equal 41000, @rounds[2].score
		assert_equal 19000, @rounds[3].score
	end
	

	test "プラマイ計算" do
		@rounds = get_test_data
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		assert_equal -21, @rounds[0].plus_minus
		assert_equal 1, @rounds[1].plus_minus
		assert_equal 31, @rounds[2].plus_minus
		assert_equal -11, @rounds[3].plus_minus
	end
	
	###############################################
	## 同点の場合
	###############################################
	
	test "順位（1位と2位が同じ）" do
		@rounds = get_test_data(4)
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 4, @rounds[0].rank
		assert_equal 1, @rounds[1].rank
		assert_equal 1, @rounds[2].rank
		assert_equal 3, @rounds[3].rank
	end
	
	# 想定結果：1位と2位がそれぞれ馬を折半し7500点ずつ加算
	test "同着ウマ支払い（1位と2位が同じ）" do
		@rounds = get_test_data(4)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		assert_equal 5000, @rounds[0].score
		assert_equal 39500, @rounds[1].score
		assert_equal 39500, @rounds[2].score
		assert_equal 16000, @rounds[3].score
	end
	
	# 端数は切り捨て
	test "プラマイ（1位と2位が同じ）" do
		@rounds = get_test_data(4)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		assert_equal -25, @rounds[0].plus_minus
		assert_equal 19.5, @rounds[1].plus_minus
		assert_equal 19.5, @rounds[2].plus_minus
		assert_equal -14, @rounds[3].plus_minus
	end
	
	test "順位（3位と4位が同じ）" do
		@rounds = get_test_data(8)
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 3, @rounds[0].rank
		assert_equal 3, @rounds[1].rank
		assert_equal 2, @rounds[2].rank
		assert_equal 1, @rounds[3].rank
	end
	
	# 想定結果：3位と4位がそれぞれ馬を折半し7500点ずつ支払い
	test "同着ウマ支払い（3位と4位が同じ）" do
		@rounds = get_test_data(8)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		assert_equal 1500, @rounds[0].score
		assert_equal 1500, @rounds[1].score
		assert_equal 41000, @rounds[2].score
		assert_equal 56000, @rounds[3].score
	end
	
	test "プラマイ（3位と4位が同じ）" do
		@rounds = get_test_data(8)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		assert_equal -28.5, @rounds[0].plus_minus
		assert_equal -28.5, @rounds[1].plus_minus
		assert_equal 11, @rounds[2].plus_minus
		assert_equal 46, @rounds[3].plus_minus
	end
	
	test "順位（2位と3位が同じ）" do
		@rounds = get_test_data(12)
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 1, @rounds[0].rank
		assert_equal 2, @rounds[1].rank
		assert_equal 2, @rounds[2].rank
		assert_equal 4, @rounds[3].rank
	end
	
	# 想定結果：２／３位の間に授受は発生しない
	test "同着ウマ支払い（2位と3位が同じ）" do
		@rounds = get_test_data(12)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		assert_equal 66000, @rounds[0].score
		assert_equal 20000, @rounds[1].score
		assert_equal 20000, @rounds[2].score
		assert_equal -6000, @rounds[3].score
	end
	
	test "プラマイ（2位と3位が同じ）" do
		@rounds = get_test_data(12)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		assert_equal 56, @rounds[0].plus_minus
		assert_equal -10, @rounds[1].plus_minus
		assert_equal -10, @rounds[2].plus_minus
		assert_equal -36, @rounds[3].plus_minus
	end
	
	test "順位（1位と2位と3位が同じ）" do
		@rounds = get_test_data(16)
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 4, @rounds[0].rank
		assert_equal 1, @rounds[1].rank
		assert_equal 1, @rounds[2].rank
		assert_equal 1, @rounds[3].rank
	end
	
	# 想定結果：１／２／３位それぞれ3300点ずつ加算（端数切り捨て）（仮）
	test "同着ウマ支払い（1位と2位と3位が同じ）" do
		@rounds = get_test_data(16)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		# 4位は-5900かもしれない？要確認
		assert_equal -6000, @rounds[0].score
		assert_equal 35300, @rounds[1].score
		assert_equal 35300, @rounds[2].score
		assert_equal 35300, @rounds[3].score
	end
	
	test "プラマイ（1位と2位と3位が同じ）" do
		@rounds = get_test_data(16)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		# 35.9かもしれない
		assert_equal -36, @rounds[0].plus_minus
		assert_equal 12, @rounds[1].plus_minus
		assert_equal 12, @rounds[2].plus_minus
		assert_equal 12, @rounds[3].plus_minus
	end
	
	test "順位（2位と3位と4位が同じ）" do
		@rounds = get_test_data(20)
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 1, @rounds[0].rank
		assert_equal 2, @rounds[1].rank
		assert_equal 2, @rounds[2].rank
		assert_equal 2, @rounds[3].rank
	end
	
	# 想定結果：２／３／4位それぞれ3300点ずつ支払い（端数切り捨て）（仮）
	test "同着ウマ支払い（2位と3位と4位が同じ）" do
		@rounds = get_test_data(20)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		# 82900かもしれない
		assert_equal 83000, @rounds[0].score
		assert_equal 5700, @rounds[1].score
		assert_equal 5700, @rounds[2].score
		assert_equal 5700, @rounds[3].score
	end
	
	test "プラマイ（2位と3位と4位が同じ）" do
		@rounds = get_test_data(20)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		# 73かもしれない
		assert_equal 72.9, @rounds[0].plus_minus
		assert_equal -24.3, @rounds[1].plus_minus
		assert_equal -24.3, @rounds[2].plus_minus
		assert_equal -24.3, @rounds[3].plus_minus
	end
	
	test "順位（全員同じ）" do
		@rounds = get_test_data(24)
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 1, @rounds[0].rank
		assert_equal 1, @rounds[1].rank
		assert_equal 1, @rounds[2].rank
		assert_equal 1, @rounds[3].rank
	end
	
	# 想定結果：なにもうごかない
	test "同着ウマ支払い（全員同じ）" do
		@rounds = get_test_data(24)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		assert_equal 25000, @rounds[0].score
		assert_equal 25000, @rounds[1].score
		assert_equal 25000, @rounds[2].score
		assert_equal 25000, @rounds[3].score
	end
	
	test "プラマイ（全員同じ）" do
		@rounds = get_test_data(24)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		assert_equal 0, @rounds[0].plus_minus
		assert_equal 0, @rounds[1].plus_minus
		assert_equal 0, @rounds[2].plus_minus
		assert_equal 0, @rounds[3].plus_minus
	end
	
	test "順位（1/2位、3/4位同着）" do
		@rounds = get_test_data(28)
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 1, @rounds[0].rank
		assert_equal 3, @rounds[1].rank
		assert_equal 3, @rounds[2].rank
		assert_equal 1, @rounds[3].rank
	end
	
	# 想定結果：3位と4位がそれぞれ馬を折半し7500点ずつ支払い、1位と2位がそれぞれ馬を折半し7500点ずつ加算
	test "同着ウマ支払い（1/2位、3/4位同着）" do
		@rounds = get_test_data(28)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		assert_equal 37500, @rounds[0].score
		assert_equal 12500, @rounds[1].score
		assert_equal 12500, @rounds[2].score
		assert_equal 37500, @rounds[3].score
	end
	
	test "プラマイ（1/2位、3/4位同着）" do
		@rounds = get_test_data(28)
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		assert_equal 17.5, @rounds[0].plus_minus
		assert_equal -17.5, @rounds[1].plus_minus
		assert_equal -17.5, @rounds[2].plus_minus
		assert_equal 17.5, @rounds[3].plus_minus
	end
end
