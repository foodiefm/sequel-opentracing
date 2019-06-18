# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sequel::OpenTracing::Database do
  let(:tracer) { OpenTracingTestTracer.build }
  let(:db) { test_db }

  before do
    db.run('CREATE TABLE IF NOT EXISTS ' \
           'items(id integer PRIMARY KEY, name TEXT NOT NULL)')
    ::OpenTracing.global_tracer = tracer
    Sequel::Database.send(:prepend, described_class::Tracer::InstanceMethods)
  end

  describe '.run' do
    before do
      db.run('insert into items values(1, \'foo\')')
    end

    it 'records span' do
      expect(tracer.spans.count).to eq(1)
    end

    it 'tags type' do
      span = tracer.spans.last
      expect(span.tags['type']).to eql('sql')
    end
  end

  describe '#parse_opts' do
    let(:prepared_statement) do
      double('PREPARED', prepared_sql: 'select now()')
    end
    let(:statement) { 'select now()' }
    let(:symbol_s) { :foo }

    it 'adds correct query from prepared statement' do
      res = db.send(:parse_opts, prepared_statement, {})
      expect(res[:query]).to eql('select now()')
    end

    it 'adds correct query from string statement' do
      res = db.send(:parse_opts, statement, {})
      expect(res[:query]).to eql('select now()')
    end

    it 'folds with symbol' do
      res = db.send(:parse_opts, symbol_s, {})
      expect(res[:query]).to be(:foo)
    end
  end
end
