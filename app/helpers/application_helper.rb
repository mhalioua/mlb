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
	def mixed_statistic_ip(lefty_stat, righty_stat, num_lefty, num_righty)
		if num_lefty + num_righty == 0
			0
		elsif lefty_stat == nil || righty_stat == nil
			0
		else
			decimal = ((lefty_stat - lefty_stat.to_i)*10).round() + ((righty_stat - righty_stat.to_i)* 10).round()
			sum = lefty_stat.to_i * num_lefty + righty_stat.to_i * num_righty
			sum + (decimal/3).to_i + (decimal%3)/10
		end
	end
end
