class UploadImagesToAws
	def self.upload_images
		game_start_index = '2020-03-11'
	    game_end_index = '2020-03-16'
	    #390 games
	    games = Game.where("game_date between ? and ?", Date.strptime(game_start_index).beginning_of_day, Date.strptime(game_end_index).end_of_day)

		games.each do |game|
			#url = URI.parse("https://mlb-daemon.s3.amazonaws.com/images/#{game.id}.png")
			#http = Net::HTTP.new(url.host, url.port)
			#http.use_ssl = true if url.scheme == 'https'
			#unless http.request_head(url.path).code == "200"
				kit = IMGKit.new("https://mlb.herokuapp.com/game/new/#{game.id}/0/0/5", :quality => 50)
				file = kit.to_file("#{Rails.root}/tmp/game#{game.id}.png")
				obj = S3.object("images/#{game.id}.png")
				obj.upload_file(file, acl:'public-read')
				File.delete(file)
				puts "game #{game.id}"
			#end
		end
	end
end