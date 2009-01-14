# A hash with method_missing implemented so you can make calls
# i.e.: hash.foo.bar => hash[:foo][:bar]
#       hash.foo "bar" => hash[:foo] = "bar"
class CallHash < Hash
  alias_method :orig_method_missing, :method_missing

  def method_missing(meth, *args)
    return nil if !key?(meth) && args.empty?
    if args.empty?
      self[meth]
    else
      self[meth] = args.size == 1 ? args.first : args
    end
  end

  # Recursively build a CallHash from a Hash.
  # Every value that is a Hash will be converted to a CallHash
  def self.recurse(hash)
    callhash = CallHash.new
    hash.each do |key,val| 
      callhash[key] = val.instance_of?(Hash) ? recurse(val) : val
    end
    callhash
  end

  # Different inspect method to distinguish from Hash
  def inspect
    strs = []
    each do |k,v|
      if v.instance_of?(CallHash)
        v.each do |ck, cv|
          strs << "%s.%s: %s" % [k, ck, cv.inspect]
        end
      else
        strs << "%s: %s" % [k, v.inspect]
      end
    end
    "{%s}" % strs.join(', ')
  end
end
