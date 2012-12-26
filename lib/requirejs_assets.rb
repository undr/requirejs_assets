begin
  require 'rkelly'
rescue SyntaxError => e
  # patch for ruby 1.9.3
  require 'requirejs_assets/rkelly_patch'
end

require 'requirejs_assets/version'

module RequirejsAssets
  extend ActiveSupport::Autoload

  autoload :Config, 'requirejs_assets/config'
  autoload :Processor, 'requirejs_assets/processor'
end

require 'requirejs_assets/engine' if defined?(Rails)
