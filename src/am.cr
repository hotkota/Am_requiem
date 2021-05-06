require "yaml"
require "discordcr"
require "./event/init"

# TODO: Write documentation for `Bot`
module Am
  VERSION = "0.1.0"

  # TODO: Put your code here
  client = Discord::Client.new(token: "Bot #{YAML.parse(File.open("./config.yml"))["token"].as_s}", client_id: (YAML.parse(File.open("./config.yml"))["client_id"]).as_i64.to_u64, intents: Discord::Gateway::Intents::Guilds | Discord::Gateway::Intents::GuildMessages)
  cache = Discord::Cache.new(client)
  client.cache = cache

  client.on_ready do
    Events.on_ready(client)
  end

  client.on_message_create do |message|
    Events.on_message(client, cache, message)
  end
  
  client.run
end
