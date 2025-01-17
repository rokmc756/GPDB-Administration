--
select oid, datname from pg_database;

--
select relfilenode, relname from pg_class where relname='test';

--
-- SELECT content, preferred_role = 'p' as definedprimary, dbid, role = 'p' as isprimary, hostname, address, port, datadir
SELECT content, preferred_role = 'p' as definedprimary, dbid, role = 'p' as isprimary, hostname, address, port
                       FROM gp_segment_configuration
                       WHERE (role = 'p' or content < 0 );

-- for GPDB 6.x
-- select * from gp_toolkit.__gp_param_setting_on_segments('data_directory');

-- for GPDB 6.x
select proname from pg_proc where proname like '%dir%';

-- for GPDB 6.x
select proname from pg_proc where proname like '%segment%';

-- for GPDB 6.x
-- select pg_relation_filepath('public.test_table57');

-- for GPDB 6.x
-- select pg_relation_filepath('public.test_table57') from gp_dist_random('gp_id');

\df gp_toolkit.__gp_param_setting_on_segments;

--
-- SELECT pg_relation_filepath('test_table1');


-- if we want to know which segments have this table
--    we can use this command:
--    # found which segment have the table.

-- Go to master only gpdb with utility mode.
-- PGOPTIONS='-c gp_session_role=utility' psql -d postgres
-- Getting schema name of table from OIDs.
-- [gpadmin@rh7-master 331147]$ cat gpcheckcat_summary.log | grep "Relation oid" | sed -e 's/Relation oid//g' | tr -d "[:blank:]" | cut -d : -f 2 | sort | uniq | sed -e 's/$/,/g' >> find_table_location.sql

select gp_segment_id, count(*) from gp_dist_random('public.test_table57') group by gp_segment_id;

select b.nspname || '.' || a.relname from pg_class a, pg_namespace b where a.relnamespace = b.oid and a.oid in(
24191,
24192,
24193,
24194,
24195,
24196,
24197,
24198,
24199,
24200,
24201,
24202,
24203,
24204,
24205,
24206,
24207,
24208,
24209,
24210,
24211,
24212,
24213,
24214,
24215,
24216,
24217,
24218,
24219,
24220,
24221,
24222,
24223,
24224,
24225,
24226,
24227,
24228,
24229,
24230,
24231,
24232,
24233,
24234,
24235,
24236,
24237,
24238,
24239,
24240,
24241,
24242,
24243,
24244,
24245,
24246,
24247,
24248,
24249,
24250,
25567,
25568,
25569,
25570,
25571,
25572,
25573,
25574,
25575,
25576,
25577,
25578,
25579,
25580,
25581,
25582,
25583,
25584,
25585,
25586,
25587,
25588,
25589,
25590,
25591,
25592,
25593,
25594,
25595,
25596,
25597,
25598,
25599,
25600,
25601,
25602,
25603,
25604,
25605,
25606,
25607,
25608,
25609,
25610,
25611,
25612,
25613,
25614,
25615,
25616,
25617,
25618,
25619,
25620,
25621,
25622,
25623,
25624,
25625,
25626)
;

