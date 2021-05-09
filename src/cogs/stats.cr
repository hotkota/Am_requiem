require "redis"
require "discordcr"

module Command
    def stats(client, cache, message, redis_tags, db_stats)
        if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
            embed = Discord::Embed.new(
                title: "Статистика",
                colour: 0xff5587,
                thumbnail: Discord::EmbedThumbnail.new(
                    url: cache.resolve_user(client.client_id).avatar_url
                ),
                fields: [
                    Discord::EmbedField.new(
                        name: "Сервера",
                        value: "`#{cache.guilds.size}`"
                    ),
                    Discord::EmbedField.new(
                        name: "База данных",
                        value: "теги: `#{Redis.open(database: redis_tags) { |redis| redis.keys("*").size} }`"
                    ),
                    Discord::EmbedField.new(
                        name: "Память",
                        value: "выделено: `#{(GC.stats.heap_size/1000/1000).round(0).to_i} mb`\nиспользуется: `#{(GC.stats.total_bytes/1000/1000).round(0).to_i} mb`\nсвободно: `#{(GC.stats.free_bytes/1000/1000).round(0).to_i} mb`"
                    ),
                ],
                timestamp: Time.utc
            )
        else
            embed = Discord::Embed.new(
                title: "Statistics",
                colour: 0xff5587,
                thumbnail: Discord::EmbedThumbnail.new(
                    url: cache.resolve_user(client.client_id).avatar_url
                ),
                fields: [
                    Discord::EmbedField.new(
                        name: "Guilds",
                        value: "`#{cache.guilds.size}`"
                    ),
                    Discord::EmbedField.new(
                        name: "Database",
                        value: "tags: `#{Redis.open(database: redis_tags) { |redis| redis.keys("*").size} }`"
                    ),
                    Discord::EmbedField.new(
                        name: "Memory",
                        value: "allocated `#{(GC.stats.heap_size/1000/1000).round(0).to_i} mb`\nused: `#{(GC.stats.total_bytes/1000/1000).round(0).to_i} mb`\nfree: `#{(GC.stats.free_bytes/1000/1000).round(0).to_i} mb`"
                    )
                ],
                timestamp: Time.utc
            )
        end
        client.create_message(message.channel_id, "", embed)
    end
end