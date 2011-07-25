require 'omniauth/openid'
require 'oauth'

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

      def dummy_app
        return lambda{|env| [401, {"WWW-Authenticate" => Rack::OpenID.build_header(
          :identifier => identifier,
          :return_to => callback_url,
          :required => @options[:required],
          :optional => @options[:optional],
          :"oauth[consumer]" => @options[:consumer_key],
          :"oauth[scope]" => @options[:scope],
          :method => 'post'
        )}, []]}
      end

      def access_token_path
        "http://data.hyves-api.nl/?#{access_token_options}&#{default_options}"
      end

      def default_options
        to_params({:ha_version => '2.0', :ha_format => 'xml', :ha_fancylayout => false})
      end

      def access_token_options
        to_params({:ha_method => 'auth.accesstoken', :strict_oauth_spec_response => true})
      end

      def request_token_path
        "http://data.hyves-api.nl/?#{request_token_options}&#{default_options}"
      end

      def request_token_options
        to_params({:methods => 'wwws.create,users.getLoggedin', :ha_method => 'auth.requesttoken', :strict_oauth_spec_response => true, :expirationtype => "infinite"})
      end

      def to_params(options)
        options.collect{|key, value| "#{key}=#{value}"}.join('&')
      end

      def auth_hash
        # Based on https://gist.github.com/569650 by nov
        oauth_response = ::OpenID::OAuth::Response.from_success_response(@openid_response)
        client_options = {
          :authorize_path => 'http://www.hyves.nl/api/authorize',
          :access_token_url => access_token_path,
          :http_method => :get,
          :request_token_path => request_token_path,
          :scheme => :header
        }

        consumer = ::OAuth::Consumer.new(
          @options[:consumer_key],
          @options[:consumer_secret],
          client_options
        )

        request_token = ::OAuth::RequestToken.new(
          consumer,
          oauth_response.request_token,
          "" # OAuth request token secret is also blank in OpenID/OAuth Hybrid
        )

        @access_token = request_token.get_access_token

        OmniAuth::Utils.deep_merge(super(), {
          'uid' => @openid_response.display_identifier,
          'user_info' => user_info(@openid_response),
          'credentials' => {
            'scope' => @options[:scope],
            'token' => @access_token.token,
            'secret' => @access_token.secret
          }
        })
      end

      def ax_user_info(response)
        super.merge(
          {
            'street' => street(ax),
            'house_number' => house_number(ax),
            'house_number_addition' => house_number_addition(ax)
          }
        )
      end

      def ax_street(ax)
        ax.get_single(AX[:street])
      end

      def street(ax)
        return nil if ax_street(ax).blank?
        ax.get_single(AX[:street]).to_s.split(/\s/)[1.. -1].join(' ')
      end

      def house_number(ax)
        return nil if ax_street(ax).blank?
        ax.get_single(AX[:street]).to_s.split(/\s/).first.scan(/^[0-9]+/).first
      end

      def house_number_addition(ax)
        return nil if ax_street(ax).blank?
        ax.get_single(AX[:street]).to_s.split(/\s/).first.scan(/[A-Za-z]+/).first
      end
    end
  end
end