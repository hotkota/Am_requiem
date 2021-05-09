require "yaml"
require "redis"
require "discordcr"

module Command
    def set_log_channel(client, cache, message, redis_db, prefix)
        if cache.resolve_guild(message.guild_id.not_nil!.to_u64).owner_id.to_s == message.author.id.to_s
            set_log(client, cache, message, redis_db, prefix)
        elsif !message.member.not_nil!.roles.empty?
            message.member.not_nil!.roles.each_with_index do |role, i|
                role = cache.resolve_role(role)
                if role.permissions.administrator? || role.permissions.manage_guild?
                    set_log(client, cache, message, redis_db, prefix)
                    break
                elsif i == message.member.not_nil!.roles.size
                    client.create_reaction(message.channel_id, message.id, "❌")
                end
            end
        else
            client.create_reaction(message.channel_id, message.id, "❌")   
        end
    end

    private def set_log(client, cache, message, redis_db, prefix)
        content = message.content.lchop("#{prefix}logs").lchop("#{prefix}логи").strip()
        if (content.starts_with? "<#") && (content.ends_with? ">")
            if !content.lchop("<#").rchop(">").to_u64?.nil?
                Redis.open(database: redis_db) do |redis|
                    data = YAML.parse(redis.get(cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s).not_nil!)
                    redis.set(
                        cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s,
                        {
                            "prefix" => data["prefix"].as_s,
                            "premium" => data["premium"].as_bool,
                            "log_channel" => content.lchop("<#").rchop(">").to_s,
                            "hello_channel" => data["hello_channel"].as_s?,
                            "leave_channel" => data["leave_channel"].as_s?
                        }.to_yaml.to_s
                    )
                    client.create_reaction(message.channel_id, message.id, "✔")
                end
            else
                if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
                    embed = Discord::Embed.new(
                        title: "Ошибка",
                        colour: 0xff3300,
                        description: "Укажите текстовый канал",
                        timestamp: Time.utc
                    )
                else
                    embed = Discord::Embed.new(
                        title: "error",
                        colour: 0xff3300,
                        description: "select text channel",
                        timestamp: Time.utc
                    )
                end
                client.create_message(message.channel_id, "", embed)
            end
        elsif !content.to_u64?.nil?
            Redis.open(database: redis_db) do |redis|
                data = YAML.parse(redis.get(cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s).not_nil!)
                redis.set(
                    cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s,
                    {
                        "prefix" => data["prefix"].as_s,
                        "premium" => data["premium"].as_bool,
                        "log_channel" => content.lchop("<#").rchop(">").to_s,
                        "hello_channel" => data["hello_channel"].as_s?,
                        "leave_channel" => data["leave_channel"].as_s?
                    }.to_yaml.to_s
                )
                client.create_reaction(message.channel_id, message.id, "✔")
            end
        elsif (content == "remove") || (content == "удалить")
            Redis.open(database: redis_db) do |redis|
                data = YAML.parse(redis.get(cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s).not_nil!)
                if !data["log_channel"].as_s?.nil?
                    redis.set(
                        cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s,
                        {
                            "prefix" => data["prefix"].as_s,
                            "premium" => data["premium"].as_bool,
                            "log_channel" => nil,
                            "hello_channel" => data["hello_channel"].as_s?,
                            "leave_channel" => data["leave_channel"].as_s?
                        }.to_yaml.to_s
                    )
                    client.create_reaction(message.channel_id, message.id, "✔")
                else
                    client.create_reaction(message.channel_id, message.id, "✔")
                end
            end
        elsif content == "?"
            if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
                embed = Discord::Embed.new(
                    title: "хелп `#{prefix}логи`",
                    colour: 0xff5587,
                    fields: [
                        Discord::EmbedField.new(
                            name: "#{prefix}логи *#название_канала*",
                            value: "задать логи сервера"
                        ),
                        Discord::EmbedField.new(
                            name: "#{prefix}логи удалить",
                            value: "убрать отображения логов"
                        ),
                    ],
                )
            else
                embed = Discord::Embed.new(
                    title: "help `#{prefix}logs`",
                    colour: 0xff5587,
                    fields: [
                        Discord::EmbedField.new(
                            name: "#{prefix}logs *#channel_name*",
                            value: "set log channel"
                        ),
                        Discord::EmbedField.new(
                            name: "#{prefix}logs remove",
                            value: "remove logs"
                        ),
                    ],
                )
            end
            client.create_message(message.channel_id, "", embed)
        else
            if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
                embed = Discord::Embed.new(
                    title: "Ошибка",
                    colour: 0xff3300,
                    description: "Укажите текстовый канал",
                    timestamp: Time.utc
                )
            else
                embed = Discord::Embed.new(
                    title: "error",
                    colour: 0xff3300,
                    description: "select text channel",
                    timestamp: Time.utc
                )
            end
            client.create_message(message.channel_id, "", embed)
        end
    end
end