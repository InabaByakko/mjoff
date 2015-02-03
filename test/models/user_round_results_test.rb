require 'test_helper'

class UserRoundResultsTest < ActiveSupport::TestCase
	fixtures :user_round_results
  # test "the truth" do
  #   assert true
  # end
	
	def get_test_data
		rounds = UserRoundResults.all
		array = [rounds[0],rounds[1],rounds[2],rounds[3]]
		return array
	end
	
	test "set_ranks" do
		@rounds = get_test_data
		
		UserRoundResults.set_ranks(@rounds)
		
		assert_equal 4, @rounds[0].rank
		assert_equal 2, @rounds[1].rank
		assert_equal 1, @rounds[2].rank
		assert_equal 3, @rounds[3].rank
	end
	
	test "payrankscore" do
		@rounds = get_test_data
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		
		assert_equal 9000, @rounds[0].score
		assert_equal 30000, @rounds[1].score
		assert_equal 41000, @rounds[2].score
		assert_equal 20000, @rounds[3].score
	end
	

	test "set_plus_minus" do
		@rounds = get_test_data
		
		UserRoundResults.set_ranks(@rounds)
		UserRoundResults.pay_rank_score(@rounds)
		UserRoundResults.set_plus_minus(@rounds)
		
		assert_equal -21, @rounds[0].plus_minus
		assert_equal 0, @rounds[1].plus_minus
		assert_equal 31, @rounds[2].plus_minus
		assert_equal -10, @rounds[3].plus_minus
	end
end
