module Command
    def prefix_find(client, message, cache, prefix)
        if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
            client.create_message(message.channel_id, "Мой префикс для этого сервера: `#{prefix}`")
        else
            client.create_message(message.channel_id, "My prefix for guild: #{prefix}")
        end
    end
end