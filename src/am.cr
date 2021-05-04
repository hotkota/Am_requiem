require "yaml"
require "discordcr"

# TODO: Write documentation for `Bot`
module Am
  VERSION = "0.1.0"

  # TODO: Put your code here
  client = Discord::Client.new(token: "Bot #{YAML.parse(File.open("./config.yml"))["token"].as_s}", client_id: (YAML.parse(File.open("./config.yml"))["client_id"]).as_i64.to_u64, intents: Discord::Gateway::Intents::Guilds | Discord::Gateway::Intents::GuildMessages)

  client.on_message_create do |message|
    if message.content.starts_with? "!ping"
      client.create_message(message.channel_id, "Pong!")
    end
  end
  
  client.run
end
