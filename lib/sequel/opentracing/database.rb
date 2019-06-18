# frozen_string_literal: true

module Sequel
  module OpenTracing
    module Database
      module Tracer
        # Instance methods for instrumenting Sequel::Database
        module InstanceMethods
          def run(sql, options = ::Sequel::OPTS)
            opts = parse_opts(sql, options)

            response = nil

            ::OpenTracing.start_active_span(opts[:query], tags: {}) do |scope|
              span = scope.span
              span.set_tag('type', 'sql')
              response = super(sql, options)
            end
            response
          end

          private

          def parse_opts(sql, _opts)
            db_opts = @opts
            if instance_variable_defined?(:@pool) && @pool
              db_opts = @pool.db.opts
            end

            unless sql.is_a?(String)
              sql = sql.prepared_sql unless sql.is_a? Symbol
            end

            { name: db_opts[:type], query: sql, database: db_opts[:database],
              host: db_opts[:host] }
          end
        end
      end
    end
  end
end
