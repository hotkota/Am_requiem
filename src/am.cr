require "log"
require "yaml"
require "./config"
require "discordcr"
require "./event/init"

# TODO: Write documentation for `Bot`
module Am
	VERSION = "1.0.0"

	# TODO: Put your code here
	Log.setup(:notice)
	client = Discord::Client.new(
		token: "Bot #{Config::Token}",
		client_id: Config::Client_id,
		intents: Discord::Gateway::Intents::Guilds | Discord::Gateway::Intents::GuildMessages | Discord::Gateway::Intents::GuildMessageReactions
	)
	cache = Discord::Cache.new(client)
	client.cache = cache

	client.on_ready do
		Events.on_ready(client)
	end

	client.on_message_create do |message|
		Events.on_message(client, cache, message)
	end

	client.on_guild_delete do |guild|
		Events.guild_delete(cache, guild)
	end

	client.on_message_reaction_add do |handler|
		Events.message_reaction_add(client, cache, handler, Config::Redis["reaction"])
	end

	client.run
end
