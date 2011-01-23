class Maromi
  module Proxies
    class ConsumerRequest
      
      def initialize(request, consumer = nil)
        @request, @consumer = request, consumer
      end
      
      def authorized!(params = {})
        request.tap do |r|
          r.authorizer = params[:by] if params[:by]
          r.scopes = params[:to] if params[:to]
          r.verified = true
          r.verifier = (request.callback_url == 'oob' ? rand(9999) : Helpers::Token.new)
          r.save!
        end
        Maromi.authorized_request = request
      end
      
      def authorizer
        nil
      end
      alias_method :user, :authorizer
      
      def name
        consumer.name
      end
      
      def callback
        return request.callback_url unless request.callback_url == 'oob'
        return consumer.callback_url
      end
      
      def requested_redirect?
        request.callback_url != 'oob'
      end
      
      def verifier
        request.verifier
      end
      alias_method :pin, :verifier
      
      def to_s
        name || callback
      end
      
      def token
        consumer.token
      end
      
      def authorize_button(button_text = 'Authorize')
        <<-EOF.gsub('          ', '')
          <form action="/oauth/authorize" method="post">
            <input type="hidden" name="oauth_token" value="#{request.token}" />
            <button type="submit">#{button_text}</button>
          </form>
        EOF
      end
      
      private
      
      attr_reader :request
      
      def consumer
        @consumer ||= request.consumer
      end
      
    end
  end
end