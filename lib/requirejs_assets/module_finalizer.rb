require 'tilt'

module RequirejsAssets
  class ModuleFinalizer < Tilt::Template
    def prepare
    end
    
    def evaluate context, locals, &block
      @data += "\n\ndefine(\"#{context.logical_path}\", function(){});\n\n" if requirejs_asset?(context)
      @data
    end

    private
    def requirejs_asset? context
      modules = Rails.application.config.requirejs.modules.
        map{|module_path| module_path.split(?.).first}
      modules << 'application'
      modules.include?(context.logical_path)
    end
  end
end
