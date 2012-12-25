require 'spec_helper'

describe RequirejsAssets::Helper do
  include RSpec::Rails::HelperExampleGroup

  describe '#requirejs_include_tag' do
    context 'without options' do
      specify do
        helper.requirejs_include_tag.should == "<script data-main=\"application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
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
        helper.requirejs_include_tag.should == "<script data-main=\"application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"},\"some_lib\":[\"dependency\"]}});\n//]]>\n</script>"
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
        helper.requirejs_include_tag(shim: {'some_lib' => ['dependency']}).should == "<script data-main=\"application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n//<![CDATA[\nrequirejs.config({\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"},\"some_lib\":[\"dependency\"]}});\n//]]>\n</script>"
      end
    end
  end
end
