# -*- coding: utf-8; mode: ruby; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2
# -*- vim:fenc=utf-8:filetype=ruby:et:sw=2:ts=2:sts=2

# Provides UTF Friendly String Trimming Functions 
module StringTrim
  class << self
    # UTF Friendly trim of sentences.
    # @note 
    # @param [String] s Text to be trimmed.
    # @param [FixNum] supposed max length of the string, the excess will be trimmed in a UTF Friendly way
    # @return [String] Trimmed text.
    def utf_friendly_trim(text, length)
      text = text.to_s
      output = ""
      if length<=3 or (text.length <= length) or (text.length <= 3)
        output = text
      else
        str = String.new(text)
        # Match encoding of output string to that of input string
        str.force_encoding(text.encoding)  if str.respond_to?(:force_encoding)
        
        str.slice!(length-3..-1)
        # Ruby < 1.9 doesn't know how to slice between
        # characters, so deal specially with that case
        # so that we don't truncate in the middle of a UTF8 sequence,
        # which would be invalid.
        unless str.respond_to?(:force_encoding)
          # If the last remaining character is part of a UTF8 multibyte character,
          # keep truncating until we go past the start of a UTF8 character.
          # This assumes that this is a UTF8 string, which may be a false assumption
          # unless somebody has taken care to check the encoding of the source file.
          # We truncate at most 6 additional bytes, which is the length of the longest
          # UTF8 sequence
          6.times do
            c = str[-1, 1].to_i
            break if (c & 0x80) == 0      # Last character is plain ASCII: don't truncate
            str.slice!(-1, 1)            # Truncate character
            break if (c & 0xc0) == 0xc0   # Last character was the start of a UTF8 sequence, so we can stop now
          end
          # Append three dots to the end of line to indicate it's been truncated
          # (avoiding ellipsis character so as not to introduce more encoding issues)
          str = "#{str}..."
	end
	output = str
      end
      output
    end
  end
end
