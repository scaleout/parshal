require 'rubygems'
gem 'activesupport'
require 'parshal'
class A
  include Parshallable
  attr_accessor :x, :y, :z, :b
  attr_accessor :p, :q

  parshal :x, :y, :z, :b   # ignores :p and :q
end

class B
  include Parshallable
  attr_accessor :m, :n

  parshal :m, :n
end

a = A.new
a.x = :x
a.y = 1
a.z = {:hoge => :hage}
a.p = :unused
a.q = :unused

b = B.new
b.m = 'm'
b.n = [b, b.clone, b.clone]
a.b = b

a = Marshal.load(Marshal.dump(a))
p a
