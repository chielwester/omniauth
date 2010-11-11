require 'omniauth/openid'

module OmniAuth
  module Strategies
    class Hyves < OmniAuth::Strategies::OpenID
      def initialize(app, store = nil, options = {})
        options[:name] ||= 'hyves'
        super(app, store, options)
      end

      def identifier
        "http://hyves.nl"
      end
    end
  end
end