require "redis"

module Command
    def message_reaction(client, message, db)
        Redis.open(database: db) do |redis|
            client.create_reaction(message.channel_id, message.id, "🦐")
            redis.set(message.id.to_s, true)
            redis.expire(message.id.to_s, 160)
            client.create_message(message.channel_id, "ок")
        end
    end
end