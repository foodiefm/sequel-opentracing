# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Sequel::OpenTracing do
  let(:tracer) { OpenTracingTestTracer.build }
  let(:db) { test_db }

  it 'has a version number' do
    expect(Sequel::OpenTracing::VERSION).not_to be nil
  end

  before do
    db.run('CREATE TABLE IF NOT EXISTS items(id integer PRIMARY KEY, name TEXT NOT NULL)')
    _null = db[:items].first
    ::OpenTracing.global_tracer = tracer
    described_class.instrument
  end

  it 'applies instrumentation to Sequel::Database' do
    db.run('SELECT * from items')
    expect(tracer.spans.count).to eq(1)
  end

  it 'applies instrumentation to Sequel::Dataset' do
    db[:items].first
    expect(tracer.spans.count).to eq(1)
  end

end
