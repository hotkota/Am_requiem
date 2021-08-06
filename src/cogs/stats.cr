require "../am"
require "redis"
require "discordcr"

module Command
	def stats(client, cache, message, redis_tags)
		embed = Discord::Embed.new(
			colour: 0xff5587,
			thumbnail: Discord::EmbedThumbnail.new(
				url: cache.resolve_user(client.client_id).avatar_url
			),
			timestamp: Time.utc
		)
		if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
			embed.title = "Статистика"
			embed.fields = [
				Discord::EmbedField.new(
					name: "Основное",
					value: "серверов: `#{cache.guilds.size}`"
				),
				Discord::EmbedField.new(
					name: "База данных",
					value: "теги: `#{Redis.open(database: redis_tags) { |redis| redis.keys("*").size} }`"
				),
				Discord::EmbedField.new(
					name: "Память",
					value: "выделено: `#{(GC.stats.total_bytes/1000/1000).round(0).to_i} mb`\nиспользуется: `#{(GC.stats.heap_size/1000/1000).round(0).to_i} mb`\nрезерв: `#{(GC.stats.free_bytes/1000/1000).round(0).to_i} mb`"
				),
			]
		else
			embed.title = "Statistics"
			embed.fields = [
				Discord::EmbedField.new(
					name: "Guilds",
					value: "`#{cache.guilds.size}`"
				),
				Discord::EmbedField.new(
					name: "Database",
					value: "tags: `#{Redis.open(database: redis_tags) { |redis| redis.keys("*").size} }`"
				),
				Discord::EmbedField.new(
					name: "Memory",
					value: "allocated `#{(GC.stats.total_bytes/1000/1000).round(0).to_i} mb`\nused: `#{(GC.stats.heap_size/1000/1000).round(0).to_i } mb`\nfree: `#{(GC.stats.free_bytes/1000/1000).round(0).to_i} mb`"
				),
			]
		end
		client.create_message(message.channel_id, "", embed)
	end
end