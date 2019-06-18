# frozen_string_literal: true

require 'sequel/opentracing/version'
require 'opentracing'
require 'sequel'
require 'sequel/opentracing/database'
require 'sequel/opentracing/dataset'

module Sequel
  module Opentracing
    ## Apply intrumentation
    def self.instrument
      ::Sequel::Database.send(:prepend, Database::Tracer::InstanceMethods)
      ::Sequel::Dataset.send(:prepend, Database::Tracer::InstanceMethods)
      self
    end
  end
end
