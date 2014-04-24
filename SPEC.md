```ruby
if Flag(:experiment).on?
end

Flag(:experiment).on!
Flag(:experiment).off!

Flag(:experiment).on!("30%")
Flag(:experiment).on!(user.id)
Flag(:experiment).on!(:group)

Flag(:experiment).on?(user.id)
Flag(:experiment).on?(:group)

Flag.group[:group] = lambda { |id| id % 2 == 0 }
```
