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

            ::OpenTracing.global_tracer.start_active_span(opts[:query], tags: {}) do |scope|
              span = scope.span
              span.set_tag('type', 'sql')
              response = super(sql, options)
            end
            response
          end

          private

          def parse_opts(sql, _opts)
            db_opts = if ::Sequel::VERSION < '3.41.0' && self.class.to_s !~ /Dataset$/
                        @opts
                      elsif instance_variable_defined?(:@pool) && @pool
                        @pool.db.opts
                      end
            if ::Sequel::VERSION >= '4.37.0' && !sql.is_a?(String)
              # In 4.37.0, sql was converted to a prepared statement object
              sql = sql.prepared_sql unless sql.is_a?(Symbol)
            end

            {
              name: db_opts[:type],
              query: sql,
              database: db_opts[:database],
              host: db_opts[:host]
            }
          end
        end
      end
    end
  end
end
