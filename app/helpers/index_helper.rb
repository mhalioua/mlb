module IndexHelper
	def game_link(game)
		game.away_team.name + " @ " + game.home_team.name
	end
end
