require "discordcr"

module Command
    def help(client, cache, message, prefix)
        if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
            embed = Discord::Embed.new(
                title: "Помощь",
                colour: 0xff5587,
                fields: [
                    Discord::EmbedField.new(
                        name: "Информация",
                        value: "`#{prefix}хелп` `#{prefix}пинг`"
                    ),
                ],
                timestamp: Time.utc
            )
            client.create_message(message.channel_id, "", embed)
        else
            embed = Discord::Embed.new(
                title: "Help",
                colour: 0xff5587,
                fields: [
                    Discord::EmbedField.new(
                        name: "info",
                        value: "`#{prefix}help` `#{prefix}ping`"
                    ),
                ],
                timestamp: Time.utc
            )
            client.create_message(message.channel_id, "", embed)
        end
    end
end