# encoding: utf-8

require 'guard/asciidoctor'

module Guard
  class Asciidoctor < Plugin
    class Notifier
      class << self
        def image(result)
          result ? :success : :failed
        end

        def notify(result, message)
          Compat::UI.notify(message, title: 'Guard::Asciidoctor', image: image(result))
        end
      end
    end
  end
end