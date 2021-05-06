require "redis"

module Command
    def tags(client, message, db)
        content = (message.content).split(" ", limit: 3, remove_empty: true)
        content.shift
        if content[0] == "create" || content[0] == "создать"
            if content[1].split("|", limit: 3, remove_empty: true).size == 2
                Redis.open(database: db) do |redis|
                    data = content[1].split("|", limit: 3, remove_empty: true)
                    redis.set(data[0].strip, data[1].strip)
                end
                client.create_reaction(message.channel_id, message.id, "✔")
            else
                client.create_reaction(message.channel_id, message.id, "❌")
            end
        elsif content[0] == "delete" || content[0] == "удалить"
            Redis.open(database: db) do |redis|
                if redis.get(content[1]).nil?
                    client.create_reaction(message.channel_id, message.id, "❌")
                else
                    redis.del(content[1])
                    client.create_reaction(message.channel_id, message.id, "✔")
                end 
            end
        else
            Redis.open(database: db) do |redis|
                if !redis.get(content[0]).nil?
                    client.create_message(message.channel_id, redis.get(content[0]).not_nil!)
                end 
            end
        end
    end
end