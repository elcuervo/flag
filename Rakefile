require "rake/testtask"

Rake::TestTask.new("spec") do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

task :default => [:test]
task :all     => [:test, :bench]
task :test    => [:spec]
