require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'oauth'
require 'oauth/request_proxy/rack_request'
require 'uri'


load 'maromi/consumer.rb'
load 'maromi/authorization.rb'
load 'maromi/request.rb'
load 'maromi/helper.rb'
load 'maromi/helpers/sinatra.rb'
load 'maromi/token.rb'
load 'maromi/parameter_list.rb'
load 'maromi/consumer_proxy.rb'
load 'maromi/consumer_request_proxy.rb'
load 'maromi/consumer_authorization_proxy.rb'

class Maromi
  VERSION = '0.0.1'
  
  class << self; attr_accessor :is_migrated, :authorized_request; end
  
  def initialize(app, connection_path = nil)
    @app = app
    @app.send(:helpers, Maromi::Helpers::Sinatra) if @app.is_a? Sinatra::Application
    DataMapper::Logger.new($stdout, :error)
    unless DataMapper::Repository.adapters[:default]
      if c = (ENV['DATABASE_URL'] || connection_path || (defined? Rails && ActiveRecord::Base.configurations[ENV['RACK_ENV']]))
        if c.is_a? Hash
          c = "#{c[:adapter]}://#{c[:username]}#{(p=c[:password]) ? ":#{p}" : ''}@#{c[:host]||'localhost'}/#{c[:database]}"
        end
        DataMapper.setup(:default, c)
      else
        raise "Maromi couldn't find a database to connect to. You should provide it with what it needs."
      end
    end
  end
  
  def call(env)
    
    unless Maromi.is_migrated
      DataMapper.auto_upgrade!
      Consumer.create(:shared_secret => Token.new, :consumer_key => Token.new(16), :callback_url => 'http://localhost:4567/oauth/callback')
      Maromi.is_migrated = true
    end
    
    setup env
    if is_terminal_request?
      handle_request
    else
      add_headers
      response = @app.call(@env)
      clean_up
      return hijacked || response
    end
  end
  
  private
  
  def setup(env)
    @env = env
    @request = Rack::Request.new(env)
  end
  
  def is_terminal_request?
    ['/oauth/request_token', '/oauth/access_token'].include? @request.path
  end
  
  def add_headers
    @env['maromi.version'] = VERSION
    @env['maromi.handled'] = true
    @env['maromi.helper']  = Helper.new(@request)
  end
  
  def clean_up
    if request = Maromi.authorized_request and request.callback_url != 'oob'
      uri = URI.parse(request.callback_url)
      uri.send(:set_query, [uri.query, 'oauth_verifier=' + request.verifier].reject(&:nil?).join('&'))
      hijack [301, {'Location' => uri.to_s}, []]
      Maromi.authorized_request = nil
    end
  end
  
  def handle_request
    return generate_request_token if @request.path == '/oauth/request_token'
    return generate_access_token if @request.path == '/oauth/access_token'
  rescue Exception => e
    p e
    p e.backtrace
    return [500, {'Content-Type' => 'text/plain'}, ['Maromi has pooped the bed.']]
  end
  
  def generate_access_token
    request, r, c = OAuth::RequestProxy.proxy(@request)
    required = %w(oauth_signature_method oauth_signature oauth_timestamp oauth_nonce oauth_consumer_key oauth_token)
    if required.any? {|s| !request.parameters[s]}
      [400, {'Content-Type' => 'text/plain'}, [required.join(', ') + ' are required.']]
    elsif !(r = Request.first(:token => request.parameters['oauth_token'], :consumer => c = Consumer.get(request.parameters['oauth_consumer_key'])))
      [401, {'Content-Type' => 'text/plain'}, ['Unable to find a request with token ' + request.parameters['oauth_token']]]
    elsif r.verified && r.verifier == request.parameters['oauth_verifier'] && OAuth::Signature.verify(request) {|_| [r.token_secret, c.shared_secret] }
      a = Authorization.create(:consumer => c, :user_id => r.user_id, :token => Token.new(16), :secret => Token.new)
      r.destroy
      p = ParameterList.new(:oauth_token => a.token, :oauth_token_secret => a.secret)
      [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, [p.urlencoded]]
    else
      [401, {'Content-Type' => 'text/plain'}, ['Unauthorized']]
    end
  end
  
  def generate_request_token
    request, c = OAuth::RequestProxy.proxy(@request)
    if ['oauth_signature_method', 'oauth_callback', 'oauth_consumer_key', 'oauth_signature'].any? {|s| !request.parameters[s] }
      [400, {'Content-Type' => 'text/plain'}, ['signature_method, callback, consumer_key, and signature are required.']]
    elsif OAuth::Signature.verify(request) {|r| [ nil, (c=Consumer.get!(r.parameters['oauth_consumer_key'])).shared_secret]}
      r = Request.new(:consumer => c)
      r.callback_url = @request.params[:oauth_callback] || r.consumer.callback_url
      r.token = Token.new(16)
      r.token_secret = Token.new
      r.save
      p = ParameterList.new(:oauth_token => r.token, :oauth_token_secret => r.token_secret, :oauth_callback_confirmed => 'true')
      [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, [p.urlencoded]]
    elsif [:oauth_consumer_key]
      [401, {'Content-Type' => 'text/plain'}, ['Bad Signature.']]
    end
  rescue OAuth::Signature::UnknownSignatureMethod => e
    [400, {'Content-Type' => 'text/plain'}, ['Unknown signature method ' + e.message]]
  rescue DataMapper::ObjectNotFoundError
    [401, {'Content-Type' => 'text/plain'}, ['Could not find a consumer with token ' + request.parameters['oauth_consumer_key']]]
  end
  
  def hijacked
    @hijacked
  end
  
  def hijack(response)
    p 'hijacking with', response
    @hijacked = response
  end
  
end