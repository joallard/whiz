require "whos/version"
require "whois"
require "whois-parser"
# https://whoisrb.org/docs/v3/parser/

module Whos
  def self.lookup(domain, opts: {})
    Lookup.new(domain).print_output
  end

  class Lookup
    # Functions as a DSL to define the output
    def output
      domain
      puts("=" * @domain.length)
      status

      puts

      property(:expires_on) do |p|
        "Expiration: " + p.to_s
      end

      property(:created_on) do |p|
        "Creation:   " + p.to_s
      end

      property(:registrar) do |p|
        "Registrar:  " + p.name
      end
    end

    def print_output
      puts
      output
      puts
    end

    def initialize(domain)
      @domain = domain
      perform!
    end

    protected

    def perform!
      begin
        @lookup = client.lookup @domain
        @parsed = @lookup.parser
      rescue Timeout::Error
        server = client.instance_exec{ @server }.host
        puts "Timed out on server #{server}"
        exit
      end
    end

    def client
      Whois::Client.new
    end

    module Output
      def domain
        puts @domain
      end

      def status
        status = if @parsed.available?
                   :available
                 elsif @parsed.registered?
                   :registered
                 else
                   @parsed.status
                 end

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

        puts yield(result)
      end
    end

    include Output
  end
end
