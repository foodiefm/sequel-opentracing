require 'spec_helper'

RSpec.describe Sequel::OpenTracing::Database do
  let(:tracer) { OpenTracingTestTracer.build }
  let(:db) { test_db }

  before do
    db.run('CREATE TABLE IF NOT EXISTS items(id integer PRIMARY KEY, name TEXT NOT NULL)')
    ::OpenTracing.global_tracer = tracer
    Sequel::Database.send(:prepend, described_class::Tracer::InstanceMethods)
  end


  context '.run' do
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
end
