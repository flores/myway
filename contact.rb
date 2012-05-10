#!/usr/bin/env ruby 

require 'rubygems'
require 'sinatra'
require 'erb'
require 'sanitize'
require 'aws/ses'

set :environment, :production
set :port, '4000'
#set :bind, 'localhost'

EMAIL = 'me@mydomain.com'

get '/' do
  erb :impress
end

get '/title/:newtitle' do
  @newtitle = params[:newtitle]
  erb :impress
end

get '/contact' do
  erb :contact
end

post '/contact' do
  params.collect! do |param|
    Sanitize.clean(param)
  end

  ses = AWS::SES::Base.new(
    :access_key_id  => 'id',
    :secret_access_key => 'key'
  )
  ses.send_email(
    :to => EMAIL, 
    :from => EMAIL, 
    :subject => params[:mail] + " sent you a message",
    :body => "subject: " + params[:subject] + "\nname: " + 
      params[:name] + "\n\n" + params[:body]
  )
  erb :success
end

error do
  erb :error
end
