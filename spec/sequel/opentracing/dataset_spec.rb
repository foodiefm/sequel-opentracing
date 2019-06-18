# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sequel::OpenTracing::Dataset do
  let(:tracer) { OpenTracingTestTracer.build }
  let(:db) { test_db }

  before do
    db.run('CREATE TABLE IF NOT EXISTS ' \
           'items(id integer PRIMARY KEY, name TEXT NOT NULL)')
    _null = db[:items].first
    ::OpenTracing.global_tracer = tracer
    Sequel::Dataset.send(:prepend, described_class::Tracer::InstanceMethods)
  end

  RSpec.shared_examples 'correct span' do
    it 'records span' do
      expect(spans.count).to eq(1)
    end

    it 'tags type' do
      span = spans.last
      expect(span.tags['type']).to eql('sql')
    end
  end

  describe '.execute_ddl' do
    before do
      db[:items].first
    end

    it_behaves_like 'correct span' do
      let(:spans) { tracer.spans }
    end

    it 'has operation name' do
      span = tracer.spans.last
      expect(span.operation_name).to eql('SELECT * FROM `items` LIMIT 1')
    end
  end

  describe '.execute_insert' do
    before do
      db[:items].insert(id: 2, name: 'bar')
    end

    it_behaves_like 'correct span' do
      let(:spans) { tracer.spans }
    end

    it 'has operation name' do
      span = tracer.spans.last
      expect(span.operation_name).to match(/INSERT INTO `items`/)
    end
  end

  describe '.execute_dui' do
    before do
      db[:items].delete
    end

    it_behaves_like 'correct span' do
      let(:spans) { tracer.spans }
    end

    it 'has operation name' do
      span = tracer.spans.last
      expect(span.operation_name).to match(/DELETE FROM `items`/)
    end
  end

  describe '#parse_opts' do
    let(:prepared_statement) do
      double('PREPARED', prepared_sql: 'select now()')
    end
    let(:statement) { 'select now()' }
    let(:symbol_s) { :foo }

    it 'adds correct query from prepared statement' do
      res = db[:items].send(:parse_opts, prepared_statement, {}, {})
      expect(res[:query]).to eql('select now()')
    end

    it 'adds correct query from string statement' do
      res = db[:items].send(:parse_opts, statement, {}, {})
      expect(res[:query]).to eql('select now()')
    end

    it 'folds with symbol' do
      res = db[:items].send(:parse_opts, symbol_s, {}, {})
      expect(res[:query]).to be(:foo)
    end
  end
end
