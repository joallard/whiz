require 'whois'
require 'whois-parser'
# https://whoisrb.org/docs/v3/parser/

def output(&block); @output = block; end

output do
  puts
  domain
  puts("-" * @domain.length)
  status

  puts

  property(:expires_on) do
    "Expiration: " + @parsed.expires_on.to_s
  end

  property(:created_on) do
    "Creation:   " + @parsed.created_on.to_s
  end

  property(:registrar) do
    "Registrar:  " + @parsed.registrar.name
  end
end


unless @domain = ARGV[0]
  puts "Usage: ruby lookup.rb [domain.com]"
  exit 1
end


wc = Whois::Client.new
begin
  d = wc.lookup @domain
rescue Timeout::Error
  server = wc.instance_exec{ @server }.host
  puts "Timed out on server #{server}"
  exit
end

@parsed = d.parser

def domain
  puts @domain
end

def status
  status = @parsed.status

  if @parsed.available?
    print "\e[32m"
  else
    print "\e[34m"
  end

  print status
  puts "\e[0m"
end

def property(prop)
  return unless @parsed.property_any_supported?(prop)
  return unless result = @parsed.public_send(prop)

  puts yield
end

@output.call
puts
