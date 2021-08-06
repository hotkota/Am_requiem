require "discordcr"

module Command
	def help(client, cache, message, prefix)
		embed = Discord::Embed.new(
			colour: 0xff5587,
			thumbnail: Discord::EmbedThumbnail.new(
				url: cache.resolve_user(client.client_id).avatar_url
			),
			timestamp: Time.utc
		)
		if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
			embed.title = "Хелп"
			embed.fields = [
				Discord::EmbedField.new(
					name: "Информация",
					value: "`#{prefix}хелп` `#{prefix}пинг` `#{prefix}стат` `#{prefix}бот`"
				),
				Discord::EmbedField.new(
					name: "Теги",
					value: "`#{prefix}тег ?`"
				),
				Discord::EmbedField.new(
					name: "Настройка",
					value: "`#{prefix}префикс`"
				)
			]
		else
			embed.title = "Help"
			embed.fields = [
				Discord::EmbedField.new(
					name: "info",
					value: "`#{prefix}help` `#{prefix}ping` `#{prefix}stat` `#{prefix}bot`"
				),
				Discord::EmbedField.new(
					name: "tag",
					value: "`#{prefix}tag ?`"
				),
				Discord::EmbedField.new(
					name: "settings",
					value: "`#{prefix}prefix`"
				)
			]
		end
		client.create_message(message.channel_id, "", embed)
	end
end