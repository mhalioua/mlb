module ApplicationHelper
	def mixed_statistic(lefty_stat, righty_stat, num_lefty, num_righty)
		if num_lefty + num_righty == 0
			0
		elsif lefty_stat == nil || righty_stat == nil
			0
		else
			((lefty_stat * num_lefty + righty_stat * num_righty)/(num_lefty + num_righty)).round(2)
		end
	end
end
