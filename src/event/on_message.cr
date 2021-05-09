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
							"hello_channel" => nil,
							"hello_message" => nil,
							"leave_channel" => nil,
							"leave_message" => nil,
						}.to_yaml.to_s
					)
				end
			end

			Redis.open(database: Redis_DB_Guild) do |redis|
				prefix = YAML.parse(redis.get(cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s).not_nil!)["prefix"]
				if (message.content.starts_with? "#{prefix}ping") || (message.content.starts_with? "#{prefix}пинг")
					Commands.ping(client, cache, message)
				elsif (message.content.starts_with? "#{prefix}tag") || (message.content.starts_with? "#{prefix}тег")
					Commands.tags(client, message, Config::Redis["tags"], prefix, cache)
				elsif (message.content.starts_with? "#{prefix}help") || (message.content.starts_with? "#{prefix}хелп")
					Commands.help(client, cache, message, prefix)
				elsif (message.content.starts_with? "#{prefix}bonus") || (message.content.starts_with? "#{prefix}бонус")
					Commands.premium(client, cache, message, Redis_DB_Member)
				elsif (message.content.starts_with? "#{prefix}prefix") || (message.content.starts_with? "#{prefix}префикс")
					Commands.prefix(client, cache, message, Redis_DB_Guild, prefix)
				elsif (message.content =="<@#{Config::Client_id}>")
					Commands.prefix_find(client, message, cache, prefix)
				elsif (message.content.starts_with? "#{prefix}logs") || (message.content.starts_with? "#{prefix}логи")
					Commands.set_log_channel(client, cache, message, Redis_DB_Guild, prefix)
				elsif (message.content.starts_with? "#{prefix}stat") || (message.content.starts_with? "#{prefix}стат")
					Commands.stats(client, cache, message, Config::Redis["tags"], Config::Redis["stats"])
				end
			end
		end
	end
end