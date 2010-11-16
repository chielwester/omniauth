require 'omniauth/oauth'

module OmniAuth
  module Strategies
    # Authenticate with Windows LiveID via Oauth WRAP and retrieve basic user information
    #
    class LiveId < OmniAuth::Strategies::OAuth
      def initialize(app, client_id, secret_key, options = {})
        client_options = {
          :site => 'https://consent.live.com',
          :request_token_path => '/Connect.aspx'
        }
        super(app, :live_id, client_id, secret_key, client_options, options)
      end
    end
  end
end