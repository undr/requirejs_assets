require 'spec_helper'

describe RequirejsAssets::Helper do
  include RSpec::Rails::HelperExampleGroup

  describe '#requirejs_include_tag' do
    context 'without options' do
      specify do
        helper.requirejs_include_tag.should == "<script data-main=\"application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"baseUrl\":\"./assets\"});\n//]]>\n</script>"
      end
    end

    context 'with rails config options' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.paths = {'module1' => 'prefix/module1'}
          config.shim = {
            'underscore' => {exports: '_'},
            'some_lib' => ['dependency']
          }
        end
      end

      specify do
        helper.requirejs_include_tag.should == "<script data-main=\"application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"},\"some_lib\":[\"dependency\"]},\"baseUrl\":\"./assets\"});\n//]]>\n</script>"
      end
    end

    context 'with argument options' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.paths = {'module1' => 'prefix/module1'}
          config.shim = {'underscore' => {exports: '_'}}
        end
      end

      specify do
        helper.requirejs_include_tag(runtime: {shim: {'some_lib' => ['dependency']}}).should == "<script data-main=\"application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"},\"some_lib\":[\"dependency\"]},\"baseUrl\":\"./assets\"});\n//]]>\n</script>"
      end
    end

    context 'without modules' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag.should == "<script data-main=\"application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"./assets\"});\n//]]>\n</script>"
      end
    end

    context 'with all modules' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag(modules: :all).should == "<script data-main=\"application\" data-module1=\"module1\" data-module2=\"module2\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"./assets\"});\n//]]>\n</script>"
      end
    end

    context 'with modules as string' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag(modules: 'module1').should == "<script data-main=\"application\" data-module1=\"module1\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"./assets\"});\n//]]>\n</script>"
      end
    end

    context 'with modules as array' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag(modules: ['module1']).should == "<script data-main=\"application\" data-module1=\"module1\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"./assets\"});\n//]]>\n</script>"
      end
    end

    context 'with existing modules' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag(modules: ['module2', 'module3']).should == "<script data-main=\"application\" data-module2=\"module2\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"./assets\"});\n//]]>\n</script>"
      end
    end
  end
end
