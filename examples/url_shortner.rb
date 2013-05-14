require 'rubygems'
require 'sinatra'
 
LINKS='linksfile'
LOG='log.txt'

def log(stuff)
  File.open(LOG, "a") do |file|
    file.write stuff + "\n"
  end
end

def getlink(short)
  File.open(LINKS, "r") do |file|
    file.each do |line|
      if line =~ /^#{short}\s(.+)$/
        file.close
        return $1
      end
    end
  end
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
 
def searchshortener(short)
  File.open(LINKS, "r") do |file|
    file.each do |line|
      if line !~ /^#{short}\s/
	file.close
	return 0
      end
    end
  end
end
 
def createlink(link)
  log("pie")
  string = Array.new(5){rand(36).to_s(36)}.join
  until searchshortener(string)
    string = Array.new(5){rand(36).to_s(36)}.join
  end 
  puts "string is " + string
  File.open(LINKS, "a") do |file|
    log("about to write file")
    file.write string + " " + link + "\n" 
    log("wrote file")
  end
  return string
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
  puts shortlink
  if shortlink
    "dev.sma.edgecastcdn.net/go/" + shortlink
  else
    "dev.sma.edgecastcdn.net/go/" + createlink(link)
  end
end
