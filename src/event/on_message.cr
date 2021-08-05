require "yaml"
require "redis"
require "../config"
require "../cogs/init"

module Event
	def on_message(client, cache, message)
		if !message.author.bot
			if !(cache.resolve_channel(message.channel_id).type.dm?)
				Redis.open(database: Config::Redis["guilds"]) do |redis|
					if redis.get(message.guild_id.not_nil!.to_s).nil?
						redis.set(
							message.guild_id.not_nil!.to_s,
							{
								"prefix" => "//",
								"log_channel" => nil,
								"hello" => {
									"hello_channel" => nil,
									"hello_message" => nil
								},
								"leave" => {
									"leave_channel" => nil,
									"leave_message" => nil
								}
							}.to_yaml.to_s
						)
					end
				end
			end

			Redis.open(database: Config::Redis["guilds"]) do |redis|
				prefix = YAML.parse(redis.get(message.guild_id.not_nil!.to_s).not_nil!)["prefix"].as_s

				if message.content.strip == "<@#{client.client_id}>"
					Commands.prefix_find(client, message, cache, prefix)
				end

				return if !message.content.starts_with?(prefix)

				case message.content.lchop(prefix).strip.split(" ", remove_empty: true)[0]
				when "ping", "пинг"
					Commands.ping(client, cache, message)
				when "tag", "тег"
					Commands.tags(client, message, Config::Redis["tags"], prefix, cache)
				when "help", "хелп"
					Commands.help(client, cache, message, prefix)
				when "prefix", "префикс"
					Commands.prefix(client, cache, message, Config::Redis["guilds"], prefix)
				when "logs", "логи"
					Commands.set_log_channel(client, cache, message, Config::Redis["guilds"], prefix)
				when "stat", "стат"
					Commands.stats(client, cache, message, Config::Redis["tags"])
				when "bot", "бот"
					Commands.info(client, cache, message)
				when "reaction", "реакции"
					Commands.message_reaction(client, message, Config::Redis["reaction"])
				end
			end
		end
	end
end