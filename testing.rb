require 'rubygems'
require 'sinatra'
$: << File.join(File.dirname(__FILE__), 'maromi', 'lib')

load 'maromi.rb'

use Maromi

get '/' do
  "hey"
end

get '/maromi' do
  p maromi
end

get '/oauth/authorize' do
  haml :request_for_authorization
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
%b= consumer_name

@@ new_oauth_consumer
You want to be a consumer, eh?
%ul
  - @errors.each do |section|
    -section.each do |error|
      %li= section.to_s + " " + error
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
    