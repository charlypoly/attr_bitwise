# `attr_bitwise` ![https://circleci.com/gh/wittydeveloper/attr_bitwise.png?circle-token=7f58370c3b13faaf1954b9e8fe6c7b1fb329daf2](https://circleci.com/gh/wittydeveloper/attr_bitwise.png?circle-token=7f58370c3b13faaf1954b9e8fe6c7b1fb329daf2)
Bitwise attribute for ruby class and Rails model

## Features

- bitwise attribute + helpers, useful for storing multiple states in one place
- ActiveRecord compatible

## Install


### Inline

- `gem install attr_bitwise`

### Gemfile

- `gem 'attr_bitwise'`


## Usage

```ruby
attr_bitwise :<name>, mapping: <values_sym> [, column_name: <column_name>]
```

## Example

With a shop selling many types of fruits

```ruby

class Shop < ActiveRecord::Base
  include AttrBitwise

  attr_bitwise :fruits, mapping: [:apples, :bananas, :pears]

  scope :with_any_fruits, lambda { |*fruits_sym|
    where(fruits_value: bitwise_union(*fruits_sym, 'fruits'))
  }

  scope :with_all_fruits, lambda { |*fruits_sym|
    where(fruits_value: bitwise_intersection(*fruits_sym, 'fruits'))
  }

end

### 

# return all shops that sell at least bananas or apples
Shop.with_any_fruits(:apples, :bananas).select(:address)

# return all shops that sell bananas and apples
Shop.with_all_fruits(:apples, :bananas).select(:address)

```


## API

### "Dynamic methods"

**Notes :**

*Exemple with name = 'fruits'*

*`value` is always a `Fixnum`*


- `Class#fruits #=> [<Symbol>, ...]`

Return current value as symbols

- `Class#fruit == value_or_sym) #=> Boolean`

Return true if current value equals (strictly) `value_or_sym`


- `Class#fruit?(value_or_sym) #=> Boolean`

Return true if current value contains `value_or_sym`


- `Class#add_fruit(value_or_sym) #=> Fixnum`

Add `value_or_sym` to value


- `Class#remove_fruit(value_or_sym) #=> Fixnum`

Remove `value_or_sym` from value


- `Class#fruits_union([value_or_sym, ..]) #=> [Fixnum, ..]`

Given an array of value (fixnum) or symbols, return bitwise union

- `Class#fruits_intersection([value_or_sym, ..]) #=> [Fixnum, ..]`

Given an array of value (fixnum) or symbols, return bitwise intersection

- `Class#fruits_mapping #=> Hash`

Return symbol->value mapping

### Others methods

- `Class.to_bitwise_values(object, name) #=> [<Fixnum>, ...]`

Given an `Object` and a attribute name, return value (Fixnum) depending on mapping

- `Class.bitwise_union([Fixnum, ..], name) #=> [Fixnum, ..]`

Given an array of value (fixnum) or symbols and a attribute name, return bitwise union

- `Class.bitwise_intersection([Fixnum, ..], name) #=> [Fixnum, ..]`

Given an array of value (fixnum) or symbols and a attribute name, return bitwise intersection

----------------------------------------
Maintainers :  @wittydeveloper and @FSevaistre 
