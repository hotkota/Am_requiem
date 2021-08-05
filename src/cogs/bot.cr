require "../am.cr"
require "discordcr"

module Command
    def info(client, cache, message)
        if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
            embed = Discord::Embed.new(
                title: "информация",
                colour: 0xff5587,
                thumbnail: Discord::EmbedThumbnail.new(
					url: cache.resolve_user(client.client_id).avatar_url
				),
                fields: [
                    Discord::EmbedField.new(
						name: "основное",
						value: "серверов: `#{cache.guilds.size}`"
					),
                    Discord::EmbedField.new(
                        name: "версии",
                        value: "проект: `#{Am::VERSION}`\ncrystal: `#{Crystal::VERSION}`\nllvm: `#{Crystal::LLVM_VERSION}`"
                    )
                ],
                timestamp: Time.utc
            )
        else
            embed = Discord::Embed.new(
                title: "info",
                colour: 0xff5587,
                thumbnail: Discord::EmbedThumbnail.new(
					url: cache.resolve_user(client.client_id).avatar_url
				),
                fields: [
                    Discord::EmbedField.new(
						name: "main",
						value: "guilds: `#{cache.guilds.size}`"
					),
                    Discord::EmbedField.new(
                        name: "versions",
                        value: "project: `#{Am::VERSION}`\ncrystal: `#{Crystal::VERSION}`\nllvm: `#{Crystal::LLVM_VERSION}`"
                    )
                ],
                timestamp: Time.utc
            )
        end
        client.create_message(
            channel_id: message.channel_id,
            content: "",
            embed: embed
        )
    end
end