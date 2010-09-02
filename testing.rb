require 'rubygems'
require 'sinatra'
require 'haml'
$: << File.join(File.dirname(__FILE__), 'maromi', 'lib')

load 'maromi.rb'

use Maromi, :database => 'dtb_dev', :adapter => 'postgres'

get '/toaster' do
  require_oauth_authentication!
  consumer.user_id.to_s
end

get '/oauth/authorize' do
  haml :request_for_authorization
end

post '/oauth/authorize' do
  consumer.authorized! :by => 1, :to => 'read'
end

get '/oauth/consumers/new' do
  haml :new_oauth_consumer
end

post '/oauth/consumers' do
  if @consumer = create_consumer(params[:consumer])
    haml :you_are_a_consumer
  else
    @errors = consumer_errors
    haml :new_oauth_consumer
  end
end

__END__

@@ request_for_authorization
you are about to authorize
%b= consumer.name || consumer.callback
%form{:method => 'post', :action => '/oauth/authorize'}
  Sound good?
  %input{:type => :hidden, :name => :oauth_token, :value => oauth_token}/
  %button{:type => 'submit'} Yeah, okay.

@@ new_oauth_consumer
You want to be a consumer, eh?
%ul
  - if @errors
    - @errors.each do |error|
      %li= error
%form{:method => 'post', :action => '/oauth/consumers'}
  %input{:name => 'consumer[callback]'}
  %button{:type=>'submit'} YES
  
@@ you_are_a_consumer
You are now a consumer
%table
  %tr
    %td token
    %td= @consumer.token
  %tr
    %td shared secret
    %td= @consumer.secret
    