require 'spec_helper'

describe RequirejsAssets::AssetsHelper do
  include RSpec::Rails::HelperExampleGroup

  describe '#requirejs_include_tag' do
    context 'without options' do
      specify do
        helper.requirejs_include_tag.should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
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
        helper.requirejs_include_tag.should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"},\"some_lib\":[\"dependency\"]},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
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
        helper.requirejs_include_tag(runtime: {shim: {'some_lib' => ['dependency']}}).should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"},\"some_lib\":[\"dependency\"]},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
      end
    end

    context 'without modules' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag.should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
      end
    end

    context 'with all modules' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag(modules: :all).should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application\" data-module1=\"/assets/module1\" data-module2=\"/assets/module2\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
      end
    end

    context 'with modules as string' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag(modules: 'module1').should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application\" data-module1=\"/assets/module1\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
      end
    end

    context 'with modules as array' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag(modules: ['module1']).should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application\" data-module1=\"/assets/module1\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
      end
    end

    context 'with existing modules' do
      before do
        Rails.application.config.requirejs.configure do |config|
          config.modules = ['module1', 'module2']
        end
      end

      specify do
        helper.requirejs_include_tag(modules: ['module2', 'module3']).should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application\" data-module2=\"/assets/module2\" src=\"/assets/require.js\" type=\"text/javascript\"></script>"
      end
    end

    context 'digest' do
      before do
        Rails.application.config.assets.digest = true
        Rails.application.config.assets.digests = {
          'application.js' => 'application-1.js',
          'require.js' => 'require-2.js',
          'module1.js' => 'module1-3.js',
          'module2.js' => 'module2-4.js'
        }
      end

      context 'without options' do
        specify do
          helper.requirejs_include_tag.should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application-1\" src=\"/assets/require-2.js\" type=\"text/javascript\"></script>"
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
          helper.requirejs_include_tag.should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"},\"some_lib\":[\"dependency\"]},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application-1\" src=\"/assets/require-2.js\" type=\"text/javascript\"></script>"
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
          helper.requirejs_include_tag(runtime: {shim: {'some_lib' => ['dependency']}}).should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"},\"some_lib\":[\"dependency\"]},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application-1\" src=\"/assets/require-2.js\" type=\"text/javascript\"></script>"
        end
      end

      context 'without modules' do
        before do
          Rails.application.config.requirejs.configure do |config|
            config.modules = ['module1', 'module2']
          end
        end

        specify do
          helper.requirejs_include_tag.should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application-1\" src=\"/assets/require-2.js\" type=\"text/javascript\"></script>"
        end
      end

      context 'with all modules' do
        before do
          Rails.application.config.requirejs.configure do |config|
            config.modules = ['module1', 'module2']
          end
        end

        specify do
          helper.requirejs_include_tag(modules: :all).should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application-1\" data-module1=\"/assets/module1-3\" data-module2=\"/assets/module2-4\" src=\"/assets/require-2.js\" type=\"text/javascript\"></script>"
        end
      end

      context 'with modules as string' do
        before do
          Rails.application.config.requirejs.configure do |config|
            config.modules = ['module1', 'module2']
          end
        end

        specify do
          helper.requirejs_include_tag(modules: 'module1').should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application-1\" data-module1=\"/assets/module1-3\" src=\"/assets/require-2.js\" type=\"text/javascript\"></script>"
        end
      end

      context 'with modules as array' do
        before do
          Rails.application.config.requirejs.configure do |config|
            config.modules = ['module1', 'module2']
          end
        end

        specify do
          helper.requirejs_include_tag(modules: ['module1']).should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application-1\" data-module1=\"/assets/module1-3\" src=\"/assets/require-2.js\" type=\"text/javascript\"></script>"
        end
      end

      context 'with existing modules' do
        before do
          Rails.application.config.requirejs.configure do |config|
            config.modules = ['module1', 'module2']
          end
        end

        specify do
          helper.requirejs_include_tag(modules: ['module2', 'module3']).should == "<script type=\"text/javascript\">\n//<![CDATA[\nvar require = {\"paths\":{\"module1\":\"prefix/module1\"},\"shim\":{\"underscore\":{\"exports\":\"_\"}},\"baseUrl\":\"/assets\"};\n//]]>\n</script>\n<script data-main=\"/assets/application-1\" data-module2=\"/assets/module2-4\" src=\"/assets/require-2.js\" type=\"text/javascript\"></script>"
        end
      end
    end
  end
end
