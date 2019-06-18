# frozen_string_literal: true

require 'sequel/opentracing/version'
require 'opentracing'
require 'sequel'
require 'sequel/opentracing/database'
require 'sequel/opentracing/dataset'

module Sequel
  # Opentracing instrumentation for SEquel
  module OpenTracing
    ##
    def self.instrument
      warn 'Sequel < 4.37.0 not supported' if ::Sequel::VERSION < '4.37.0'
      ::Sequel::Database.send(:prepend, Database::Tracer::InstanceMethods)
      ::Sequel::Dataset.send(:prepend, Dataset::Tracer::InstanceMethods)
      self
    end
  end
end
