module RequirejsAssets
  module Helper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::JavaScriptHelper

    def requirejs_include_tag options={}
      html = [javascript_include_tag('require.js', data_attributes_hash)]
      if requirejs_runtime_options.present?
        html << javascript_tag("requirejs.config(#{requirejs_runtime_options.deep_merge(options).to_json});")
      end
      html.join("\n").html_safe
    end

    def requirejs_runtime_options
      config = Rails.application.config.requirejs.to_hash
      Hash[config.reject{|key, value| value.blank?}]
    end

    def data_attributes_hash
      {'data-main' => 'application'}
    end
  end
end
