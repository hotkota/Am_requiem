require "yaml"
require "redis"
require "discordcr"

module Command
	def tags(client, message, db, prefix, cache)
		content = message.content.lchop("#{prefix}tag").lchop("#{prefix}тег").strip().split(" ", limit: 2, remove_empty: true)
		if !content.empty?
			case content[0].strip
			when "create", "создать"
				if content[1].split("|", limit: 2, remove_empty: true).size == 2
					Redis.open(database: db) do |redis|
						data = content[1].split("|", limit: 2, remove_empty: true)
						redis.set(
							data[0].strip,
							{
								"value": data[1].strip,
								"author": message.author.id.to_u64,
								"guild": message.guild_id.not_nil!.to_u64,
								"timestamp": Time.utc.to_s
							}.to_yaml
						)
					end
					client.create_reaction(message.channel_id, message.id, "✔")
				else
					client.create_reaction(message.channel_id, message.id, "❌")
				end
			when "delete", "удалить"
				Redis.open(database: db) do |redis|
					if redis.get(content[1]).nil?
						client.create_reaction(message.channel_id, message.id, "❌")
					else
						redis.del(content[1])
						client.create_reaction(message.channel_id, message.id, "✔")
					end
				end
			when "info", "инфо"
				Redis.open(database: db) do |redis|
					if !redis.get(content[1].strip).nil?
						data = YAML.parse(redis.get(content[1]).not_nil!)
						if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
							embed = Discord::Embed.new(
								title: "тег инфо",
								colour: 0xff5587,
								thumbnail: Discord::EmbedThumbnail.new(
									url: cache.resolve_user(data["author"].as_i64.to_u64).avatar_url
								),
								fields: [
									Discord::EmbedField.new(
										name: "тег",
										value: "имя: #{content[1]}\nсодержимое: #{data["value"]}"
									),
									Discord::EmbedField.new(
										name: "автор",
										value: "ник: `#{cache.resolve_user(data["author"].as_i64.to_u64).username}##{cache.resolve_user(data["author"].as_i64.to_u64).discriminator}\n`id: `#{data["author"]}`"
									),
									Discord::EmbedField.new(
										name: "создан",
										value: "`#{data["timestamp"].as_s}`"
									)
								],
								timestamp: Time.utc
							)
						else
							embed = Discord::Embed.new(
								title: "tag info",
								colour: 0xff5587,
								thumbnail: Discord::EmbedThumbnail.new(
									url: cache.resolve_user(data["author"].as_i64.to_u64).avatar_url
								),
								fields: [
									Discord::EmbedField.new(
										name: "tag",
										value: "name: #{content[1]}\nvalue: #{data["value"]}"
									),
									Discord::EmbedField.new(
										name: "author",
										value: "nickname: `#{cache.resolve_user(data["author"].as_i64.to_u64).username}##{cache.resolve_user(data["author"].as_i64.to_u64).discriminator}\n`id: `#{data["author"]}`"
									),
									Discord::EmbedField.new(
										name: "create at",
										value: "`#{data["timestamp"].as_s}`"
									)
								],
								timestamp: Time.utc
							)
						end
						client.create_message(message.channel_id, "", embed)
					else
						client.create_reaction(message.channel_id, message.id, "❌")
					end
				end
			when "?"
				if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
					embed = Discord::Embed.new(
						title: "хелп `#{prefix}тег`",
						colour: 0xff5587,
						thumbnail: Discord::EmbedThumbnail.new(
							url: cache.resolve_user(client.client_id).avatar_url
						),
						fields: [
							Discord::EmbedField.new(
								name: "#{prefix}тег *название*",
								value: "`вывести значение тега`"
							),
							Discord::EmbedField.new(
								name: "#{prefix}тег инфо *название*",
								value: "`информация о теге`"
							),
							Discord::EmbedField.new(
								name: "#{prefix}тег удалить *название*",
								value: "`удалить тег навсегда`"
							),
							Discord::EmbedField.new(
								name: "#{prefix}тег создать *имя* | *значение*",
								value: "`создать тег`"
							),
							Discord::EmbedField.new(
								name: "#{prefix}тег alias *название* | *новое_название*",
								value: "новый тег с тем же названием"
							)
						],
						timestamp: Time.utc
					)
				else
					embed = Discord::Embed.new(
						title: "help `#{prefix}tag`",
						colour: 0xff5587,
						thumbnail: Discord::EmbedThumbnail.new(
							url: cache.resolve_user(client.client_id).avatar_url
						),
						fields: [
							Discord::EmbedField.new(
								name: "#{prefix}tag *name*",
								value: "`outputs the value of the tag`"
							),
							Discord::EmbedField.new(
								name: "#{prefix}tag info *name*",
								value: "`info about tag`"
							),
							Discord::EmbedField.new(
								name: "#{prefix}tag delete *name*",
								value: "`remove tag`"
							),
							Discord::EmbedField.new(
								name: "#{prefix}tag create *name* | *value*",
								value: "`create tag`"
							),
							Discord::EmbedField.new(
								name: "#{prefix}tag alias *name* | *new_name*",
								value: ":shrimp:"
							),
						],
						timestamp: Time.utc
					)
				end
				client.create_message(message.channel_id, "", embed)
			when "alias"
				Redis.open(database: db) do |redis|
					if content[1].split("|", limit: 2, remove_empty: true).size == 2
						content = content[1].split("|", limit: 2, remove_empty: true)
						if !redis.get(content[0].to_s.strip).nil?
							redis.set(
								content[1].to_s.strip,
								redis.get(content[0].to_s.strip).not_nil!
							)
							client.create_reaction(message.channel_id, message.id, "✔")
						else
							client.create_reaction(message.channel_id, message.id, "❌")
						end
					else
						client.create_reaction(message.channel_id, message.id, "❌")
					end
				end
			else
				Redis.open(database: db) do |redis|
					if !redis.get(message.content.lchop("#{prefix}tag").lchop("#{prefix}тег").strip()).nil?
						content = YAML.parse(redis.get(message.content.lchop("#{prefix}tag").lchop("#{prefix}тег").strip()).not_nil!)["value"].as_s
						if (!content.index("@everyone").nil?) || (!content.index("@here").nil?)
							client.create_message(message.channel_id, "", Discord::Embed.new(
									colour: 0xff5587,
									description: content
								)
							)
						else
							client.create_message(message.channel_id, content)
						end
					else
						client.create_reaction(message.channel_id, message.id, "❌")
					end
				end
			end
		end
	end
end
