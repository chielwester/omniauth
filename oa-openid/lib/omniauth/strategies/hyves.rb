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

      protected

      def ax_user_info(response)
        super.merge(
          {
            'street' => street(ax),
            'house_number' => house_number(ax),
            'house_number_addition' => house_number_addition(ax)
          }
        )
      end

      def street(ax)
        ax.get_single(AX[:street]).to_s.split(/\s/)[1.. -1].join(' ')
      end

      def house_number(ax)
        ax.get_single(AX[:street]).to_s.split(/\s/).first.scan(/^[0-9]+/).first
      end

      def house_number_addition(ax)
        ax.get_single(AX[:street]).to_s.split(/\s/).first.scan(/[A-Za-z]+/).first
      end
    end
  end
end