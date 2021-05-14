require "../text_engine"

module Command
    def render(client, cache, message)
        render_engine = TextEngine::Messages.new
        client.create_message(message.channel_id, render_engine.message(cache, message))
    end
end