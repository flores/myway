#!/usr/bin/env ruby 

require 'rubygems'
require 'sinatra'
require 'erb'
require 'sanitize'
require 'aws/ses'
require 'openssl'

set :environment, :production
set :port, '4000'
#set :bind, 'localhost'

EMAIL = 'me@mydomain.com'

get '/' do
  erb :impress
end

get '/contact' do
  haml :contact
end

post '/contact' do
  name = Sanitize.clean(params[:name])
  mail = Sanitize.clean(params[:mail])
  subject = Sanitize.clean(params[:subject])
  body = params[:body]
  ses = AWS::SES::Base.new(
    :access_key_id  => 'key',
    :secret_access_key => 'key'
  )
  ses.send_email(
    :to => EMAIL, 
    :from => EMAIL, 
    :subject => mail + " - " + name + " - " + subject,
    :body => body
  )
  haml :success
end

get '/formy_yanc.css' do
	File.read(File.join('public', 'formy_yanc.css'))
end

error do
  haml :error
end
