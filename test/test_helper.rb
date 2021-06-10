require 'simplecov'
SimpleCov.start 'test_frameworks'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'deep_pluck'

require 'minitest/autorun'

ActiveRecord::Base.establish_connection(
  'adapter'  => 'sqlite3',
  'database' => ':memory:',
)
require 'lib/seeds'

def assert_queries(expected_count, event_key = 'sql.active_record')
  sqls = []
  subscriber = ActiveSupport::Notifications.subscribe(event_key) do |_, _, _, _, payload|
    next if payload[:sql].start_with?('PRAGMA table_info')
    next if payload[:sql] =~ /\A(?:BEGIN TRANSACTION|COMMIT TRANSACTION|BEGIN|COMMIT)\z/i

    sqls << "  ● #{payload[:sql]}"
  end
  yield
  if expected_count != sqls.size # show all sql queries if query count doesn't equal to expected count.
    assert_equal "expect #{expected_count} queries, but have #{sqls.size}", "\n#{sqls.join("\n").tr('"', "'")}\n"
  end
  assert_equal expected_count, sqls.size
ensure
  ActiveSupport::Notifications.unsubscribe(subscriber)
end
