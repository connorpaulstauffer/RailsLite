require 'uri'

class Params
  def initialize(req, route_params = {})
    parse_www_encoded_form(req.query_string)
    parse_www_encoded_form(req.body)
    @params = my_deep_merge(@params, route_params)
  end

  def [](key)
    @params[key.to_s] || @params[key.to_sym]
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  def parse_www_encoded_form(www_encoded_form)
    @params ||= {}
    return if www_encoded_form.nil?
    URI::decode_www_form(www_encoded_form).each do |key, val|
      this_hash = hashize(parse_key(key) << val)
      @params = my_deep_merge(@params, this_hash)
    end
  end

  def hashize(array)
    return {array.first => array.last} if array.length == 2
    { array.first => hashize(array.drop(1))}
  end

  def my_deep_merge(hash1, hash2)
    key_intersection = (hash1.keys & hash2.keys)
    return hash1.merge(hash2) if key_intersection.empty?

    unique1 = hash1.reject { |k, _| hash2.keys.include?(k) }
    unique2 = hash2.reject { |k, _| hash1.keys.include?(k) }
    merged = unique1.merge(unique2)

    key_intersection.each do |common_key|
      val1, val2 = hash1[common_key], hash2[common_key]
      raise "value conflict" unless [val1, val2].all? { |el| el.is_a?(Hash) }
      merged[common_key] = my_deep_merge(val1, val2)
    end
    merged
  end

  def parse_key(key)
    key.split(/[\[\]]/).reject(&:empty?)
  end
end
