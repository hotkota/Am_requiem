require "yaml"
require "redis"
require "../config"
require "../settings"
require "../cogs/init"

Redis_DB_Member = Config::Redis["members"]
Redis_DB_Guild = Config::Redis["guilds"]

module Event
	def on_message(client, cache, message)
		if !message.author.bot
			Redis.open(database: Redis_DB_Member) do |redis|
				if redis.get(message.author.id.to_s).nil?
					redis.set(
						message.author.id.to_s,
						{
							"permission" => Permission::No.value,
							"premium" => false,
							"count_premium" => 0,
							"premium_guilds" => [] of UInt64
						}.to_yaml.to_s
					)
				end
			end

			Redis.open(database: Redis_DB_Guild) do |redis|
				if redis.get(cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s).nil?
					redis.set(
						cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s,
						{
							"prefix" => "//",
							"premium" => false,
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

			Redis.open(database: Redis_DB_Guild) do |redis|
				prefix = YAML.parse(redis.get(cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s).not_nil!)["prefix"].as_s
				case message.content.lchop(prefix).strip().split(" ", remove_empty: true)[0]
				when "ping", "пинг"
					Commands.ping(client, cache, message)
				when "tag", "тег"
					Commands.tags(client, message, Config::Redis["tags"], prefix, cache)
				when "help", "хелп"
					Commands.help(client, cache, message, prefix)
				when "prefix", "префикс"
					Commands.prefix(client, cache, message, Redis_DB_Guild, prefix)
				when "logs", "логи"
					Commands.set_log_channel(client, cache, message, Redis_DB_Guild, prefix)
				when "stat", "стат"
					Commands.stats(client, cache, message, Config::Redis["tags"])
				else
					if message.content == "<@#{client.client_id}>"
						Commands.prefix_find(client, message, cache, prefix)
					end
				end
			end
		end
	end
end