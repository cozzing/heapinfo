module HeapInfo
  class Libc < Segment
    def main_arena_offset
      return @main_arena_offset if @main_arena_offset
      return nil unless exhaust_search :main_arena
      @main_arena_offset
    end

    def main_arena
      return @main_arena.reload! if @main_arena
      off = main_arena_offset
      return if off.nil?
      @main_arena = Arena.new(off + self.base, process.bits, lambda{|*args| process.dump(*args)})
    end

    def self.find(maps, name, process)
      obj = super(maps, name)
      obj.send(:process=, process)
      obj
    end


  private
    attr_accessor :process
    # only for searching offset of main_arena now
    def exhaust_search(symbol)
      return false if symbol != :main_arena
      # TODO: read from cache
      @main_arena_offset = resolve_main_arena_offset
      true
    end

    def resolve_main_arena_offset
      tmp_elf = HeapInfo::TMP_DIR + "/get_arena"
      libc_file = HeapInfo::TMP_DIR + "/libc.so.6"
      ld_file = HeapInfo::TMP_DIR + "/ld.so"
      flags = "-w #{@process.bits == 32 ? '-m32' : ''}"
      %x(cp #{self.name} #{libc_file} && \
         cp #{@process.ld.name} #{ld_file} && \
         gcc #{flags} #{File.expand_path('../tools/get_arena.c', __FILE__)} -o #{tmp_elf} 2>&1 > /dev/null && \
         #{ld_file} --library-path #{HeapInfo::TMP_DIR} #{tmp_elf} && \
         rm #{tmp_elf} #{libc_file} #{ld_file}).to_i(16)
    end
  end
end
