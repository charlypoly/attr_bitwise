# `attr_bitwise` ![https://circleci.com/gh/wittydeveloper/attr_bitwise.png?circle-token=7f58370c3b13faaf1954b9e8fe6c7b1fb329daf2](https://circleci.com/gh/wittydeveloper/attr_bitwise.png?circle-token=7f58370c3b13faaf1954b9e8fe6c7b1fb329daf2) [![Gem Version](https://badge.fury.io/rb/attr_bitwise.svg)](https://badge.fury.io/rb/attr_bitwise)
Bitwise attribute for ruby class and Rails model

## Features

- bitwise attribute + helpers, useful for storing multiple states in one place
- ActiveRecord compatible

[Please read this article for some concrete examples](https://medium.com/jobteaser-dev-team/rails-bitwise-enum-with-super-powers-5030bda5dbab)


## Install


### Inline

- `gem install attr_bitwise`

### Gemfile

- `gem 'attr_bitwise'`


## Usage

```ruby
attr_bitwise :<name>, mapping: <values_sym> [, column_name: <column_name>]
```

Alternatively, you can explicitly specify your states by supplying a hash with the values.

```ruby
attr_bitwise :<name>, mapping: {<sym1: 1, sym2: 2, sym3: 4>} [, column_name: <column_name>]
```


## Example

You have a website with many locales (English, French, German...) with specific content in each locale. You want your users to be able to chose which content they want to see and you want to be able to query the users by the locales they have chosen.

Start with migration
```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      # [...]
      t.integer :locales_value
    end
  end
end
```

Model
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

**Examples with <code>name = 'locales'</code>**

### High level methods
<table>
  <tr>
    <th>Method</th>
    <th>Return</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>
      <code>Class#locales</code>
    </td>
    <td>
      <code>[<Symbol>, ...]</code>
    </td>
    <td>
      Return values as symbols
    </td>
  </tr>
  <tr>
    <td>
      <code>Class#locales=([value_or_sym, ..])</code>
    </td>
    <td>
      <code>[<Symbol>, ...]</code>
    </td>
    <td>
      Given an array of values (Fixnum or Symbol) or single value (Fixnum or Symbol) add them to value.
    </td>
  </tr>
  <tr>
    <td>
      <code>Class#locale == fixnum_or_sym</code>
    </td>
    <td>
      <code>Boolean</code>
    </td>
    <td>
      Return true if value contains only Fixnum or Symbol
    </td>
  </tr>
  <tr>
    <td>
      <code>Class#locale?(fixnum_or_sym)</code>
    </td>
    <td>
      <code>Boolean</code>
    </td>
    <td>
      Return true if value contains Fixnum or Symbol
    </td>
  </tr>
  <tr>
    <td>
      <code>Class#add_locale(value_or_sym)</code>
    </td>
    <td>
      <code>Fixnum</code>
    </td>
    <td>
      Add Fixnum or Symbol to value
    </td>
  </tr>
  <tr>
    <td>
      <code>Class#remove_locale(value_or_sym)</code>
    </td>
    <td>
      <code>Fixnum</code>
    </td>
    <td>
      Remove Fixnum or Symbol to value
    </td>
  </tr>
  <tr>
    <td>
      <code>Class#locales_union([value_or_sym, ..])</code>
    </td>
    <td>
      <code>[Fixnum, ..]</code>
    </td>
    <td>
      Given an array of values (Fixnum or Symbol), return bitwise union computation <br>
      Return all possible values (mask) for an union of given values
    </td>
  </tr>
  <tr>
    <td>
      <code>Class#locales_intersection([value_or_sym, ..])</code>
    </td>
    <td>
      <code>[Fixnum, ..]</code>
    </td>
    <td>
      Given an array of values (Fixnum or Symbol), return bitwise intersection computation <br>
      Return all possible values (mask) for an intersection of given values
    </td>
  </tr>
  <tr>
    <td>
      <code>Class::LOCALES_MAPPING</code>
    </td>
    <td>
      <code>Hash</code>
    </td>
    <td>
      Return <code>Symbol</code> -> <code>Fixnum</code> mapping
    </td>
  </tr>


</table>


### Low level methods

*Theses methods are static, so a <code>name</code> parameters is mandatory in order to fetch mapping*


<table>
  <tr>
    <th>Method</th>
    <th>Return</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>
      <code>Class.to_bitwise_values(object, name)</code>
    </td>
    <td>
      <code>[Fixnum, ...]</code>
    </td>
    <td>
      Given an Object and a attribute name, return Fixnum value depending on mapping
    </td>
  </tr>
  <tr>
    <td>
      <code>Class.bitwise_union([Fixnum, ..], name)</code>
    </td>
    <td>
      <code>[Fixnum, ..]</code>
    </td>
    <td>
      Given an array of values (Fixnum or Symbol) and a attribute name, return bitwise union computation <br>
      Return all possible values (mask) for an union of given values
    </td>
  </tr>
  <tr>
    <td>
      <code>Class.bitwise_intersection([Fixnum, ..], name)</code>
    </td>
    <td>
      <code>[Fixnum, ..]</code>
    </td>
    <td>
      Given an array of values (Fixnum or Symbol) and a attribute name, return bitwise intersection computation <br>
      Return all possible values (mask) for an intersection of given values
    </td>
  </tr>

</table>


----------------------------------------
Maintainers :  [@wittydeveloper](https://github.com/wittydeveloper) and [@FSevaistre](https://github.com/FSevaistre)
