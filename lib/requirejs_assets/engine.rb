module RequirejsAssets
  class Engine < ::Rails::Engine
    config.before_configuration do |app|
      app.config.assets.precompile += [/require\.js$/]
      app.config.requirejs = RequirejsAssets::Config.new.configure do |c|
        c.paths = {}
        c.modules = []
      end
    end

    config.after_initialize do |app|
      c = app.config
      c.assets.precompile += c.requirejs.modules
    end

    initializer 'requirejs.environment', after: 'sprockets.environment' do |app|
      app.assets.register_postprocessor('application/javascript', RequirejsAssets::Processor)
      app.assets.register_bundle_processor('application/javascript', RequirejsAssets::ModuleFinalizer)
    end
  end
end
