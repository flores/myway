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

  @name = params[:name]
  erb :success
end

LINKS='linksfile'

def createlink(link)
  string = Array.new(5){rand(36).to_s(36)}.join
  until searchshortener(string)
    string = Array.new(5){rand(36).to_s(36)}.join
  end 
  File.open(LINKS, "a") do |file|
    file.write string + " " + link + "\n" 
  end
  return string
end

def searchlinks(link)
  match = nil
  File.open(LINKS, "r") do |file|
    file.each do |line|
      if line =~ /(.+?)\s#{link}$/
        match = $1
	break
      end
    end
  end
  return match
end

def getlink(short)
  match = nil
  File.open(LINKS, "r") do |file|
    file.each do |line|
      if line =~ /^#{short}\s(.+)$/
	match = $1
	break
      end
    end
  end
  return match
end
  
def searchshortener(short)
  match = nil
  File.open(LINKS, "r") do |file|
    file.each do |line|
      if line !~ /^#{short}\s/
	match = 1
	break
      end
    end
  end
  return match
end
 

get '/go/:short' do
  short = params[:short]
  target = getlink(short)

  if target
    redirect "#{target}"
  else
    status 404
  end
end
 
get '/shorten/*' do
  link = params[:splat].join('/')
  if link !~ /^http(s?:)/
    link = "http://#{link}"
  end
  shortlink = searchlinks(link)
  if shortlink
    request.host + shortlink
  else
    request.host + createlink(link)
  end
end

error do
  erb :error
end
