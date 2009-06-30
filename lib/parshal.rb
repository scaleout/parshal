# = Parshal
# A lightweight wrapper for Mashal. 
#
# == Copyright
# :Copyright
#  Copyright (c) 2009 Yugui (Yuki Sonoda).
# :License
#  MIT license

require 'active_support'

# a namespace, which provides partial marshaling.
module Parshallable
  VERSION = "0.0.2"

  # holds class methods
  module ClassMethods
    def parshal(*names)
      self.parshalled_attributes ||= []
      self.parshalled_attributes += names
    end
  end

  module OverrideMethodsForActiveRecord
    def parshal_initialize
      initialize
    end
    def marshal_dump_with_new_record
      attrs = marshal_dump_without_new_record
      attrs[:@new_record] = new_record?
      attrs
    end
    def marshal_load_with_new_record(attrs)
      new_record = attrs.delete(:@new_record)
      marshal_load_without_new_record(attrs)
      @new_record = new_record
    end
    def self.included(model)
      model.send(:alias_method_chain, :marshal_load, :new_record)
      model.send(:alias_method_chain, :marshal_dump, :new_record)
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

  def marshal_load(attributes)
    self.__send__(:parshal_initialize)
    attributes.each do |name, value|
      self.__send__("#{name}=", value)
    end
  end

  def marshal_dump
    attributes = {}
    self.class.parshalled_attributes.each do |name|
      value = self.__send__(name)
      attributes[name] = value
    end
    return attributes
  end
end
