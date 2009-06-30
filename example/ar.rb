require 'rubygems'
gem 'activerecord'
require 'active_record'
require 'sqlite3'
require 'pp'
require 'parshal'

ActiveRecord::Base.establish_connection \
  :adapter => 'sqlite3',
  :database => 'example-ar.sqlite3'

ActiveRecord::Schema.define do
  create_table :feeds, :force => true do |t|
    t.string :subject, :null => false
  end
  create_table :subscribers, :force => true do |t|
    t.string :name, :null => false
  end
  create_table :subscriptions, :force => true do |t|
    t.belongs_to :feed
    t.belongs_to :subscriber
  end
end

class Feed < ActiveRecord::Base
  include Parshallable
  has_many :subscriptions
  has_many :subscribers, :through => :subscriptions

  parshal :id
end

class Subscriber < ActiveRecord::Base
  include Parshallable
  has_many :subscriptions
  has_many :feeds, :through => :subscriptions

  parshal :id, :name
  def feeds=(feeds)
    feeds.each do |f|
      s = self.subscriptions.find_or_new :feed => f
    end
  end
end

class Subscription < ActiveRecord::Base
  belongs_to :feed
  belongs_to :subscriber
end

feeds = %w[ foo bar baz qux ].map{|subject| Feed.create! :subject => subject }
subscribers = %w[ a b c d ].map{|name| Subscriber.create! :name => name }


subscribers.each_with_index do |s,i|
  ((0...4).to_a - [i]).each do |j|
    s.subscriptions.create! :feed => feeds[j]
  end
end

subscribers = Marshal.load(Marshal.dump(subscribers))
subscribers.each do |s| s.save! end
pp subscribers
pp subscribers.map(&:feeds)
