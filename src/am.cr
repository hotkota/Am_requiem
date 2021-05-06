require "yaml"
require "redis"
require "discordcr"
require "./settings"
require "./cogs/init"

# TODO: Write documentation for `Bot`
module Am
  VERSION = "0.1.0"

  # TODO: Put your code here
  client = Discord::Client.new(token: "Bot #{YAML.parse(File.open("./config.yml"))["token"].as_s}", client_id: (YAML.parse(File.open("./config.yml"))["client_id"]).as_i64.to_u64, intents: Discord::Gateway::Intents::Guilds | Discord::Gateway::Intents::GuildMessages)
  cache = Discord::Cache.new(client)
  client.cache = cache

  PREFIX = YAML.parse(File.open("./config.yml"))["prefix"].as_s

  Redis_DB_Member = YAML.parse(File.open("./config.yml"))["redis"]["members"].as_i
  Redis_DB_Guild = YAML.parse(File.open("./config.yml"))["redis"]["guilds"].as_i

  client.on_message_create do |message|
    if !message.author.bot
      Redis.open(database: Redis_DB_Member) do |redis|
        if redis.get(message.author.id.to_s).nil?
          redis.set(
            message.author.id.to_s,
            {"permission"=>Permission::No.value, "premium"=>false, "count_premium"=>0, "premium_guilds"=>[] of UInt64}.to_yaml.to_s
          )
        end
      end
      Redis.open(database: Redis_DB_Guild) do |redis|
        if redis.get(cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s).nil?
          redis.set(
            cache.resolve_guild(message.guild_id.not_nil!.to_u64).id.to_s,
            {"prefix"=>PREFIX, "premium"=>false}.to_yaml.to_s
          )
        end
      end
      if (message.content.starts_with? "#{PREFIX}ping") || (message.content.starts_with? "#{PREFIX}пинг")
        Commands.ping(client, cache, message)
      elsif (message.content.starts_with? "#{PREFIX}tag") || (message.content.starts_with? "#{PREFIX}тег")
        Commands.tags(client, message, YAML.parse(File.open("./config.yml"))["redis"]["tags"].as_i)
      elsif (message.content.starts_with? "#{PREFIX}help") || (message.content.starts_with? "#{PREFIX}хелп")
        Commands.help(client, cache, message, PREFIX)
      end
    end
  end
  
  client.run
end
