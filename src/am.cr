require "yaml"
require "discordcr"

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
      if cache.resolve_guild(message.guild_id.not_nil!.to_u64).region == "russia"
        m = client.create_message(message.channel_id, "Понг!")
        client.edit_message(m.channel_id, m.id, "Понг! Задержка: #{(Time.utc - message.timestamp).total_milliseconds} мс.")
      else
        m = client.create_message(message.channel_id, "Pong!")
        client.edit_message(m.channel_id, m.id, "Pong! Time taken: #{(Time.utc - message.timestamp).total_milliseconds} ms.")
      end
    end
  end
  
  client.run
end
