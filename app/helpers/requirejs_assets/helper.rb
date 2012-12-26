module RequirejsAssets
  module Helper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::JavaScriptHelper

    def requirejs_include_tag options={}
      runtime_options = options[:runtime] || {}
      html = [javascript_include_tag('require.js', data_attributes_hash(options))]
      if requirejs_runtime_options.present?
        html << javascript_tag("requirejs.config(#{requirejs_runtime_options.deep_merge(runtime_options).to_json});")
      end
      html.join("\n").html_safe
    end

    private
    def requirejs_runtime_options
      config = Rails.application.config.requirejs.to_hash.merge(baseUrl: './assets')
      config.delete(:modules)
      Hash[config.reject{|key, value| value.blank?}]
    end

    def data_attributes_hash options={}
      hash = {'data-main' => 'application'}
      modules = available_modules(options[:modules])
      hash = modules.inject(hash) do |result, module_name|
        result.merge("data-#{module_name}" => module_name)
      end if modules.present?
      hash
    end

    def available_modules modules
      return Rails.application.config.requirejs.modules if modules == :all
      modules = *modules
      if modules.present?
        Rails.application.config.requirejs.modules & modules
      else
        nil
      end
    end
  end
end
