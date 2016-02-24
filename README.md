# `attr_bitwise` ![https://circleci.com/gh/wittydeveloper/attr_bitwise.png?circle-token=7f58370c3b13faaf1954b9e8fe6c7b1fb329daf2](https://circleci.com/gh/wittydeveloper/attr_bitwise.png?circle-token=7f58370c3b13faaf1954b9e8fe6c7b1fb329daf2)
Bitwise attribute for ruby class and Rails model

```ruby
# Helper to define a bits based value on a Rails model attribute
#   this helper expose a set of methods to make bitwise operations
#
#
# Usage :
#   attr_bitwise :<name>, [column_name: <column_name>,] mapping: <values_sym>
#
# Example
# class MyModel < ActiveRecord::Base
#   include BitwiseAttr
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
```


## Install


### Inline

- `gem install bitwise_attr`

### Gemfile

- `gem 'bitwise_attr'`


----------------------------------------
Maintainers :  @wittydeveloper and @FSevaistre 
