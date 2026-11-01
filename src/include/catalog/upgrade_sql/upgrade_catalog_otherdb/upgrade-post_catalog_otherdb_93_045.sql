DROP FUNCTION IF EXISTS pg_catalog.int16um(int16) CASCADE;
set LOCAL inplace_upgrade_next_system_object_oids = IUO_PROC, 6460;
CREATE FUNCTION pg_catalog.int16um(int16) RETURNS int16 LANGUAGE INTERNAL IMMUTABLE STRICT as 'int16um';
COMMENT ON FUNCTION pg_catalog.int16um(int16) IS 'implementation of - operator';
SET LOCAL inplace_upgrade_next_system_object_oids=IUO_GENERAL, 6010;
CREATE OPERATOR pg_catalog.- (
    RIGHTARG = int16,
    PROCEDURE = int16um
);
COMMENT ON OPERATOR pg_catalog.-(none, int16) IS 'negate';
