module Guard
  class Handlebars

    class Template
      JS_ESCAPE_MAP = {
        "\r\n"  => '\n',
        "\n"    => '\n',
        "\r"    => '\n',
        '"'     => '\\"',
        "'"     => "\\'" }

      attr_reader :source

      def initialize(path, source, options = {})
        @path, @source, @options = path, source, options
      end

      def compile
        # TODO Do not assume require.js, but make it possible
        
        if @options[:emberjs]
          compiled = "Ember.TEMPLATES['#{camelcase(function)}'] = Ember.Handlebars.compile('#{escape(source)}');"
        else
          compiled = "(function() {"
          compiled << "\n  define(['handlebars'], function() {"
          compiled << "\n    var #{function} = Handlebars.compile('#{escape(source)}');"
          compiled << "\n    Handlebars.registerPartial('#{function}', #{function});" if partial?
          compiled << "\n    return #{function};"
          compiled << "\n  });"
          compiled << "\n}).call(this);"
        end
        
        compiled
      end

      def camelcase(s)
        s.gsub(/^[a-z]|_[a-z]/) { |a| a.upcase }.gsub(/_/, '').gsub(/^[A-Z]/) {|a| a.downcase}
      end

      def function
        name.sub(/^_/, '').split('.').first
      end

      def name
        # @path.split('/').last
        @path
      end

      def partial?
        name =~ /^_/
      end

      private

      def escape(string)
        string.strip.gsub(/(\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
      end

    end

  end
end
