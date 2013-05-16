require 'rubygems'
require 'sinatra'
 
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
  if link !~ /^http:/
    link = "http://#{link}"
  end
  shortlink = searchlinks(link)
  if shortlink
    "dev.sma.edgecastcdn.net/go/" + shortlink
  else
    "dev.sma.edgecastcdn.net/go/" + createlink(link)
  end
end
