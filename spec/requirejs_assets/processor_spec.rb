require 'spec_helper'

describe RequirejsAssets::Processor do
  let(:file){"./spec/files/processor/#{fixture}.js"}
  let(:source){File.open(file).read}

  describe '#directives' do
    let(:directives) do
      RequirejsAssets::Processor.new(file).directives.map do |directive|
        # Remove trailing rkelly node
        directive.pop
        directive
      end
    end

    context 'for one define' do
      let(:fixture){'one_define'}
      specify do
        directives.should == [
          [1, 'define', 'module_name', ['dependency_one', 'dependency_two']]
        ]
      end
    end

    context 'for one define with empty module' do
      let(:fixture){'one_define_with_empty_module'}
      specify do
        directives.should == [
          [1, 'define', nil, ['dependency_one', 'dependency_two']]
        ]
      end
    end

    context 'for one define without module' do
      let(:fixture){'one_define_without_module'}
      specify do
        directives.should == [
          [1, 'define', nil, ['dependency_one', 'dependency_two']]
        ]
      end
    end

    context 'for one define with empty dependencies' do
      let(:fixture){'one_define_with_empty_dependencies'}
      specify do
        directives.should == [
          [1, 'define', 'module_name', []]
        ]
      end
    end

    context 'for one define without dependencies' do
      let(:fixture){'one_define_without_dependencies'}
      specify do
        directives.should == [
          [1, 'define', 'module_name', []]
        ]
      end
    end
 
    context 'for one define without any arguments' do
      let(:fixture){'one_define_without_any_arguments'}
      specify do
        directives.should == [
          [1, 'define', nil, []]
        ]
      end
    end

    context 'for few defines' do
      let(:fixture){'multidefined_one'}
      specify do
        directives.should == [
          [1, 'define', 'module_one', ['dependency_one', 'dependency_two']],
          [2, 'define', 'module_two', ['module_one']],
          [9, 'define', 'module_three', ['dependency_two', 'dependency_three']],
        ]
      end
    end
  end

  describe '#evaluate' do
    let(:environment){Sprockets::Environment.new('./spec/files/processor/')}
    let(:context_instance){environment.context_class.new(environment, "#{fixture}.js", Pathname.new(file))}
    let(:processor){RequirejsAssets::Processor.new(file)}

    context 'for one define' do
      let(:fixture){'one_define'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        context_instance.should_receive(:require_asset).with("dependency_two.js")
        processor.evaluate(context_instance, {}).should == "define('module_name', ['dependency_one', 'dependency_two'], function() {\n\n});\n\n"
      end
    end

    context 'for one define with same dependencies' do
      let(:fixture){'one_define_with_same_dependencies'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        processor.evaluate(context_instance, {}).should == "define('module_name', ['dependency_one', 'dependency_one'], function() {\n\n});\n\n"
      end
    end

    context 'for one define without module' do
      let(:fixture){'one_define_without_module'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        context_instance.should_receive(:require_asset).with("dependency_two.js")
        processor.evaluate(context_instance, {}).should == "define('one_define_without_module', ['dependency_one', 'dependency_two'], function() {\n\n});\n\n"
      end
    end

    context 'for one define with empty module' do
      let(:fixture){'one_define_with_empty_module'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        context_instance.should_receive(:require_asset).with("dependency_two.js")
        processor.evaluate(context_instance, {}).should == "define('one_define_with_empty_module', ['dependency_one', 'dependency_two'], function() {\n\n});\n\n"
      end
    end

    context 'for one define without any arguments' do
      let(:fixture){'one_define_without_any_arguments'}
      specify do
        processor.evaluate(context_instance, {}).should == "define('one_define_without_any_arguments', function() {\n\n});\n\n"
      end
    end

    context 'for few defines' do
      let(:fixture){'multidefined_one'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        context_instance.should_receive(:require_asset).with("dependency_two.js")
        context_instance.should_receive(:require_asset).with("dependency_three.js")
        processor.evaluate(context_instance, {}).should == "define('module_one', ['dependency_one', 'dependency_two'], function() {\n\n});\ndefine('module_two', ['module_one'], function() {\n  var method = function(x, y) {\n    return [x, y];\n  };\n  return method('application', ['module1', 'module2']);\n});\ndefine('module_three', ['dependency_two', 'dependency_three'], function() {\n\n});\n\n"
      end
    end

    context 'when used aliases' do
      let(:fixture){'one_define_with_aliases'}

      before do
        Rails.application.config.requirejs.paths = {
          'alias_one_define_with_aliases' => 'one_define_with_aliases',
          'alias_dependency_one' => 'alias/dependency_one',
          'alias_dependency_two' => 'alias/dependency_two'
        }
      end

      specify do
        context_instance.should_receive(:require_asset).with("alias/dependency_one.js")
        context_instance.should_receive(:require_asset).with("alias/dependency_two.js")
        processor.evaluate(context_instance, {}).should == "define('alias_one_define_with_aliases', ['alias_dependency_one', 'alias_dependency_two'], function() {\n\n});\n\n"
      end
    end
  end
end
