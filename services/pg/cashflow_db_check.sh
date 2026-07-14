if psql -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $APP_DB_NAME; then
  echo "app database $APP_DB_NAME exists"
else
  echo "create database $APP_DB_NAME"
  psql -U $DB_USER -d "postgres" -c "CREATE DATABASE $APP_DB_NAME"
  psql -U $DB_USER -d $APP_DB_NAME -c "GRANT ALL PRIVILEGES ON DATABASE $APP_DB_NAME to $DB_USER"
fi

## CREATE SCHEMA IF NOT EXISTS goose
psql -U $DB_USER -d $APP_DB_NAME -c "CREATE SCHEMA IF NOT EXISTS goose"
