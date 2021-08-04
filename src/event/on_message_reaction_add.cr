require "redis"
require "discordcr"

module Event
    def message_reaction_add(client, cache, handler, db)
        if !cache.resolve_user(handler.user_id).bot
            Redis.open(database: db) do |redis|
                if redis.exists(handler.message_id.to_s)
                    if handler.emoji.id.nil?
                        client.create_message(handler.channel_id, "#{cache.resolve_user(handler.user_id).username} нажал на: #{handler.emoji.name}")
                    else
                        client.create_message(handler.channel_id, "#{cache.resolve_user(handler.user_id).username} нажал на: <:#{handler.emoji.name}:#{handler.emoji.id.to_s}>")
                    end
                end
            end
        end
    end
end