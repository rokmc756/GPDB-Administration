-- Insert test data
insert into public.test_add_column
select to_char(generate_series('20200101'::date,'20230401'::date,'1 month'),'yyyymmdd'),
a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,
array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],
array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],array[a,a],
array[a,a],array[a,a],array[a,a]
from generate_series(1,10000000,1) a;
