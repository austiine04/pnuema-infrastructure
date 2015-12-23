#!/bin/bash

set -xe

#specify the locale
export LC_ALL=C

#skip interactive dialogues when installing packages
export DEBIAN_FRONTEND=noninteractive

minimal_apt_get_install='apt-get install -y --no-install-recommends'

#exclude the man pages to reduce the image foot print
echo "path-exclude /usr/share/doc/*" > /etc/dpkg/dpkg.cfg.d/01_nodoc
echo "path-include /usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/01_nodoc
echo "path-exclude /usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc
echo "path-exclude /usr/share/groff/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc
echo "path-exclude /usr/share/info/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc

apt-get update

$minimal_apt_get_install postgresql-9.3 postgresql-contrib-9.3

# trust local connections to postgres
cp /etc/postgresql/9.3/main/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf.bak
sed 's/peer/trust/' /etc/postgresql/9.3/main/pg_hba.conf.bak > /etc/postgresql/9.3/main/pg_hba.conf
rm /etc/postgresql/9.3/main/pg_hba.conf.bak

service postgresql start

#create pneuma user
psql -U postgres --command "CREATE USER pneuma WITH PASSWORD 'password';"

query_statement="select count(1) from pg_catalog.pg_database where datname = 'pneuma'"
create_db_statement="CREATE DATABASE pneuma WITH OWNER pneuma"
cmd="psql -U postgres -t -c \"$query_statement\""
db_exists=`eval $cmd`

if [ $db_exists -eq 0 ] ; then
    echo "creating the database"
    cmd="psql -U postgres -t -c \"$create_db_statement\""
    eval $cmd
fi

service postgresql stop
