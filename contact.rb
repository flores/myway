#!/usr/bin/env ruby 

require 'rubygems'
require 'sinatra'
require 'erb'
require 'sanitize'
require 'aws/ses'

set :environment, :production
set :port, '10000'
#set :bind, 'localhost'

EMAIL = 'me@mydomain.com'

get '/' do
  erb :reveal, :layout => false
end

get '/preso' do 
  erb :reveal, :layout => false
end

get '/title/:newtitle' do
  @newtitle = params[:newtitle]
  erb :impress
end

get '/contact' do
  erb :contact
end

post '/' do
  @name = Sanitize.clean(params[:name])
  mail = Sanitize.clean(params[:mail])
  subject = Sanitize.clean(params[:subject])
  body = params[:body]
  ses = AWS::SES::Base.new(
    :access_key_id  => 'id',
    :secret_access_key => 'key'
  )
  ses.send_email(
    :to => YOUR_EMAIL,              
    :from => 'tonina@petalphile.com',
    :subject => mail + " - " + @name + " - " + subject,
    :body => body
  )
  erb :success
end
