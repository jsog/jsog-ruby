
require 'json'

class JSOG
  class << self

    # Convert a (Hash) object graph with potential cyclic references into a simpler structure
    # which contains @id and @ref references.
    #
    # @param obj [Hash] the object graph to convert
    # @return [Hash] an object graph with @ref instead of duplicate references
    def encode(obj)
      return do_encode(obj, {})
    end

    # Convert a (Hash) object graph that was encoded with encode() back to a normal structure
    # with cyclic references.
    #
    # @param obj [Hash] an object graph that was created with encode()
    # @return [Hash] an object graph with direct references instead of @ref
    def decode(obj)
      return do_decode(obj, {})
    end

    # Just like JSON.parse(), but reads JSOG. JSON is safe too.
    def parse(str)
      return decode(JSON.parse(str))
    end

    # Just like JSON.dump(), but outputs JSOG.
    def dump(obj)
      return JSON.dump(encode(obj))
    end


    private

    def do_encode(original, sofar)
      if original.is_a?(Array)
        return encode_array(original, sofar)
      elsif original.is_a?(Hash)
        return encode_object(original, sofar)
      else
        return original
      end
    end

    def encode_object(original, sofar)
      original_id = original.object_id.to_s

      if sofar.has_key?(original_id)
        return { '@ref' => original_id }
      end

      result = sofar[original_id] = { '@id' => original_id }

      original.each do |key, value|
        result[key] = do_encode(value, sofar)
      end

      return result
    end

    def encode_array(original, sofar)
      return original.map { |val| encode(val, sofar) }
    end

    #

    def do_decode(encoded, found)
      if encoded.is_a?(Array)
        return decode_array(encoded, found)
      elsif encoded.is_a?(Hash)
        return decode_object(encoded, found)
      else
        return encoded
      end
    end

    def decode_object(encoded, found)
      ref = encoded['@ref']
      return found[ref.to_s] if ref # be defensive if someone uses numbers in violation of the spec

      result = {}

      id = encoded['@id']
      found[id.to_s] = result if id # be defensive if someone uses numbers in violation of the spec

      encoded.each do |key, value|
        result[key] = do_decode(value, found)
      end

      return result
    end

    def decode_array(encoded, found)
      return encoded.map { |value| decode(value, found) }
    end

  end
end