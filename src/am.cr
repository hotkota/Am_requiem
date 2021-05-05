require "yaml"
require "redis"
require "discordcr"
require "./cogs/init"

# TODO: Write documentation for `Bot`
module Am
  VERSION = "0.1.0"

  # TODO: Put your code here
  client = Discord::Client.new(token: "Bot #{YAML.parse(File.open("./config.yml"))["token"].as_s}", client_id: (YAML.parse(File.open("./config.yml"))["client_id"]).as_i64.to_u64, intents: Discord::Gateway::Intents::Guilds | Discord::Gateway::Intents::GuildMessages)
  cache = Discord::Cache.new(client)
  client.cache = cache

  PREFIX = YAML.parse(File.open("./config.yml"))["prefix"].as_s

  client.on_message_create do |message|
    if (message.content.starts_with? "#{PREFIX}ping") || (message.content.starts_with? "#{PREFIX}пинг")
      Commands.ping(client, cache, message)
    elsif (message.content.starts_with? "#{PREFIX}tag") || (message.content.starts_with? "#{PREFIX}тег")
      Commands.tags(client, message)
    end
  end
  
  client.run
end
