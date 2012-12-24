require 'tilt'

module RequirejsAssets
  class Processor < Tilt::Template
    attr_reader :pathname

    def prepare
      @data += "\n" if data != '' && data !~ /\n\Z/m
    end

    def evaluate context, locals, &block
      @context = context
      process_directives
      ast.to_ecma + "\n\n"
    end

    def directives
      @directives ||= begin
        ast.inject([]) do|result,  node|
          if node.is_a?(RKelly::Nodes::FunctionCallNode) && (
            node.value.value === 'define' || node.value.value === 'requirejs'
          )
            result << [node.arguments.line, node.value.value.dup, *extract_directives(node), node]
          end
          result
        end
      end
    end

    protected
    attr_reader :context

    def process_directives
      directives.each do |line_number, directive, *args|
        context.__LINE__ = line_number
        send("process_#{directive}_directive", *args)
        context.__LINE__ = nil
      end
    end

    def process_define_directive module_name, deps, node
      node.arguments.value.unshift(RKelly::Nodes::StringNode.new("'#{name_of_processed_module}'")) unless module_name
      process_require_directive(module_name, deps, node)
      defined_modules << module_name
    end

    def process_requirejs_directive *args
      process_require_directive(*args)
    end

    def process_require_directive module_name, deps, node
      deps.each do |dependency|
        unless defined_modules.include?(dependency) || required_dependencies.include?(dependency)
          require_path(module_path_for(dependency))
          required_dependencies << dependency
        end
      end
    end

    def require_path path
      #path = "./#{path}" unless relative?(path)
      context.require_asset(path)
    end

    private
    def relative?(path)
      path =~ /^\.($|\.?\/)/
    end

    def ast
      @ast ||= js_parser.parse(data)
    end
    
    def js_parser
      @js_parser ||= RKelly::Parser.new
    end

    def safety_wrapper_ast
      @js_wrapper_ast ||= js_parser.parse('(function(){}).call(this);')
    end

    def safety_javascript source, return_string=nil
      unless source.is_a?(RKelly::Nodes::SourceElementsNode)
        return_string = true if return_string.nil?
        source = js_parser.parse(source)
      end

      function_node = safety_wrapper_ast.find do |node|
        node.is_a?(RKelly::Nodes::FunctionExprNode)
      end
      function_node.function_body.value = source
      return_string ? safety_wrapper_ast.to_ecma : safety_wrapper_ast
    end

    def extract_directives node
      module_name, deps = nil, nil

      node.arguments.value.dup.each do |n|
        case n
        when RKelly::Nodes::StringNode
          dependency_string = normalize_dependency_string(n.value.dup)
          
          if dependency_string.present?
            module_name = dependency_string 
          else
            node.arguments.value.delete(n)
          end
        when RKelly::Nodes::ArrayNode
          deps = n.each{}
        end
      end

      [module_name, (deps || []).map(&method(:normalize_dependency_string))]
    end

    def module_path_for name
      #context.resolve("#{Rails.application.config.requirejs.paths[name].presence || name}.js", content_type: :self)
      "#{Rails.application.config.requirejs.paths[name].presence || name}.js"
    end

    def name_of_processed_module
      path = context.logical_path
      Rails.application.config.requirejs.paths.invert[path].presence || path
    end

    def normalize_dependency_string dependency
      dependency.present? ? dependency.tr("\"'", '') : nil
    end

    def defined_modules
      @defined_modules ||= Set.new
    end

    def required_dependencies
      @required_dependencies ||= Set.new
    end
  end
end
