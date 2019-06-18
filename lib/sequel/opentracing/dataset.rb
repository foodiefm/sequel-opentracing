# frozen_string_literal: true

module Sequel
  module OpenTracing
    module Dataset
      module Tracer
        # Instance methods for instrumenting Sequel::Dataset
        module InstanceMethods
          def execute(sql, options = ::Sequel::OPTS, &block)
            otrace(proc { super }, sql, options, &block)
          end

          def execute_ddl(sql, options = ::Sequel::OPTS, &block)
            otrace(proc { super }, sql, options, &block)
          end

          def execute_dui(sql, options = ::Sequel::OPTS, &block)
            otrace(proc { super }, sql, options, &block)
          end

          def execute_insert(sql, options = ::Sequel::OPTS, &block)
            otrace(proc { super }, sql, options, &block)
          end

          private

          def otrace(super_method, sql, options, &block)
            opts = parse_opts(sql, options, db.opts)
            response = nil

            ::OpenTracing.start_active_span(opts[:query], tags: {}) do |scope|
              span = scope.span
              span.set_tag('type', 'sql')
              response = super_method.call(sql, options, &block)
            end
            response
          end

          def parse_opts(sql, opts, db_opts)
            unless sql.is_a?(String)
              sql = sql.prepared_sql unless sql.is_a?(Symbol)
            end
            {
              name: opts[:type],
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
