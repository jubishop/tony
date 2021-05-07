module Tony
  module ContentFor
    def content_for(key)
      content_blocks[key].push(yield)
      return
    end

    def yield_content(key)
      content_blocks[key].join
    end

    private

    def content_blocks
      @content_blocks ||= Hash.new { |hash, key| hash[key] = [] }
    end
  end
end
