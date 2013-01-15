module RequirejsAssets
  module Helper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::JavaScriptHelper

    def requirejs_include_tag options={}
      runtime_options = options[:runtime] || {}
      html = []
      if requirejs_runtime_options.present?
        html << javascript_tag("var require = #{requirejs_runtime_options.deep_merge(runtime_options).to_json};")
      end
      html << javascript_include_tag('require.js', data_attributes_hash(options))
      html.join("\n").html_safe
    end

    private
    def requirejs_runtime_options
      config = rails_config.requirejs.to_hash.merge(baseUrl: rails_config.assets.prefix)
      config.delete(:modules)
      Hash[config.reject{|key, value| value.blank?}]
    end

    def data_attributes_hash options={}
      hash = {'data-main' => digest_module_name('application')}
      modules = available_modules(options[:modules])
      hash = modules.inject(hash) do |result, module_name|
        result.merge("data-#{module_name}" => digest_module_name(module_name))
      end if modules.present?
      hash
    end

    def available_modules modules
      return rails_config.requirejs.modules if modules == :all
      modules = *modules
      if modules.present?
        rails_config.requirejs.modules & modules
      else
        nil
      end
    end

    def digest_module_name module_name
      if digest = asset_paths.digest_for("#{module_name}.js")
        module_name = digest.split(?.).first
      end
      "#{rails_config.assets.prefix}/#{module_name}"
    end

    def rails_config
      Rails.application.config
    end
  end
end
