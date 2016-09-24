module Grifork::Concerns
  module Loggable
    def logger
      Grifork.logger
    end
  end
end
