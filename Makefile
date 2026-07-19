SHELL = /bin/sh
$(VERBOSE).SILENT:
include .env

# ****************************************************************************
# NGINX
# ****************************************************************************
nginx/container:
	docker compose up --build -d nginx
nginx: nginx/container


# ****************************************************************************
# DATABASE
# ****************************************************************************
# Postgres
pg/clear:
	docker compose stop pg > /dev/null && rm -rf services/pg/data
pg/reset: pg/clear pg
pg/error:
	docker compose logs pg | read LOGS; echo $LOGS;
pg/env:
	touch ./services/pg/env/extended.env
pg/container:
	docker compose up --build -d pg
pg/wait:
	echo 'wait for pg'; sleep 3; while ! docker compose exec pg bash -c 'sh /tmp/cashflow_healthcheck.sh'; do printf '%s' "#";  sleep 1; done; echo -en "\rpg is ready"
pg/check:
	echo 'search db'; sleep 3; while ! docker compose exec pg bash -c 'sh /tmp/cashflow_db_check.sh'; do printf '%s' "#";  sleep 1; done; echo -en "\rpg"
# Pg run
pg: pg/container pg/check pg/wait


# ****************************************************************************
# APPLICATIONS
# ****************************************************************************
cashflow_app/source:
	./source.sh cashflow_app master cashflow_app
cashflow_app/env:
	touch ./services/cashflow_app/env/extended.env
cashflow_app/config:
	touch ./services/cashflow_app/config/extended.env
	(./config.sh cashflow_app)
cashflow_app: cashflow_app/source cashflow_app/config


# ****************************************************************************
# LAUNCHING APPS
# ****************************************************************************
# Build
extend_required: pg/env
extend_apps: cashflow_app/env
extend_services:

# Init
init/env:
	cp -n .env.example .env
user:
	./user.sh
init_required: init/env user pg
init_apps: cashflow_app

# Build sequence
extend: extend_required extend_services extend_apps
init: extend init_required init_apps
#  nginx


# ****************************************************************************
# DOCKER CONTAINER
# ****************************************************************************
# Container
up:
	docker compose up -d
down:
	docker compose down
kill:
	docker compose kill
stop:
	docker compose stop

# Start
stop/all:
	 docker stop $$(docker ps -a -q)
rm/all:
	docker rm $$(docker ps -a -q) | echo "no containers"
