require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'oauth'
require 'oauth/request_proxy/rack_request'
require 'uri'

$: << File.dirname(__FILE__)

# The Maromi Rack Middleware
class Maromi
  
  REQUIRED_OAUTH_PARAMETERS = %w( oauth_signature_method oauth_timestamp
                                  oauth_nonce oauth_consumer_key
                                  oauth_signature )
  
  
  autoload :Proxies, 'maromi/proxies'
  autoload :Helpers, 'maromi/helpers'
  require 'maromi/models'
  
  
  cattr_accessor :authorized_request
  
  # In most cases, you should not call this method directly, but call Rack's
  # use method
  # @api public
  # @example use Maromi, :database => 'database_dev', :adapter => 'mysql',
  #                      :user => 'root', :password => ''
  # @example use Maromi, 'mysql://root:pass@localhost/database_dev'
  # @param [#call] app The downstream Rack application
  # @param [String, Hash] connection_path Either a connection string or a
  #                       hash of options
  def initialize(app, connection_path = nil)
    @app = app
    auto_attach_helpers_to app
    connect_to_datamapper! connection_path unless
        DataMapper::Repository.adapters[:default]
    DataMapper.auto_upgrade!
  end
  
  # Performs the request through maromi
  # @api protected
  # @param [Rack::Environment] env The Rack Environment
  # @return [Array] The Rack Response
  def call(env)
    setup env
    if is_terminal_request?
      respond_with terminal_response
    else
      add_headers
      with_lazy_authentication { respond_with @app.call(@env) }
      perform_required_redirects
    end
  rescue Unauthorized => e
    respond_with [
                  401, {'Content-Type' => 'text/html'},
                  ['<h1>Unauthorized.</h1>' + e.message]
                 ]
  rescue Invalid => e
    respond_with [
                  400, {'Content-Type' => 'text/html'},
                  ['<h1>Invalid</h1>' + e.message]
                 ]
  ensure
    return @response
  end
  
  private
  
  # Builds the request environment for Maromi to use
  # @api private
  # @param [Rack::Environment] env The Rack Environment
  # @return nil
  def setup(env)
    @env = env
    @request = Rack::Request.new(env)
  end
  
  def is_terminal_request?
    ['/oauth/request_token', '/oauth/access_token'].include? @request.path
  end
  
  def add_headers
    @env['maromi.version']  = VERSION
    @env['maromi.injected'] = true
    @env['maromi.helper']   = Helpers::LazyObject.new(@request)
  end
  
  def perform_required_redirects
    if request = Maromi.authorized_request and request.callback_url != 'oob'
      uri = URI.parse(request.callback_url)
      uri.send(:set_query, [uri.query, 'oauth_verifier=' + request.verifier].reject(&:nil?).join('&'))
      respond_with [301, {'Location' => uri.to_s}, []]
      Maromi.authorized_request = nil
    end
  end
  
  def terminal_response
    return generate_request_token if @request.path == '/oauth/request_token'
    return generate_access_token if @request.path == '/oauth/access_token'
  end
  
  def generate_access_token
    request, r, c = OAuth::RequestProxy.proxy(@request)
    
    if REQUIRED_OAUTH_PARAMETERS.any? {|s| !request.parameters[s]}
      raise Invalid, required.join(', ') + ' are required.'
      
    elsif !(r = Request.first(:token => request.parameters['oauth_token'],
            :consumer => c=Consumer.get(request.parameters['oauth_consumer_key'])))
      raise Unauthorized, 'Unable to find a request with token ' +
                          request.parameters['oauth_token']
                          
    elsif r.verified && r.verifier == request.parameters['oauth_verifier'] && OAuth::Signature.verify(request) {|_| [r.secret, c.secret] }
      authorization = r.upgrade!
      parameters = Helpers::ParameterList.new(:oauth_token => authorization.token, :oauth_token_secret => authorization.secret)
      
      [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, [parameters.urlencoded]]
      
    else
      raise Unauthorized
    end
  end
  
  def generate_request_token
    request, c = OAuth::RequestProxy.proxy(@request)
    if REQUIRED_OAUTH_PARAMETERS.any? {|s| !request.parameters[s] }
      raise Invalid, required.join(', ') + ' are required.'
    elsif OAuth::Signature.verify(request) {|r| [ nil, (c=Consumer.get!(r.parameters['oauth_consumer_key'])).secret]}
      r = Request.new(:consumer => c)
      r.callback_url = request.parameters['oauth_callback'] || r.consumer.callback_url
      r.token = Helpers::Token.new(16)
      r.secret = Helpers::Token.new
      r.save
      p = Helpers::ParameterList.new(:oauth_token => r.token, :oauth_token_secret => r.secret, :oauth_callback_confirmed => 'true')
      [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, [p.urlencoded]]
    elsif [:oauth_consumer_key]
      raise Unauthorized, 'Bad Signature.'
    end
  rescue OAuth::Signature::UnknownSignatureMethod => e
    raise Invalid, 'Unknown signature method ' + e.message
  rescue DataMapper::ObjectNotFoundError
    raise Unauthorized, 'Could not find a consumer with token ' +
                        request.parameters['oauth_consumer_key']
  end
  
  def respond_with(response)
    @response = response
  end
  
  def auto_attach_helpers_to(app)
    app.send(:helpers, Maromi::Helpers::Sinatra) if
      defined? Sinatra and app.is_a? Sinatra::Application
  end
  
  def connect_to_datamapper!(connection_path)
    connection_path = (ENV['DATABASE_URL'] || connection_path ||
                      (ActiveRecord::Base.configurations[ENV['RACK_ENV']] if
                      defined? ActiveRecord))
    if connection_path
      connection_path = Mash.new(connection_path) and
                  connection_path[:adapter].sub!('postgresql', 'postgres') if
                  connection_path.is_a? Hash
      DataMapper.setup(:default, connection_path)
      DataMapper::Logger.new($stdout, :error)
    else
      raise "Maromi couldn't find a database to connect to. " +
            "You should provide it with what it needs."
    end
  end
  
  def with_lazy_authentication
    authorized = false
    catch :unauthorized do
      yield
      authorized = true
    end
    raise Unauthorized unless authorized
  end
  
  class Unauthorized < Exception; end
  class Invalid < Exception; end
  
end
