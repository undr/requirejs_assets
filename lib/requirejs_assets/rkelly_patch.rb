module RequirejsAssets
  module RKellyPatch
    private
    def to_number(object)
      return RKelly::JS::Property.new('0', 0) unless object.value

      return_val =
        case object.value
        when :undefined
          RKelly::JS::NaN.new
        when false
          0
        when true
          1
        when Numeric
          object.value
        when ::String
          s = object.value.gsub(Regexp.new('(\A[\s\xA0]*|[\s\xA0]*\Z)', nil, 'n'), '')
          if s.length == 0
            0
          else
            case s
            when /^([+-])?Infinity/
              $1 == '-' ? -1.0/0.0 : 1.0/0.0
            when /\A[-+]?\d+\.\d*(?:[eE][-+]?\d+)?$|\A[-+]?\d+(?:\.\d*)?[eE][-+]?\d+$|\A[-+]?\.\d+(?:[eE][-+]?\d+)?$/, /\A[-+]?0[xX][\da-fA-F]+$|\A[+-]?0[0-7]*$|\A[+-]?\d+$/
              s.gsub!(/\.(\D)/, '.0\1') if s =~ /\.\w/
              s.gsub!(/\.$/, '.0') if s =~ /\.$/
              s.gsub!(/^\./, '0.') if s =~ /^\./
              s.gsub!(/^([+-])\./, '\10.') if s =~ /^[+-]\./
              s = s.gsub(/^[0]*/, '') if /^0[1-9]+$/.match(s)
              eval(s)
            else
              RKelly::JS::NaN.new
            end
          end
        when RKelly::JS::Base
          return to_number(to_primitive(object, 'Number'))
        end
      RKelly::JS::Property.new(nil, return_val)
    end

    def to_boolean(object)
      return RKelly::JS::Property.new(false, false) unless object.value
      value = object.value
      boolean =
        case value
        when :undefined
          false
        when true
          true
        when Numeric
          value == 0 || value.respond_to?(:nan?) && value.nan? ? false : true
        when ::String
          value.length == 0 ? false : true
        when RKelly::JS::Base
          true
        else
          raise
        end
      RKelly::JS::Property.new(boolean, boolean)
    end

    def to_int_32(object)
      number = to_number(object)
      value = number.value
      return number if value == 0
      if value.respond_to?(:nan?) && (value.nan? || value.infinite?)
        RKelly::JS::Property.new(nil, 0)
      end
      value = ((value < 0 ? -1 : 1) * value.abs.floor) % (2 ** 32)
      if value >= 2 ** 31
        RKelly::JS::Property.new(nil, value - (2 ** 32))
      else
        RKelly::JS::Property.new(nil, value)
      end
    end

    def to_primitive(object, preferred_type = nil)
      return object unless object.value
      case object.value
      when false, true, :undefined, ::String, Numeric
        RKelly::JS::Property.new(nil, object.value)
      when RKelly::JS::Base
        call_function(object.value.default_value(preferred_type))
      end
    end

    def additive_operator(operator, left, right)
      left, right = to_number(left).value, to_number(right).value

      left = left.respond_to?(:nan?) && left.nan? ? 0.0/0.0 : left
      right = right.respond_to?(:nan?) && right.nan? ? 0.0/0.0 : right

      result = left.send(operator, right)
      result = result.respond_to?(:nan?) && result.nan? ? JS::NaN.new : result

      RKelly::JS::Property.new(operator, result)
    end

    def call_function(property, arguments = [])
      function  = property.function || property.value
      case function
      when RKelly::JS::Function
        scope_chain.new_scope { |chain|
          function.js_call(chain, *arguments)
        }
      when UnboundMethod
        RKelly::JS::Property.new(:ruby,
          function.bind(property.binder).call(*(arguments.map { |x| x.value}))
        )
      else
        RKelly::JS::Property.new(:ruby,
          function.call(*(arguments.map { |x| x.value }))
        )
      end
    end
  end
end

class RKelly::Visitors::EvaluationVisitor
  include RequirejsAssets::RKellyPatch
end

%w{function pointcut real_sexp sexp}.each do |name|
  require "rkelly/visitors/#{name}_visitor"
end

require 'rkelly/parser'
require 'rkelly/runtime'
require 'rkelly/syntax_error'
