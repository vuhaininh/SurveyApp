Sequel::Model.plugin(:schema)
Sequel::Model.plugin(:timestamps, force: true, update_on_create: true)
Sequel::Model.raise_on_save_failure = false # Throw exceptions on failure

DB = Sequel.connect(
	adapter:    'postgres',
	host:       ENV['DB_HOST'],
	database:   ENV['DB_DATABASE'],
	user:       ENV['DB_USER'],
	password:   ENV['DB_PASSWORD'],
    port: 5432,
    loggers: [logger]
)

DB.extension :pg_inet
DB.extension :connection_validator
DB.pool.connection_validation_timeout = -1
Sequel::Model.db.extension(:pagination)

