module Berkshelf
  module Formatters
    class JSON
      include AbstractFormatter

      register_formatter :json

      # Output the version of Berkshelf
      def version
        @output = { version: Berkshelf::VERSION }
      end

      def initialize
        @output = {
          cookbooks: Array.new,
          errors: Array.new,
          messages: Array.new
        }
        @cookbooks = Hash.new

        Berkshelf.ui.mute { super }
      end

      def cleanup_hook
        cookbooks.each do |name, details|
          details[:name] = name
          output[:cookbooks] << details
        end

        puts ::JSON.pretty_generate(output)
      end

      # @param [Berkshelf::Dependency] dependency
      def fetch(dependency)
        cookbooks[dependency] ||= {}
        cookbooks[dependency][:version]  = dependency.locked_version.to_s
        cookbooks[dependency][:location] = dependency.location
      end

      # Add a Cookbook installation entry to delayed output
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [~Location] location
      def install(cookbook, version, location)
        cookbooks[cookbook] ||= {}
        cookbooks[cookbook][:version] = version

        if location && location.is_a?(PathLocation)
          cookbooks[cookbook][:metadata] = true if location.metadata?
          cookbooks[cookbook][:location] = location.relative_path
        end
      end

      # Add a Cookbook use entry to delayed output
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [~Location] location
      def use(cookbook, version, location = nil)
        cookbooks[cookbook] ||= {}
        cookbooks[cookbook][:version] = version

        if location && location.is_a?(PathLocation)
          cookbooks[cookbook][:metadata] = true if location.metadata?
          cookbooks[cookbook][:location] = location.relative_path
        end
      end

      # Add a Cookbook upload entry to delayed output
      #
      # @param [Berkshelf::CachedCookbook] cookbook
      # @param [Ridley::Connection] conn
      def upload(cookbook, conn)
        name = cookbook.cookbook_name
        cookbooks[name] ||= {}
        cookbooks[name][:version] = cookbook.version
        cookbooks[name][:uploaded_to] = conn.server_url
      end

      # Add a Cookbook skip entry to delayed output
      #
      # @param [Berkshelf::CachedCookbook] cookbook
      # @param [Ridley::Connection] conn
      def skip(cookbook, conn)
        name = cookbook.cookbook_name
        cookbooks[name] ||= {}
        cookbooks[name][:version] = cookbook.version
        cookbooks[name][:skipped] = true
      end

      # Output a list of outdated cookbooks and the most recent version
      # to delayed output
      #
      # @param [Hash] hash
      #   the list of outdated cookbooks in the format
      #   { 'cookbook' => { 'api.berkshelf.com' => #<Cookbook> } }
      def outdated(hash)
        hash.keys.each do |name|
          hash[name].each do |source, cookbook|
            cookbooks[name] ||= {}
            cookbooks[name][:version] = cookbook.version
            cookbooks[name][:sources] ||= {}
            cookbooks[name][:sources][source] = cookbook
          end
        end
      end

      # Add a Cookbook package entry to delayed output
      #
      # @param [String] cookbook
      # @param [String] destination
      def package(cookbook, destination)
        cookbooks[cookbook] ||= {}
        cookbooks[cookbook][:destination] = destination
      end

      # Output a list of cookbooks to delayed output
      #
      # @param [Hash<Dependency, CachedCookbook>] list
      def list(list)
        list.each do |dependency, cookbook|
          cookbooks[cookbook.cookbook_name] ||= {}
          cookbooks[cookbook.cookbook_name][:version] = cookbook.version
          if dependency.location
            cookbooks[cookbook.cookbook_name][:location] = dependency.location
          end
        end
      end

      # Output Cookbook info entry to delayed output
      #
      # @param [CachedCookbook] cookbook
      def show(cookbook)
        cookbooks[cookbook.cookbook_name] = cookbook.pretty_hash
      end

      # Add a vendor message to delayed output
      #
      # @param [CachedCookbook] cookbook
      # @param [String] destination
      def vendor(cookbook, destination)
        cookbook_destination = File.join(destination, cookbook.cookbook_name)
        msg("Vendoring #{cookbook.cookbook_name} (#{cookbook.version}) to #{cookbook_destination}")
      end

      # Add a generic message entry to delayed output
      #
      # @param [String] message
      def msg(message)
        output[:messages] << message
      end

      # Add an error message entry to delayed output
      #
      # @param [String] message
      def error(message)
        output[:errors] << message
      end

      private

        attr_reader :output
        attr_reader :cookbooks
    end
  end
end
