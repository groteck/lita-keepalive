module Lita
  module Handlers
    class Keepalive < Handler
      config :url, required: true, type: String
      config :minutes, required: true, type: Integer
      config :end_hour, required: false, type: Integer

      http.get '/ping' do |request, response|
        response.body << "pong"
      end

      def workin_hours?
        log.debug config.end_hour
        log.debug Time.now.strftime('%H')

        !config.end_hour.nil? &&
          Time.now.strftime('%H').to_i < config.end_hour
      end

      on(:loaded) do
        log.debug "Starting Keepalive to #{config.url}/ping"

        every(config.minutes * 60) do
          log.debug 'Trying to run Keepalive!!!'

          if workin_hours?
            log.info 'Keepalive the bot we are working, ping...'
            http.get "#{config.url}/ping"
          else
            log.info 'Out of working hours going to sleep!!!'
          end
        end
      end
    end

    Lita.register_handler(Keepalive)
  end
end
