require "whos/version"
require "whois"
require "whois-parser"
# https://whoisrb.org/docs/v3/parser/

module Whos
  def self.lookup(domain, opts: {})
    Lookup.new(domain).tap{ |l| l.print_output }
  end

  class Lookup
    attr_reader :lookup, :parsed

    # Functions as a DSL to define the output
    def output
      h1 domain
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
        give @domain
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

        status
      end

      # Ensures property is available in lookup and that it is not empty
      def property(prop)
        return unless @parsed.property_any_supported?(prop)
        return unless result = @parsed.public_send(prop)

        puts yield(result)
      end

      def h1(content)
        # puts(content)
        puts("=" * content.length)
      end

      # Makes a puts that returns the object
      def give(content)
        content.tap{ |c| puts(c) }
      end
    end

    include Output
  end
end
