module VersionRangeCalculator
  class VersionsRange
    def initialize(versions_numbers)
      @versions = versions_numbers.map{ |n| Version.new n }
    end

    def is_first_in_level?(number, level)
      if number.kind_of? Version
        version = number
      else
        version = find_version(number)
      end

      previous_version = get_previous_version(version)

      return true if previous_version.nil?

      similarity_level = version.similarity_level(previous_version)

      if similarity_level >= level
        compare_section(version.sections[similarity_level], previous_version.sections[similarity_level]) < 0
      else
        true
      end
    end

    def is_last_in_level?(number, level)
      if number.kind_of? Version
        version = number
      else
        version = find_version(number)
      end

      next_version = get_next_version(version)

      return true if next_version.nil?

      similarity_level = version.similarity_level(next_version)

      if similarity_level >= level
        compare_section(version.sections[similarity_level], next_version.sections[similarity_level]) > 0
      else
        true
      end
    end

    def range_string(number1, number2)
      version1 = find_version(number1)
      version2 = find_version(number2)

      similarity = version1.similarity_level(version2)

      if is_first_in_level?(version1, similarity) and is_last_in_level?(version2, similarity)
        (version1.sections[0, similarity] + ['x']).join('.')
      else
        "#{version1.number}-#{version2.number}"
      end
    end

    private

    def get_previous_version(version)
      # version = version.kind_of?(Version) ? version : find_version(version)
      index = @versions.index(version)
      (index.nil? or index == 0) ? nil : @versions[index-1]
    end

    def get_next_version(version)
      # version = version.kind_of?(Version) ? version : find_version(version)
      index = @versions.index(version)
      (index.nil? or index == @versions.size-1) ? nil : @versions[index+1]
    end

    def find_version(number)
      @versions.find{ |v| v.number == number }
    end

    def compare_section(section1, section2)
      return 0 if section1.nil? and section2.nil?
      return -1 if section1.nil?
      return 1 if section2.nil?

      numeric1 = section1.match(/[0-9]+/).to_s.to_i
      numeric2 = section2.match(/[0-9]+/).to_s.to_i
      alpha1 = section1.match(/[a-z]+/).to_s
      alpha2 = section2.match(/[a-z]+/).to_s

      if numeric1 == numeric2
        alpha1 <=> alpha2
      else
        numeric1 - numeric2
      end
    end
  end
end