module Event
	def on_ready(client)
		client.status_update(
			status: "online",
			game: Discord::GamePlaying.new(
				name: "crystal",
				type: Discord::GamePlaying::Type::Listening
			),
		)
		puts "ready!"
	end
end