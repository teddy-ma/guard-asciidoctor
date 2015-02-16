require 'asciidoctor'
require 'guard/compat/plugin'
require 'guard/haml/notifier'

module Guard

  class Asciidoctor < Plugin

    def initialize(opts = {})
      @patterns = []

      opts = {
        notifications:        true,
        default_ext:          'html',
        auto_append_file_ext: false,
        helper_modules:       []
      }.merge(opts)

      super(opts)
    end

    def start
      run_all if options[:run_at_start]
    end

    def stop
      true
    end

    def reload
      run_all
    end

    def run_all
      run_on_changes(Compat.matching_files(self, Dir.glob(File.join('**', '*.*'))))
    end

    def run_on_changes(paths)
      puts paths
      # paths.each do |file|
      #   output_paths = _output_paths(file)
      #   compiled_haml = compile_haml(file)

      #   output_paths.each do |output_file|
      #     FileUtils.mkdir_p File.dirname(output_file)
      #     File.open(output_file, 'w') { |f| f.write(compiled_haml) }
      #   end

      #   message = "Successfully compiled haml to html!\n"
      #   message += "# #{file} -> #{output_paths.join(', ')}".gsub("#{::Bundler.root}/", '')
      #   Compat::UI.info message
      #   Notifier.notify(true, message) if options[:notifications]
      # end
    end

  end

end
