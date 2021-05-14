require "discordcr"
require "crustache"

module TextEngine
    struct Messages
        def member_add_message(text : String, cache : Discord::Cache, member_payload : Discord::Gateway::GuildMemberAddPayload) : String
            text = Crustache.parse(text)
            model = {
                "member_id" => member_payload.user.id,
                "username" => member_payload.user.username,
                "guild_id" => member_payload.guild_id,
                "guild_name" => cache.resolve_guild(member_payload.guild_id).name
            }
            return Crustache.render(text, model)
        end

        def message(cache : Discord::Cache, message : Discord::Message) : String
            text = Crustache.parse(message.content)
            model = {
                "author_id" => message.author.id,
                "message_id" => message.id,
                "author_name" => message.author.username
            }
            return Crustache.render(text, model)
        end
    end
end