CREATE OR REPLACE FUNCTION service_management.update_view_privacy(p_view_row_wid int8, p_refresh_view bool, p_processed int8)
    RETURNS int4
    LANGUAGE plpgsql
    SECURITY DEFINER
    VOLATILE
AS $$
    


/*
 * This function is used to activate and/or deactivate pii for columns defined by governance/business team in the pii table.
 * During activation, the columns added to the app_table_to_view_free_format with appropriate sql logic so that only users with pii role can view
 * the info and during deactivation the columns are removed from app_table_to_view_free_format and added back to field selection column
 * in app_table_to_view.
 *
 * param p_refresh_view - force a refresh or update the metadata but dont force a refresh.
 * param p_processed - max number of objects to process before exiting.
 *
 * return: int - -1 on failure.
 *              -  number of tables processed on success.
 */

declare v_substitute_rec record;--to capture records for the loop
declare v_row_wid bigint:=0;--to capture row id of attv
declare v_orig_view_row_wid bigint:=0;
declare v_field_selection character varying[];--to capture field_selection columns for pii activation
declare v_orig_field_selection character varying[]:='{}';
declare v_orig_free_format_row_wid bigint:=0;--to capture the current free format row_wid we are processing
declare v_field_selection_data_type text[];--to capture field_selection datatype for pii activation
declare v_success bigint;--to capture return code on success
declare v_col_data_type text;--to capture column data type
declare v_object_processed smallint:=0;--to capture the table processed
declare v_current_schema text:='first';--initialize with junk, capture current schema to process
declare v_free_format_string text:='first';--initialize with junk,capture free format
declare v_current_table text:='first';--initialize with junk,capture current table to process
declare v_current_attv_row_wid bigint:=0;--to capture the app_table_to_view free format row_wid we are processing
declare v_col_type_force_to_null boolean;--to capture pii masking type, null or sha256 when not null
declare v_levels_set text[] := array['Identify pii add/remove', '1-new attv', '2-new view',
'3-new base table', '4-set variable for current round', '5-Calc values for current rec', '6-Apply commit'];
declare v_level character varying;--to capture executing block
begin

raise notice  'processing view_row_wid %', coalesce(p_view_row_wid::text, 'all');

--Check if temp table to capture actions already exists

--Insert PII add actions

--Insert PII remove actions

--Insert PII add actions if new tags identified and remove for the exisiting one

    -- scan all views and tables where we have amendment to apply
    -- only if field selectionb is * or for field selection includes the sensitive data
v_level := 'Identify pii add/remove';
for v_substitute_rec in
	(SELECT task, row_wid, view_row_wid, field_selection, source_schema, table_name, column_name, masking_tag, attvff_row_wid, free_format
		FROM pii_implementation_action
		order by source_schema, table_name, view_row_wid, row_wid, task desc
	)
	loop

		raise notice 'starting on view_row_wid : %, column name: %, task: %', v_substitute_rec.view_row_wid , v_substitute_rec.column_name, v_substitute_rec.task;
		--if we have any entry active or inactive in the pii type 2, with null attribute

		--==1 commit the change working on previous attv record
		--==2 commit the change working on previous view
		--==3 apply for any new table done processing
		--==4 set vriable for current round
		--==5 calculate values for current record

		--==6 on exit check if there is anything to commit

		-- 1 if we are processing a new attv row_wid update the previous one

		v_level := '1-new attv';
		raise notice  '--==1 new attv';
		--if v_current_attv_row_wid <> 0 and v_current_attv_row_wid <> v_substitute_rec.row_wid then
		raise notice  'updated field selection  % for OID:%', array_to_string(v_field_selection, '-'), v_current_attv_row_wid;

		select service_management.update_app_table_to_view('F',
			v_current_attv_row_wid,null,null,
			v_field_selection,'y',user) into v_success;

	-- key query
            select pg_catalog.format_type(pa.atttypid, pa.atttypmod) data_type, case when sms.config_value is null then true else false end
                into v_col_data_type, v_col_type_force_to_null
            from pg_attribute pa,
                pg_class pc,
                pg_namespace pn,
                    pg_type pt
            left outer join service_management.service_management_config sms
                    on sms.config_item in ('PII_mask_allowed_data_types')
                    and pt.typname=any(string_to_array(sms.config_value,','))
            where pn.nspname =v_substitute_rec.source_schema
            and pc.relname =v_substitute_rec.table_name
            and pa.attname = v_substitute_rec.column_name
            and pc.relnamespace =pn.oid
            and pa.attrelid=pc.oid
            and not pa.attisdropped
            and pt.oid = pa.atttypid
            and attnum >=1;


		v_object_processed:=v_object_processed+1;

		--raise notice  'updated field_selection for entry row_wid % to %', v_current_attv_row_wid,v_field_selection;

	end loop;
    
	--raise notice  'start to sleep';
	--select pg_sleep(60);

    v_level := '6-Apply commit';
    raise notice  '6-Apply commit';
    --==6 on exit check if there is anything to commit
    -- if we exited the loop because we processed all the records returned by the query,
    -- then we need to apply the changes not commited yet

return v_object_processed;

--Exception handling
exception when OTHERS then
         if(v_level = any(v_levels_set))
            then v_success = service_management.tab_log_error(sqlstate||' '||sqlerrm, 'service_management.update_view_privacy('''||p_view_row_wid||''', '''||p_refresh_view||''','''||p_processed||''') - '||v_level);
        else
           v_success=service_management.tab_log_error(sqlstate||' ' ||sqlerrm, 'service_management.update_view_privacy');
        end if;
return -1;
end;


$$
EXECUTE ON ANY;
