require 'faraday'
require 'json'

module Dradis
  module Client
    module Response
      class ParseJson < Faraday::Response::Middleware
        WHITESPACE_REGEX = /\A^\s*$\z/

        def parse(body)
          case body
          when WHITESPACE_REGEX, nil
            nil
          else
            JSON.parse(body, :symbolize_names => true)
          end
        end

        def on_complete(response)
          response.body = parse(response.body) if respond_to?(:parse) && !unparsable_status_codes.include?(response.status)
        end

        def unparsable_status_codes
          [204, 301, 302, 304]
        end
      end
    end
  end
end

Faraday::Response.register_middleware parse_json: Dradis::Client::Response::ParseJson