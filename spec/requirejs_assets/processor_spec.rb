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
    let(:fixture_prefix){''}
    let(:result){File.open("./spec/files/processor/results/#{fixture}#{fixture_prefix}.js").read}

    context 'for one define' do
      let(:fixture){'one_define'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        context_instance.should_receive(:require_asset).with("dependency_two.js")
        processor.evaluate(context_instance, {}).should == result
      end
    end

    context 'for one define with same dependencies' do
      let(:fixture){'one_define_with_same_dependencies'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        processor.evaluate(context_instance, {}).should == result
      end
    end

    context 'for one define without module' do
      let(:fixture){'one_define_without_module'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        context_instance.should_receive(:require_asset).with("dependency_two.js")
        processor.evaluate(context_instance, {}).should == result
      end
    end

    context 'for one define with empty module' do
      let(:fixture){'one_define_with_empty_module'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        context_instance.should_receive(:require_asset).with("dependency_two.js")
        processor.evaluate(context_instance, {}).should == result
      end
    end

    context 'for one define without any arguments' do
      let(:fixture){'one_define_without_any_arguments'}
      specify do
        processor.evaluate(context_instance, {}).should == result
      end
    end

    context 'for few defines' do
      let(:fixture){'multidefined_one'}
      specify do
        context_instance.should_receive(:require_asset).with("dependency_one.js")
        context_instance.should_receive(:require_asset).with("dependency_two.js")
        context_instance.should_receive(:require_asset).with("dependency_three.js")
        processor.evaluate(context_instance, {}).should == result
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
        processor.evaluate(context_instance, {}).should == result
      end
    end

    context 'when used shim module' do
      let(:fixture){'shim_module'}

      context 'and config empty' do
        let(:fixture_prefix){'_empty_options'}
        before do
          Rails.application.config.requirejs.shim = {
            'shim_module' => {}
          }
        end

        specify do
          processor.evaluate(context_instance, {}).should == result
        end
      end

      context 'and config has exports option' do
        let(:fixture_prefix){'_exports_option'}
        before do
          Rails.application.config.requirejs.shim = {
            'shim_module' => {exports: 'module'}
          }
        end

        specify do
          processor.evaluate(context_instance, {}).should == result
        end
      end

      context 'and config has deps option' do
        let(:fixture_prefix){'_deps_option'}
        before do
          Rails.application.config.requirejs.shim = {
            'shim_module' => {deps: ['dep1', 'dep2']}
          }
        end

        specify do
          processor.evaluate(context_instance, {}).should == result
        end
      end

      context 'and config has deps and exports options' do
        let(:fixture_prefix){'_deps_exports_options'}
        before do
          Rails.application.config.requirejs.shim = {
            'shim_module' => {deps: ['dep1', 'dep2'], exports: 'module'}
          }
        end

        specify do
          processor.evaluate(context_instance, {}).should == result
        end
      end

      context 'and config has array of deps' do
        let(:fixture_prefix){'_array_of_deps'}
        before do
          Rails.application.config.requirejs.shim = {
            'shim_module' => ['dep1', 'dep2']
          }
        end

        specify do
          processor.evaluate(context_instance, {}).should == result
        end
      end
    end
  end
end
