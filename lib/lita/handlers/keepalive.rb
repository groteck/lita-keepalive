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
        !config.end_time.nil? &&
          Time.now.strftime('%H').to_i > config.end_hour
      end

      on(:loaded) do
        log.info "Starting Keepalive to #{config.url}/ping"
        every(config.minutes * 60) do
          log.info 'Trying to run Keepalive!!!'
          log.info workin_hours?

          if workin_hours?
            log.info 'Out of working hours!!!'
            next
          end
          log.info 'Keepalive ping...'
          http.get "#{config.url}/ping"
        end
      end

    end

    Lita.register_handler(Keepalive)
  end
end
