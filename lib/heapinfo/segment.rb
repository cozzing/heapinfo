module HeapInfo
  # Record the base address and name in maps
  class Segment
    # Base address of segment
    attr_reader :base
    # Name of segment
    attr_reader :name
    # Instantiate a {HeapInfo::Segment} object
    # @param [Integer] base Base address
    # @param [String] name Name of segment
    def initialize(base, name)
      @base = base
      @name = name
    end

    # Hook <tt>#to_s</tt> for pretty printing
    # @return [String] Information of name and base address wrapper with color codes.
    def to_s
      format("%-28s\tbase @ #{Helper.color(format('%#x', base))}\n", Helper.color(name.split('/')[-1]))
    end

    # Helper for creating a {HeapInfo::Segment}.
    #
    # Search the specific <tt>pattern</tt> in <tt>maps</tt> and return a {HeapInfo::Segment} object.
    #
    # @param [Array] maps <tt>maps</tt> is in form of the return value of {Helper::ClassMethods#parse_maps}.
    # @param [Regexp, String] pattern
    #   The segment name want to match in maps. If +String+ is given, the pattern is matched as a substring.
    # @return [HeapInfo::Segment, nil]
    #   The request {HeapInfo::Segment} object. If the pattern is not matched, instance of {Nil} will be returned.
    def self.find(maps, pattern)
      return Nil.new if pattern.nil?
      needs = maps.select { |m| pattern.is_a?(Regexp) ? m[3] =~ pattern : m[3].include?(pattern) }
      new(needs.map(&:first).min, needs[0][3]) unless needs.empty?
    end
  end
end
