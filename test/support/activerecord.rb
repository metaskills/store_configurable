module StoreConfigurable
  module ActiveRecordTestHelper

    protected

    class SQLCounter

      class << self
        attr_accessor :ignored_sql, :log
      end

      self.log = []
      self.ignored_sql = [/^PRAGMA (?!(table_info))/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/, /^BEGIN/i, /^COMMIT/i]

      attr_reader :ignore

      def initialize(ignore = Regexp.union(self.class.ignored_sql))
        @ignore = ignore
      end

      def call(name, start, finish, message_id, values)
        sql = values[:sql]
        return if 'CACHE' == values[:name] || ignore =~ sql
        self.class.log << sql
      end

    end

    def assert_sql(*patterns_to_match)
      SQLCounter.log = []
      yield
      SQLCounter.log
    ensure
      failed_patterns = []
      patterns_to_match.each do |pattern|
        failed_patterns << pattern unless SQLCounter.log.any?{ |sql| pattern === sql }
      end
      assert failed_patterns.empty?, "Query pattern(s) #{failed_patterns.map{ |p| p.inspect }.join(', ')} not found.#{SQLCounter.log.size == 0 ? '' : "\nQueries:\n#{SQLCounter.log.join("\n")}"}"
    end

    def assert_queries(num = 1)
      SQLCounter.log = []
      yield
    ensure
      assert_equal num, SQLCounter.log.size, "#{SQLCounter.log.size} instead of #{num} queries were executed.#{SQLCounter.log.size == 0 ? '' : "\nQueries:\n#{SQLCounter.log.join("\n")}"}"
    end

    ActiveSupport::Notifications.subscribe 'sql.active_record', SQLCounter.new

  end
end
