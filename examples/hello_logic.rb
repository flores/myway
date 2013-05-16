require 'sinatra.rb'

def check_if_carlo(name)
  if name == 'carlo'
    return true
  else
    return false
  end
end

get '/' do
  "Hello world"
end

get '/hello/:name' do
  name = params[:name]
  if check_if_carlo(name)
    "Hey " + name + ", I know you!"
  else
    "Hello " + name
  end
end
