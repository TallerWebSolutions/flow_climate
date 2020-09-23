module CircleCI
  module Parallel
    module Version
      MAJOR = 0
      MINOR = 5
      PATCH = 0

      def self.to_s
        [MAJOR, MINOR, PATCH].join('.')
      end
    end
  end
end
