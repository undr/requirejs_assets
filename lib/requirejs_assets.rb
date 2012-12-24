require 'rkelly'
require 'requirejs_assets/version'

module RequirejsAssets
  extend ActiveSupport::Autoload

  autoload :Config, 'requirejs_assets/config'
  autoload :Processor, 'requirejs_assets/processor'
end

require 'requirejs_assets/engine' if defined?(Rails)
