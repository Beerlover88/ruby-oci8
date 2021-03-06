# properties.rb -- implements OCI8.properties
#
# Copyright (C) 2010-2012 KUBO Takehiro <kubo@jiubao.org>

#
class OCI8

  @@properties = {
    :length_semantics => :byte,
    :bind_string_as_nchar => false,
    :float_conversion_type => :ruby,
    :statement_cache_size => 0,
  }

  if OCI8.oracle_client_version < OCI8::ORAVER_9_2
    @@properties[:statement_cache_size] = nil
  end

  def @@properties.[](name)
    raise IndexError, "No such property name: #{name}" unless @@properties.has_key?(name)
    super(name)
  end

  def @@properties.[]=(name, val)
    raise IndexError, "No such property name: #{name}" unless @@properties.has_key?(name)
    case name
    when :length_semantic
      if val != :byte and val != :char
        raise ArgumentError, "Invalid property value #{val} for :length_semantics."
      end
    when :bind_string_as_nchar
      val = val ? true : false
    when :float_conversion_type
      # handled by native code in oci8lib_xx.so.
      OCI8.__set_property(name, val)
    when :statement_cache_size
      if OCI8.oracle_client_version < OCI8::ORAVER_9_2
        raise RuntimeError, ":statement_cache_size is disabled on Oracle 9iR1 client."
      end
      val = val.to_i
      raise ArgumentError, "The property value for :statement_cache_size must not be negative." if val < 0
    end
    super(name, val)
  end

  # call-seq:
  #   OCI8.properties -> a customized Hash
  #
  # (new in 2.0.5)
  #
  # Returns a Hash which ruby-oci8 global settings.
  # The hash's setter and getter methods are customized to check
  # property names and values.
  #
  #   # get properties
  #   OCI8.properties[:bind_string_as_nchar]  # => false
  #   OCI8.properties[:invalid_property_name] # raises an IndexError
  #
  #   # set properties
  #   OCI8.properties[:bind_string_as_nchar] = true
  #   OCI8.properties[:invalid_property_name] = true # raises an IndexError
  #
  # Supported properties are listed below:
  #
  # [:length_semantics]
  #     (new in 2.1.0)
  #     
  #     +:char+ when Oracle character length is counted by the number of characters.
  #     +:byte+ when it is counted by the number of bytes.
  #     The default setting is +:byte+ because +:char+ causes unexpected behaviour on
  #     Oracle 9i.
  #
  # [:bind_string_as_nchar]
  #     +true+ when string bind variables are bound as NCHAR,
  #     otherwise +false+. The default value is +false+.
  #
  # [:float_conversion_type]
  #     (new in 2.1.0)
  #     
  #     +:ruby+ when Oracle decimal numbers are converted to ruby Float values
  #     same as Float#to_s does. (default)
  #     +:oracle:+ when they are done by Oracle OCI functions.
  #     
  #     From ruby 1.9.2, a float value converted from Oracle number 15.7 by
  #     the Oracle function OCINumberToReal() makes a string representation
  #     15.700000000000001 by Float#to_s.
  #     See: http://rubyforge.org/forum/forum.php?thread_id=50030&forum_id=1078
  #
  # [:statement_cache_size]
  #     (new in 2.1.1)
  #     
  #     The statement cache size per each session. The default size is 0, which
  #     means no statement cache, since 2.1.2. It was 20 in 2.1.1.
  #     This feature is available on Oracle 9iR2 or later.
  #     See: http://docs.oracle.com/cd/E11882_01/appdev.112/e10646/oci09adv.htm#i471377
  #
  def self.properties
    @@properties
  end
end
