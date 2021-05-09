module Event
    def guild_delete(cache, guild)
        if guild.unavailable.nil?
            cache.delete_guild(guild.id) 
        end
    end
end