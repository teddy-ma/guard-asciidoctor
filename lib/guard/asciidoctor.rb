require 'asciidoctor'
require 'guard/compat/plugin'
require 'guard/asciidoctor/notifier'

module Guard

  class Asciidoctor < Plugin

    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(options = {})
      @patterns = []

      opts = {
        notifications:  true,
        helper_modules: []
      }.merge(options)

      super(opts)
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
      Compat::UI.info "method start"
      run_all #if options[:run_at_start]
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    def stop
      Compat::UI.info "method stop"
      true
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    def reload
      Compat::UI.info "method reload"
      run_all
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    def run_all
      Compat::UI.info "run all"
      run_on_changes(Compat.matching_files(self, Dir.glob(File.join('**', '*.*'))))
    end


    def run_on_changes(paths)
      paths.each do |file|
        output_paths = _output_paths(file)
        compiled_asciidoc = compile_asciidoc(file)

        output_paths.each do |output_file|
          FileUtils.mkdir_p File.dirname(output_file)
          File.open(output_file, 'w') { |f| f.write(compiled_asciidoc) }
        end

        message = "Successfully compiled asciidoc!\n"
        message += "# #{file} -> #{output_paths.join(', ')}".gsub("#{::Bundler.root}/", '')
        Compat::UI.info message
        Notifier.notify(true, message) if options[:notifications]
      end
    end

    private

    def compile_asciidoc(file)
      content = File.new(file).read
      engine = ::Asciidoctor.convert content, safe: 'safe'
    rescue StandardError => error
      message = "Asciidoc compilation of #{file} failed!\nError: #{error.message}"
      Compat::UI.error message
      Notifier.notify(false, message) if options[:notifications]
      throw :task_has_failed
    end

    def scope_object
      scope = Object.new
      @options[:helper_modules].each do |mod|
        scope.extend mod
      end
      scope
    end

    # Get the file path to output the html based on the file being
    # built. The output path is relative to where guard is being run.
    #
    # @param file [String, Array<String>] path to file being built
    # @return [Array<String>] path(s) to file where output should be written
    #
    def _output_paths(file)
      input_file_dir = File.dirname(file)
      file_name = _output_filename(file)
      input_file_dir = input_file_dir.gsub(Regexp.new("#{options[:input]}(\/){0,1}"), '') if options[:input]

      if options[:output]
        Array(options[:output]).map do |output_dir|
          File.join(output_dir, input_file_dir, file_name)
        end
      else
        if input_file_dir == ''
          [file_name]
        else
          [File.join(input_file_dir, file_name)]
        end
      end
    end

    # Generate a file name based on the provided file path.
    # Provide a logical extension.
    #
    # Examples:
    #   "path/foo.adoc"     -> "foo.html"
    #   "path/foo.asciidoc" -> "foo.html"
    #
    # @param file String path to file
    # @return String file name including extension
    #
    def _output_filename(file)
      sub_strings = File.basename(file).split('.')
      base_name   = sub_strings[0..-2]
      "#{base_name.join('.')}.html"
    end
  end

end
