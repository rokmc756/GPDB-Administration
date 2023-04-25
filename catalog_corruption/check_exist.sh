

LOST_TABLES="
pg_toast.pg_toast_25567
pg_toast.pg_toast_25567_index
public.test_table51
pg_toast.pg_toast_25573
pg_toast.pg_toast_25573_index
public.test_table52
pg_toast.pg_toast_25579
pg_toast.pg_toast_25579_index
public.test_table53
pg_toast.pg_toast_25585
pg_toast.pg_toast_25585_index
public.test_table54
pg_toast.pg_toast_25591
pg_toast.pg_toast_25591_index
public.test_table55
pg_toast.pg_toast_25597
pg_toast.pg_toast_25597_index
public.test_table56
pg_toast.pg_toast_25603
pg_toast.pg_toast_25603_index
public.test_table57
pg_toast.pg_toast_25609
pg_toast.pg_toast_25609_index
public.test_table58
pg_toast.pg_toast_25615
pg_toast.pg_toast_25615_index
public.test_table59
pg_toast.pg_toast_25621
pg_toast.pg_toast_25621_index
public.test_table60
"

for i in `echo $LOST_TABLES`
do
    echo $i
    psql -d testdb -c "select gp_segment_id, count(*) from gp_dist_random('$i') group by gp_segment_id;"
done
