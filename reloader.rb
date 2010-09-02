load 'testing.rb'
class Reloader
  
  def initialize(app)
    @app = app
  end
  
  def call(env)
    load 'testing.rb'
    Sinatra::Application.call(env)
  end
end