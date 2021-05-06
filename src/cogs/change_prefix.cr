require "yaml"
require "redis"

module Command
    def prefix(client, cache, message, redis_db, prefix)
        Redis.open(database: redis_db) do |redis|
            redis.set(
                cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s,
                {
                    "prefix" => message.content.lchop("#{prefix}prefix").lchop("#{prefix}префикс").sub("\\s", " ").lstrip().to_s,
                    "premium" => YAML.parse(redis.get(cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s).not_nil!)["premium"].as_bool
                }.to_yaml.to_s
            )
            client.create_reaction(message.channel_id, message.id, "✔")
        end
    end
end