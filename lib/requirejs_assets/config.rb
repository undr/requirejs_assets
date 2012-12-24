module RequirejsAssets
  class Config < ActiveSupport::OrderedOptions
    def configure
      yield self
      self
    end
  end
end
