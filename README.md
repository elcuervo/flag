# Flag

## Install

```
gem install flag
```

## Initialize

`Flag` uses `Redic.new` if no other conenction is supplied

```ruby
Flag.store = Redic.new(ENV["OTHER_REDIS"]) # <3 Redic
```

## Basic usage

```ruby
if Flag(:new_design).on?
  # Shiny new design
else
  # Marquee and blink everywhere
end
```

## Enable/Check feature flags

```ruby
Flag(:new_buttons).on! # Enabled for everyone

Flag(:new_buttons).on!(1) # Enabled for id 1
Flag(:new_buttons).on?(1) #=> true

Flag(:new_buttons).on!("AnyRandomIdentification") # Use what you want as an id
Flag(:new_buttons).on?("AnyRandomIdentification") #=> true
```
