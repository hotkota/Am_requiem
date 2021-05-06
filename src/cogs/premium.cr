require "yaml"
require "redis"

module Command
    def premium(client, cache, message, redis_db)
        Redis.open(database: redis_db) do |redis|
            member = YAML.parse(redis.get(message.author.id.to_s).not_nil!)

            content = (message.content).split(" ", limit: 3, remove_empty: true)
            content.shift

            if member["premium"]
                
            else
                
            end
        end
    end
end