module Grifork::Mixin
  module Loggable
    def logger
      Grifork.logger
    end
  end
end
