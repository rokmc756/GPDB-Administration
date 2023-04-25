#!/bin/bash
#

DATABASE_NAME="testdb"

# dropdb $DATABASE_NAME;
# createdb $DATABASE_NAME;

# Create table
for i in `seq 1 100`
do
    psql -d testdb -c "DROP TABLE IF EXISTS test_table$i;"
    psql -d testdb -c "CREATE TABLE test_table$i (a int, b int, c varchar) DISTRIBUTED BY (a);"
done

# Drop tables only on master.
for i in `seq 11 20`
do
    PGOPTIONS='-c gp_session_role=utility' psql -d testdb -c "DROP TABLE IF EXISTS test_table$i;"
done

# Drop tables only on specific segment host
for i in `seq 51 60`
do
    PGOPTIONS='-c gp_session_role=utility' psql -h rh7-node03 -p 6000 -d testdb -c "DROP TABLE IF EXISTS test_table$i;"
done

export PGDATABASE=$DATABASE_NAME
# nohup $GPHOME/bin/lib/gpcheckcat -O $DATABASE_NAME > /home/gpadmin/gpcheckcat_$(date +%Y%m%d%S)_summary.log 2>&1 &
nohup $GPHOME/bin/lib/gpcheckcat -O $DATABASE_NAME > ./gpcheckcat_summary.log 2>&1 &
