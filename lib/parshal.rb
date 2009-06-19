# = Parshal
# A lightweight wrapper for Mashal. 
#
# == Copyright
# :Copyright
#  Copyright (c) 2009 Yugui (Yuki Sonoda).
# :License
#  MIT license

require 'active_support'

module Parshal
  Dump = Struct.new(:serialized)

  module ClassMethods
    def parshal(*names)
      self.parshalled_attributes ||= []
      self.parshalled_attributes += names
    end

    def parshal_load(attributes)
      obj = self.allocate
      obj.__send__(:parshal_initialize)
      attributes.each do |name, value|
        if value.kind_of?(Dump)
          obj.__send__("#{name}=", Parshal.load(value.serialized))
        else
          obj.__send__("#{name}=", value)
        end
      end
      return obj
    end
  end

  module OverrideMethodsForActiveRecord
    def parshal_initialize
      initialize
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.class_inheritable_array(:parshalled_attributes)

    if defined?(ActiveRecord::Base)
      if klass < ActiveRecord::Base
        klass.__send__(:include, OverrideMethodsForActiveRecord)
      end
    end
  end

  def parshal_initialize; end

  def parshal_dump
    attributes = {}
    self.class.parshalled_attributes.each do |name|
      value = self.__send__(name)
      if value.kind_of?(Parshal)
        attributes[name] = Dump.new(Parshal.dump(value))
      else
        attributes[name] = value
      end
    end
    return attributes
  end

  def self.load(dump)
    klass, attributes = Marshal.load(dump)
    klass.parshal_load(attributes)
  end
  def self.dump(obj)
    Marshal.dump([obj.class, obj.parshal_dump])
  end
end
