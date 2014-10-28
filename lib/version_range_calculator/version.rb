module VersionRangeCalculator
  class Version
    attr_reader :number

    def initialize(number)
      @number = number # it's actually a string
    end

    def level
      @level ||= (@number || '').split('.').size
    end

    def sections(picked_level = level)
      @sections ||= (@number || '').split('.').slice(0, picked_level)
    end

    def similarity_level(version)
      i = 0
      while (sections[i] == version.sections[i]) and (i < sections.size) do
        i += 1
      end
      i
    end
  end
end
