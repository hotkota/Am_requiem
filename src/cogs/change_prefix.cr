require "yaml"
require "redis"

module Command
    def prefix(client, cache, message, redis_db, prefix)
        if cache.resolve_guild(message.guild_id.not_nil!.to_u64).owner_id.to_s == message.author.id.to_s
            change_prefix(client, cache, message, redis_db, prefix)
        elsif !message.member.not_nil!.roles.empty?
            message.member.not_nil!.roles.each_with_index do |role, i|
                role = cache.resolve_role(role)
                if role.permissions.administrator? || role.permissions.manage_guild?
                    change_prefix(client, cache, message, redis_db, prefix)
                    break
                elsif i == message.member.not_nil!.roles.size
                    client.create_reaction(message.channel_id, message.id, "❌")
                end
            end
        else
            client.create_reaction(message.channel_id, message.id, "❌")    
        end
    end

    private def change_prefix(client, cache, message, redis_db, prefix)
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