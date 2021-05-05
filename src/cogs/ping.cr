module Command
    def ping(client, cache, message)
        if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
            m = client.create_message(message.channel_id, "Понг!")
            client.edit_message(m.channel_id, m.id, "Понг! Задержка: #{(Time.utc - message.timestamp).total_milliseconds} мс.")
        else
            m = client.create_message(message.channel_id, "Pong!")
            client.edit_message(m.channel_id, m.id, "Pong! Time taken: #{(Time.utc - message.timestamp).total_milliseconds} ms.")
        end
    end
end