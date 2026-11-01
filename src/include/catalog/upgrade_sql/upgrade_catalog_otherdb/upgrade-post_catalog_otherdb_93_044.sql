CREATE OR REPLACE FUNCTION dbe_perf.get_global_stat_xact_all_tables
  (OUT node_name name, OUT relid oid, OUT schemaname name, OUT relname name, OUT seq_scan bigint,
   OUT seq_tup_read bigint, OUT idx_scan bigint, OUT idx_tup_fetch bigint, OUT n_tup_ins bigint,
   OUT n_tup_upd bigint, OUT n_tup_del bigint, OUT n_tup_hot_upd bigint)
RETURNS setof record
AS $$
DECLARE
  row_data dbe_perf.stat_xact_all_tables%rowtype;
  row_name record;
  query_str text;
  query_str_nodes text;
  BEGIN
    --Get all the node names
    query_str_nodes := 'select * from dbe_perf.node_name';
    FOR row_name IN EXECUTE(query_str_nodes) LOOP
        query_str := 'SELECT * FROM dbe_perf.stat_xact_all_tables';
        FOR row_data IN EXECUTE(query_str) LOOP
            node_name := row_name.node_name;
            relid := row_data.relid;
            schemaname := row_data.schemaname;
            relname := row_data.relname;
            seq_scan := row_data.seq_scan;
            seq_tup_read := row_data.seq_tup_read;
            idx_scan := row_data.idx_scan;
            idx_tup_fetch := row_data.idx_tup_fetch;
            n_tup_ins := row_data.n_tup_ins;
            n_tup_upd := row_data.n_tup_upd;
            n_tup_del := row_data.n_tup_del;
            n_tup_hot_upd := row_data.n_tup_hot_upd;
            return next;
        END LOOP;
    END LOOP;
    return;
  END; $$
LANGUAGE 'plpgsql' NOT FENCED;
