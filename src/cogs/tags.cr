require "redis"
require "discordcr"

module Command
    def tags(client, message, db, prefix, cache)
        content = message.content.lchop("#{prefix}tag").lchop("#{prefix}тег").strip().split(" ", limit: 2, remove_empty: true)
        if !content.empty?
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
            elsif content[0] == "?"
                if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
                    embed = Discord::Embed.new(
                        title: "хелп `#{prefix}тег`",
                        colour: 0xff5587,
                        fields: [
                            Discord::EmbedField.new(
                                name: "#{prefix}тег название",
                                value: "`вывести значение тега`"
                            ),
                            Discord::EmbedField.new(
                                name: "#{prefix}тег удалить название",
                                value: "`удалить тег навсегда`"
                            ),
                            Discord::EmbedField.new(
                                name: "#{prefix}тег создать имя | значение",
                                value: "`создать тег`"
                            ),
                        ],
                        timestamp: Time.utc
                    )
                else
                    embed = Discord::Embed.new(
                        title: "help `#{prefix}тег`",
                        colour: 0xff5587,
                        fields: [
                            Discord::EmbedField.new(
                                name: "#{prefix}tag name",
                                value: "`outputs the value of the tag`"
                            ),
                            Discord::EmbedField.new(
                                name: "#{prefix}tag delete name",
                                value: "`remove tag`"
                            ),
                            Discord::EmbedField.new(
                                name: "#{prefix}tag create name | value",
                                value: "`create tag`"
                            ),
                        ],
                        timestamp: Time.utc
                    )
                end
                client.create_message(message.channel_id, "", embed)
            else
                Redis.open(database: db) do |redis|
                    if !redis.get(content[0]).nil?
                        client.create_message(message.channel_id, redis.get(content[0]).not_nil!)
                    else
                        client.create_reaction(message.channel_id, message.id, "❌")
                    end 
                end
            end
        end
    end
end