require "../am.cr"
require "discordcr"

module Command
    def info(client, cache, message)
	    embed = Discord::Embed.new(
		    colour: 0xff5587,
			thumbnail: Discord::EmbedThumbnail.new(
				url: cache.resolve_user(client.client_id).avatar_url
			),
			timestamp: Time.utc
		)
	    if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
		    embed.title = "информация"
            embed.fields = [
			    Discord::EmbedField.new(
				    name: "основное",
				    value: "серверов: `#{cache.guilds.size}`"
			    ),
			    Discord::EmbedField.new(
			        name: "версии",
			        value: "проект: `#{Am::VERSION}`\ncrystal: `#{Crystal::VERSION}`\nllvm: `#{Crystal::LLVM_VERSION}`"
			    )
		    ]
	    else
		    embed.title = "info"
		    embed.fields = [
			    Discord::EmbedField.new(
					name: "main",
					value: "guilds: `#{cache.guilds.size}`"
				),
				Discord::EmbedField.new(
					name: "versions",
					value: "project: `#{Am::VERSION}`\ncrystal: `#{Crystal::VERSION}`\nllvm: `#{Crystal::LLVM_VERSION}`"
				)
			]
	   end
	   client.create_message(message.channel_id, "", embed)
    end
end