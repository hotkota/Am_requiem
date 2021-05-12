require "yaml"
require "redis"

module Event
    def member_join(client, member_payload, redis_db)
        Redis.open(database: redis_db) do |redis|
            data = YAML.parse(redis.get(member_payload.guild_id.to_s).not_nil!)
            if !data["hello_channel"].as_s?.nil?
                client.create_message(data["hello"]["hello_channel"].as_s?.not_nil!.to_u64, "#{member_payload.nick} join")
            end
        end
    end
end