require "active_support"
require "active_support/concern"
require "active_support/core_ext"
require "attr_bitwise/version"

# Helper to define a bits based value on a Rails model attribute
#   this helper expose a set of methods to make bitwise operations
#
#
# Usage :
#   attr_bitwise :<name>, [column_name: <column_name>,] mapping: <values_sym>
#
# Example
# class MyModel < ActiveRecord::Base
#   include AttrBitwise
#
#   attr_bitwise :payment_types, mapping: [:slots, :credits]
# end
#
# Will define the following high-level methods :
#   - Class#payment_types => [<Symbol>, ...]
#   - Class#payment_type?(value_or_sym) => Boolean
#   - Class#add_payment_type(value_or_sym) => Fixnum
#   - Class#remove_payment_type(value_or_sym) => Fixnum
#
# Will define the following low-level methods :
#   - Class.to_bitwise_values(object, name) => [<Fixnum>, ...]
#   - Class#payment_types_union([Fixnum, ..]) => [Fixnum, ..]
#   - Class.bitwise_union([Fixnum, ..], name) => [Fixnum, ..]
#   - Class#payment_types_intersection([Fixnum, ..]) => [Fixnum, ..]
#   - Class.bitwise_intersection([Fixnum, ..], name) => [Fixnum, ..]
#   - Class#payment_types_mapping => Hash
#
# More details in methods definition
module AttrBitwise
  extend ActiveSupport::Concern


  # Custom class that allow to use shortcut :
  #   my_column == :banana
  # instead of
  #   my_column == [:banana]
  class ComparableSymbolsArray < Array
    def ==(other_object)
      if other_object.is_a?(Symbol)
        self.size == 1 && self.first == other_object
      else
        super(other_object)
      end
    end
  end

  # ClassMethods
  module ClassMethods
    ######################
    # public class methods
    ######################

    # Usage :
    #   attr_bitwise :payment_types, mapping: [:slots, :credits],
    #     column_name: 'payment_types_value'
    #
    def attr_bitwise(name, column_name: nil, mapping:)
      column_name = "#{name}_value" unless column_name.present?

      # build mapping
      bitwise_mapping = build_mapping(mapping, name)

      # mask to symbols helper
      define_method("#{name}") { send(:value_getter, column_name, bitwise_mapping) }
      define_method("#{name}=") do |values_or_symbols_array|
        send(:value_setter, column_name, Array(values_or_symbols_array), bitwise_mapping)
      end

      # masks symbol presence
      define_method("#{name.to_s.singularize}?") do |value_or_symbol|
        send(:value?, column_name, force_to_bitwise_value(value_or_symbol, bitwise_mapping))
      end

      # add value to mask
      define_method("add_#{name.to_s.singularize}") do |value_or_symbol|
        send(:add_value, column_name, force_to_bitwise_value(value_or_symbol, bitwise_mapping))
      end

      # remove value from mask
      define_method("remove_#{name.to_s.singularize}") do |value_or_symbol|
        send(:remove_value, column_name, force_to_bitwise_value(value_or_symbol, bitwise_mapping))
      end

      # compute values union against mask
      define_method("#{name}_union") do |*mixed_array|
        self.class.bitwise_union(*mixed_array, name)
      end

      # compute values intersection against mask
      define_method("#{name}_intersection") do |*mixed_array|
        self.class.bitwise_intersection(*mixed_array, name)
      end
    end

    # given a payment_values array, return a possible matches
    #   for a union
    #
    # with PAYMENT_TYPES_MAPPING = { credits: 0b001, slots: 0b010, paypal: 0b100 }
    # see http://www.calleerlandsson.com/2015/02/16/flags-bitmasks-and-unix-file-system-permissions-in-ruby/
    #
    # bitwise_union(:slots, :credits, 'payment_types') => [0b011, 0b111]
    def bitwise_union(*mixed_array, name)
      values_array = mixed_array.map { |v| to_bitwise_values(v, name) }
      mapping = mapping_from_name(name)
      mask = []

      values_array.each do |pv|
        mapping.values.each do |pvv|
          mask << (pv | pvv)
        end
      end

      mask.uniq
    end

    # given a values_arr ay array, return a possible matches
    #   for a intersection
    #
    # with PAYMENT_TYPES_MAPPING = { credits: 0b001, slots: 0b010, paypal: 0b100 }
    # see http://www.calleerlandsson.com/2015/02/16/flags-bitmasks-and-unix-file-system-permissions-in-ruby/
    #
    # bitwise_intersection(:slots, :credits, 'payment_types') => [0b101, 0b100, 0b011, 0b111]
    def bitwise_intersection(*mixed_array, name)
      values_array = mixed_array.map { |v| to_bitwise_values(v, name) }
      mapping = mapping_from_name(name)
      mask = []
      val = values_array.reduce(&:|)

      mapping.values.each do |pv|
        mask << (pv | val)
      end

      mask.uniq
    end

    # given an Object, return proper Fixnum value, depending of mapping
    def to_bitwise_values(object, name)
      mapping = mapping_from_name(name)
      if object.is_a?(Array)
        object.map { |v| force_to_bitwise_value(v, mapping) }
      elsif object.is_a?(Hash)
        object.values.map { |v| force_to_bitwise_value(v, mapping) }
      else
        force_to_bitwise_value(object, mapping)
      end
    end

    # Given a raw value (int) or a symbol, return proper raw value (int)
    def force_to_bitwise_value(value_or_symbol, mapping)
      if value_or_symbol.is_a?(Symbol)
        mapping[value_or_symbol]
      else
        value_or_symbol.to_i
      end
    end

    #######################
    # Private class methods
    #######################

    private


    # return mapping given a bitwise name
    def mapping_from_name(name)
      const_get("#{name}_mapping".upcase)
    end

    # build internal bitwise key-value mapping
    #   it add a zero value, needed for bits operations
    #
    # each sym get a power of 2 value
    def build_mapping(symbols, name)
      mapping = {}.tap do |hash|
        if symbols.is_a?(Hash)
          validate_user_defined_values!(symbols, name)
          hash.merge!(symbols.sort_by{|k,v| v}.to_h)
        else
          symbols.each_with_index do |key, i|
            hash[key] = 2**i
          end
        end
        hash[:empty] = 0
      end
      # put mapping in unique constant
      const_mapping_name = "#{name}_mapping".upcase
      const_set(const_mapping_name, mapping)
    end

    def validate_user_defined_values!(hash, name)
      hash.select{|key,value| (Math.log2(value) % 1.0)!=0}.tap do |invalid_options|
        if invalid_options.any?
          raise(ArgumentError, "#{name} value should be a power of two number (#{invalid_options.to_s})")
        end
      end
    end
  end


  ##########################
  # Private instance methods
  ##########################

  private


  def force_to_bitwise_value(value_or_symbol, mapping)
    self.class.force_to_bitwise_value(value_or_symbol, mapping)
  end

  # Given a raw value (int) return proper raw value (int)
  def value_to_sym(value, mapping)
    mapping.invert[value]
  end

  # Return current value to symbols array
  #   Ex : 011 => :slots, :credits
  def value_getter(name, mapping)
    ComparableSymbolsArray.new(
      mapping.values.select { |pv| (send(name) & pv) != 0 }.
        map { |v| value_to_sym(v, mapping) }
    )
  end

  # Set current values from values array
  def value_setter(column_name, values_or_symbols_array, mapping)
    send("#{column_name}=", 0)
    values_or_symbols_array.each { |val| add_value(column_name, force_to_bitwise_value(val, mapping)) }
  end

  # Return if value presents in mask (raw value) and mask set
  def value?(column_name, val)
    ![0, false].include?(send(column_name) & val)
  end

  # add `value_or_symbol` to mask
  #   Ex, with values = `10`
  #     add_value(1) => 11
  def add_value(column_name, val)
    send("#{column_name}=", send(column_name) | val)
  end

  # remove `value_or_symbol` to mask
  #   Ex, with values = `11`
  #     remove_value(1) => 10
  def remove_value(column_name, val)
    send("#{column_name}=", send(column_name) & ~val)
  end
end
