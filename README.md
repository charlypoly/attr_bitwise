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

You have a website with many locales (English, French, German...) with specific content in each locale. You want your users to be able to chose which content they want to see and you want to be able to query the users by the locales they have choosen.

```ruby

class User < ActiveRecord::Base
  include AttrBitwise

  attr_bitwise :locales, mapping: [:en, :fr, :de]

  scope :with_any_locales, lambda { |*locales_sym|
    where(locales_value: bitwise_union(*locales_sym, 'locales'))
  }

  scope :with_all_locales, lambda { |*locales_sym|
    where(locales_value: bitwise_intersection(*locales_sym, 'locales'))
  }

end

### 

# return all users who can see at least english or french content
User.with_any_locales(:en, :fr)

# return all users who can see english and french content
User.with_all_locales(:en, :fr)

```


## API

### "Dynamic methods"

**Notes :**

*Exemple with name = 'locales'*

*`value` is always a `Fixnum`*


- `Class#locales #=> [<Symbol>, ...]`

Return current value as symbols

- `Class#locale == value_or_sym) #=> Boolean`

Return true if current value equals (strictly) `value_or_sym`


- `Class#locale?(value_or_sym) #=> Boolean`

Return true if current value contains `value_or_sym`


- `Class#add_locale(value_or_sym) #=> Fixnum`

Add `value_or_sym` to value


- `Class#remove_locale(value_or_sym) #=> Fixnum`

Remove `value_or_sym` from value


- `Class#locales_union([value_or_sym, ..]) #=> [Fixnum, ..]`

Given an array of value (fixnum) or symbols, return bitwise union

- `Class#locales_intersection([value_or_sym, ..]) #=> [Fixnum, ..]`

Given an array of value (fixnum) or symbols, return bitwise intersection

- `Class#locales_mapping #=> Hash`

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
