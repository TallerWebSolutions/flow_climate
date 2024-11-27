SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA hdb_catalog;


--
-- Name: hdb_views; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA hdb_views;


--
-- Name: heroku_ext; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA heroku_ext;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: check_violation(text); Type: FUNCTION; Schema: hdb_catalog; Owner: -
--

CREATE FUNCTION hdb_catalog.check_violation(msg text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RAISE check_violation USING message=msg;
  END;
$$;


--
-- Name: hdb_schema_update_event_notifier(); Type: FUNCTION; Schema: hdb_catalog; Owner: -
--

CREATE FUNCTION hdb_catalog.hdb_schema_update_event_notifier() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    instance_id uuid;
    occurred_at timestamptz;
    invalidations json;
    curr_rec record;
  BEGIN
    instance_id = NEW.instance_id;
    occurred_at = NEW.occurred_at;
    invalidations = NEW.invalidations;
    PERFORM pg_notify('hasura_schema_update', json_build_object(
      'instance_id', instance_id,
      'occurred_at', occurred_at,
      'invalidations', invalidations
      )::text);
    RETURN curr_rec;
  END;
$$;


--
-- Name: inject_table_defaults(text, text, text, text); Type: FUNCTION; Schema: hdb_catalog; Owner: -
--

CREATE FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        r RECORD;
    BEGIN
      FOR r IN SELECT column_name, column_default FROM information_schema.columns WHERE table_schema = tab_schema AND table_name = tab_name AND column_default IS NOT NULL LOOP
          EXECUTE format('ALTER VIEW %I.%I ALTER COLUMN %I SET DEFAULT %s;', view_schema, view_name, r.column_name, r.column_default);
      END LOOP;
    END;
$$;


--
-- Name: insert_event_log(text, text, text, text, json); Type: FUNCTION; Schema: hdb_catalog; Owner: -
--

CREATE FUNCTION hdb_catalog.insert_event_log(schema_name text, table_name text, trigger_name text, op text, row_data json) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    id text;
    payload json;
    session_variables json;
    server_version_num int;
  BEGIN
    id := gen_random_uuid();
    server_version_num := current_setting('server_version_num');
    IF server_version_num >= 90600 THEN
      session_variables := current_setting('hasura.user', 't');
    ELSE
      BEGIN
        session_variables := current_setting('hasura.user');
      EXCEPTION WHEN OTHERS THEN
                  session_variables := NULL;
      END;
    END IF;
    payload := json_build_object(
      'op', op,
      'data', row_data,
      'session_variables', session_variables
    );
    INSERT INTO hdb_catalog.event_log
                (id, schema_name, table_name, trigger_name, payload)
    VALUES
    (id, schema_name, table_name, trigger_name, payload);
    RETURN id;
  END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.event_invocation_logs (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: event_log; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.event_log (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    trigger_name text NOT NULL,
    payload jsonb NOT NULL,
    delivered boolean DEFAULT false NOT NULL,
    error boolean DEFAULT false NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    locked boolean DEFAULT false NOT NULL,
    next_retry_at timestamp without time zone,
    archived boolean DEFAULT false NOT NULL
);


--
-- Name: event_triggers; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.event_triggers (
    name text NOT NULL,
    type text NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    configuration json,
    comment text
);


--
-- Name: hdb_action; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_action (
    action_name text NOT NULL,
    action_defn jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false
);


--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


--
-- Name: hdb_action_permission; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_action_permission (
    action_name text NOT NULL,
    role_name text NOT NULL,
    definition jsonb DEFAULT '{}'::jsonb NOT NULL,
    comment text
);


--
-- Name: hdb_allowlist; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_allowlist (
    collection_name text
);


--
-- Name: hdb_check_constraint; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_check_constraint AS
 SELECT (n.nspname)::text AS table_schema,
    (ct.relname)::text AS table_name,
    (r.conname)::text AS constraint_name,
    pg_get_constraintdef(r.oid, true) AS "check"
   FROM ((pg_constraint r
     JOIN pg_class ct ON ((r.conrelid = ct.oid)))
     JOIN pg_namespace n ON ((ct.relnamespace = n.oid)))
  WHERE (r.contype = 'c'::"char");


--
-- Name: hdb_computed_field; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_computed_field (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    computed_field_name text NOT NULL,
    definition jsonb NOT NULL,
    comment text
);


--
-- Name: hdb_computed_field_function; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_computed_field_function AS
 SELECT hdb_computed_field.table_schema,
    hdb_computed_field.table_name,
    hdb_computed_field.computed_field_name,
        CASE
            WHEN (((hdb_computed_field.definition -> 'function'::text) ->> 'name'::text) IS NULL) THEN (hdb_computed_field.definition ->> 'function'::text)
            ELSE ((hdb_computed_field.definition -> 'function'::text) ->> 'name'::text)
        END AS function_name,
        CASE
            WHEN (((hdb_computed_field.definition -> 'function'::text) ->> 'schema'::text) IS NULL) THEN 'public'::text
            ELSE ((hdb_computed_field.definition -> 'function'::text) ->> 'schema'::text)
        END AS function_schema
   FROM hdb_catalog.hdb_computed_field;


--
-- Name: hdb_custom_types; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_custom_types (
    custom_types jsonb NOT NULL
);


--
-- Name: hdb_foreign_key_constraint; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_foreign_key_constraint AS
 SELECT (q.table_schema)::text AS table_schema,
    (q.table_name)::text AS table_name,
    (q.constraint_name)::text AS constraint_name,
    (min(q.constraint_oid))::integer AS constraint_oid,
    min((q.ref_table_table_schema)::text) AS ref_table_table_schema,
    min((q.ref_table)::text) AS ref_table,
    json_object_agg(ac.attname, afc.attname) AS column_mapping,
    min((q.confupdtype)::text) AS on_update,
    min((q.confdeltype)::text) AS on_delete,
    json_agg(ac.attname) AS columns,
    json_agg(afc.attname) AS ref_columns
   FROM ((( SELECT ctn.nspname AS table_schema,
            ct.relname AS table_name,
            r.conrelid AS table_id,
            r.conname AS constraint_name,
            r.oid AS constraint_oid,
            cftn.nspname AS ref_table_table_schema,
            cft.relname AS ref_table,
            r.confrelid AS ref_table_id,
            r.confupdtype,
            r.confdeltype,
            unnest(r.conkey) AS column_id,
            unnest(r.confkey) AS ref_column_id
           FROM ((((pg_constraint r
             JOIN pg_class ct ON ((r.conrelid = ct.oid)))
             JOIN pg_namespace ctn ON ((ct.relnamespace = ctn.oid)))
             JOIN pg_class cft ON ((r.confrelid = cft.oid)))
             JOIN pg_namespace cftn ON ((cft.relnamespace = cftn.oid)))
          WHERE (r.contype = 'f'::"char")) q
     JOIN pg_attribute ac ON (((q.column_id = ac.attnum) AND (q.table_id = ac.attrelid))))
     JOIN pg_attribute afc ON (((q.ref_column_id = afc.attnum) AND (q.ref_table_id = afc.attrelid))))
  GROUP BY q.table_schema, q.table_name, q.constraint_name;


--
-- Name: hdb_function; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_function (
    function_schema text NOT NULL,
    function_name text NOT NULL,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_system_defined boolean DEFAULT false
);


--
-- Name: hdb_function_agg; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_function_agg AS
 SELECT (p.proname)::text AS function_name,
    (pn.nspname)::text AS function_schema,
    pd.description,
        CASE
            WHEN (p.provariadic = (0)::oid) THEN false
            ELSE true
        END AS has_variadic,
        CASE
            WHEN ((p.provolatile)::text = ('i'::character(1))::text) THEN 'IMMUTABLE'::text
            WHEN ((p.provolatile)::text = ('s'::character(1))::text) THEN 'STABLE'::text
            WHEN ((p.provolatile)::text = ('v'::character(1))::text) THEN 'VOLATILE'::text
            ELSE NULL::text
        END AS function_type,
    pg_get_functiondef(p.oid) AS function_definition,
    (rtn.nspname)::text AS return_type_schema,
    (rt.typname)::text AS return_type_name,
    (rt.typtype)::text AS return_type_type,
    p.proretset AS returns_set,
    ( SELECT COALESCE(json_agg(json_build_object('schema', q.schema, 'name', q.name, 'type', q.type)), '[]'::json) AS "coalesce"
           FROM ( SELECT pt.typname AS name,
                    pns.nspname AS schema,
                    pt.typtype AS type,
                    pat.ordinality
                   FROM ((unnest(COALESCE(p.proallargtypes, (p.proargtypes)::oid[])) WITH ORDINALITY pat(oid, ordinality)
                     LEFT JOIN pg_type pt ON ((pt.oid = pat.oid)))
                     LEFT JOIN pg_namespace pns ON ((pt.typnamespace = pns.oid)))
                  ORDER BY pat.ordinality) q) AS input_arg_types,
    to_json(COALESCE(p.proargnames, ARRAY[]::text[])) AS input_arg_names,
    p.pronargdefaults AS default_args,
    (p.oid)::integer AS function_oid
   FROM ((((pg_proc p
     JOIN pg_namespace pn ON ((pn.oid = p.pronamespace)))
     JOIN pg_type rt ON ((rt.oid = p.prorettype)))
     JOIN pg_namespace rtn ON ((rtn.oid = rt.typnamespace)))
     LEFT JOIN pg_description pd ON ((p.oid = pd.objoid)))
  WHERE (((pn.nspname)::text !~~ 'pg_%'::text) AND ((pn.nspname)::text <> ALL (ARRAY['information_schema'::text, 'hdb_catalog'::text, 'hdb_views'::text])) AND (NOT (EXISTS ( SELECT 1
           FROM pg_aggregate
          WHERE ((pg_aggregate.aggfnoid)::oid = p.oid)))));


--
-- Name: hdb_function_info_agg; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_function_info_agg AS
 SELECT hdb_function_agg.function_name,
    hdb_function_agg.function_schema,
    row_to_json(( SELECT e.*::record AS e
           FROM ( SELECT hdb_function_agg.description,
                    hdb_function_agg.has_variadic,
                    hdb_function_agg.function_type,
                    hdb_function_agg.return_type_schema,
                    hdb_function_agg.return_type_name,
                    hdb_function_agg.return_type_type,
                    hdb_function_agg.returns_set,
                    hdb_function_agg.input_arg_types,
                    hdb_function_agg.input_arg_names,
                    hdb_function_agg.default_args,
                    (EXISTS ( SELECT 1
                           FROM information_schema.tables
                          WHERE (((tables.table_schema)::text = hdb_function_agg.return_type_schema) AND ((tables.table_name)::text = hdb_function_agg.return_type_name)))) AS returns_table) e)) AS function_info
   FROM hdb_catalog.hdb_function_agg;


--
-- Name: hdb_permission; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_permission (
    table_schema name NOT NULL,
    table_name name NOT NULL,
    role_name text NOT NULL,
    perm_type text NOT NULL,
    perm_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_permission_perm_type_check CHECK ((perm_type = ANY (ARRAY['insert'::text, 'select'::text, 'update'::text, 'delete'::text])))
);


--
-- Name: hdb_permission_agg; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_permission_agg AS
 SELECT hdb_permission.table_schema,
    hdb_permission.table_name,
    hdb_permission.role_name,
    json_object_agg(hdb_permission.perm_type, hdb_permission.perm_def) AS permissions
   FROM hdb_catalog.hdb_permission
  GROUP BY hdb_permission.table_schema, hdb_permission.table_name, hdb_permission.role_name;


--
-- Name: hdb_primary_key; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_primary_key AS
 SELECT tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    json_agg(constraint_column_usage.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN ( SELECT x.tblschema AS table_schema,
            x.tblname AS table_name,
            x.colname AS column_name,
            x.cstrname AS constraint_name
           FROM ( SELECT DISTINCT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_depend d,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (d.refclassid = ('pg_class'::regclass)::oid) AND (d.refobjid = r.oid) AND (d.refobjsubid = a.attnum) AND (d.classid = ('pg_constraint'::regclass)::oid) AND (d.objid = c.oid) AND (c.connamespace = nc.oid) AND (c.contype = 'c'::"char") AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND (NOT a.attisdropped))
                UNION ALL
                 SELECT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (nc.oid = c.connamespace) AND (r.oid =
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confrelid
                            ELSE c.conrelid
                        END) AND (a.attnum = ANY (
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confkey
                            ELSE c.conkey
                        END)) AND (NOT a.attisdropped) AND (c.contype = ANY (ARRAY['p'::"char", 'u'::"char", 'f'::"char"])) AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])))) x(tblschema, tblname, colname, cstrname)) constraint_column_usage ON ((((tc.constraint_name)::text = (constraint_column_usage.constraint_name)::text) AND ((tc.table_schema)::text = (constraint_column_usage.table_schema)::text) AND ((tc.table_name)::text = (constraint_column_usage.table_name)::text))))
  WHERE ((tc.constraint_type)::text = 'PRIMARY KEY'::text)
  GROUP BY tc.table_schema, tc.table_name, tc.constraint_name;


--
-- Name: hdb_query_collection; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_query_collection (
    collection_name text NOT NULL,
    collection_defn jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false
);


--
-- Name: hdb_relationship; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_relationship (
    table_schema name NOT NULL,
    table_name name NOT NULL,
    rel_name text NOT NULL,
    rel_type text,
    rel_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_relationship_rel_type_check CHECK ((rel_type = ANY (ARRAY['object'::text, 'array'::text])))
);


--
-- Name: hdb_role; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_role AS
 SELECT DISTINCT q.role_name
   FROM ( SELECT hdb_permission.role_name
           FROM hdb_catalog.hdb_permission
        UNION ALL
         SELECT hdb_action_permission.role_name
           FROM hdb_catalog.hdb_action_permission) q;


--
-- Name: hdb_schema_update_event; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_schema_update_event (
    instance_id uuid NOT NULL,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL,
    invalidations json NOT NULL
);


--
-- Name: hdb_table; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_table (
    table_schema name NOT NULL,
    table_name name NOT NULL,
    configuration jsonb,
    is_system_defined boolean DEFAULT false,
    is_enum boolean DEFAULT false NOT NULL
);


--
-- Name: hdb_table_info_agg; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_table_info_agg AS
 SELECT schema.nspname AS table_schema,
    "table".relname AS table_name,
    jsonb_build_object('oid', ("table".oid)::integer, 'columns', COALESCE(columns.info, '[]'::jsonb), 'primary_key', primary_key.info, 'unique_constraints', COALESCE(unique_constraints.info, '[]'::jsonb), 'foreign_keys', COALESCE(foreign_key_constraints.info, '[]'::jsonb), 'view_info',
        CASE "table".relkind
            WHEN 'v'::"char" THEN jsonb_build_object('is_updatable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 4) = 4), 'is_insertable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 8) = 8), 'is_deletable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 16) = 16))
            ELSE NULL::jsonb
        END, 'description', description.description) AS info
   FROM ((((((pg_class "table"
     JOIN pg_namespace schema ON ((schema.oid = "table".relnamespace)))
     LEFT JOIN pg_description description ON (((description.classoid = ('pg_class'::regclass)::oid) AND (description.objoid = "table".oid) AND (description.objsubid = 0))))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('name', "column".attname, 'position', "column".attnum, 'type', COALESCE(base_type.typname, type.typname), 'is_nullable', (NOT "column".attnotnull), 'description', col_description("table".oid, ("column".attnum)::integer))) AS info
           FROM ((pg_attribute "column"
             LEFT JOIN pg_type type ON ((type.oid = "column".atttypid)))
             LEFT JOIN pg_type base_type ON (((type.typtype = 'd'::"char") AND (base_type.oid = type.typbasetype))))
          WHERE (("column".attrelid = "table".oid) AND ("column".attnum > 0) AND (NOT "column".attisdropped))) columns ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_build_object('constraint', jsonb_build_object('name', class.relname, 'oid', (class.oid)::integer), 'columns', COALESCE(columns_1.info, '[]'::jsonb)) AS info
           FROM ((pg_index index
             JOIN pg_class class ON ((class.oid = index.indexrelid)))
             LEFT JOIN LATERAL ( SELECT jsonb_agg("column".attname) AS info
                   FROM pg_attribute "column"
                  WHERE (("column".attrelid = "table".oid) AND ("column".attnum = ANY ((index.indkey)::smallint[])))) columns_1 ON (true))
          WHERE ((index.indrelid = "table".oid) AND index.indisprimary)) primary_key ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('name', class.relname, 'oid', (class.oid)::integer)) AS info
           FROM (pg_index index
             JOIN pg_class class ON ((class.oid = index.indexrelid)))
          WHERE ((index.indrelid = "table".oid) AND index.indisunique AND (NOT index.indisprimary))) unique_constraints ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('constraint', jsonb_build_object('name', foreign_key.constraint_name, 'oid', foreign_key.constraint_oid), 'columns', foreign_key.columns, 'foreign_table', jsonb_build_object('schema', foreign_key.ref_table_table_schema, 'name', foreign_key.ref_table), 'foreign_columns', foreign_key.ref_columns)) AS info
           FROM hdb_catalog.hdb_foreign_key_constraint foreign_key
          WHERE ((foreign_key.table_schema = (schema.nspname)::text) AND (foreign_key.table_name = ("table".relname)::text))) foreign_key_constraints ON (true))
  WHERE ("table".relkind = ANY (ARRAY['r'::"char", 't'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"]));


--
-- Name: hdb_unique_constraint; Type: VIEW; Schema: hdb_catalog; Owner: -
--

CREATE VIEW hdb_catalog.hdb_unique_constraint AS
 SELECT tc.table_name,
    tc.constraint_schema AS table_schema,
    tc.constraint_name,
    json_agg(kcu.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN information_schema.key_column_usage kcu USING (constraint_schema, constraint_name))
  WHERE ((tc.constraint_type)::text = 'UNIQUE'::text)
  GROUP BY tc.table_name, tc.constraint_schema, tc.constraint_name;


--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: remote_schemas; Type: TABLE; Schema: hdb_catalog; Owner: -
--

CREATE TABLE hdb_catalog.remote_schemas (
    id bigint NOT NULL,
    name text,
    definition json,
    comment text
);


--
-- Name: remote_schemas_id_seq; Type: SEQUENCE; Schema: hdb_catalog; Owner: -
--

CREATE SEQUENCE hdb_catalog.remote_schemas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: remote_schemas_id_seq; Type: SEQUENCE OWNED BY; Schema: hdb_catalog; Owner: -
--

ALTER SEQUENCE hdb_catalog.remote_schemas_id_seq OWNED BY hdb_catalog.remote_schemas.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: class_of_service_change_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.class_of_service_change_histories (
    id bigint NOT NULL,
    demand_id integer NOT NULL,
    change_date timestamp without time zone NOT NULL,
    from_class_of_service integer,
    to_class_of_service integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: class_of_service_change_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.class_of_service_change_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: class_of_service_change_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.class_of_service_change_histories_id_seq OWNED BY public.class_of_service_change_histories.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    abbreviation character varying NOT NULL,
    customers_count integer DEFAULT 0,
    slug character varying,
    api_token character varying NOT NULL,
    company_type integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: company_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.company_settings (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    max_active_parallel_projects integer NOT NULL,
    max_flow_pressure numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: company_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.company_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: company_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.company_settings_id_seq OWNED BY public.company_settings.id;


--
-- Name: contract_consolidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contract_consolidations (
    id bigint NOT NULL,
    contract_id integer NOT NULL,
    consolidation_date date NOT NULL,
    operational_risk_value numeric NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    min_monte_carlo_weeks integer DEFAULT 0,
    max_monte_carlo_weeks integer DEFAULT 0,
    monte_carlo_duration_p80_weeks integer DEFAULT 0,
    estimated_hours_per_demand integer,
    real_hours_per_demand integer,
    development_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    design_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    management_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    development_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL,
    design_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL,
    management_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL,
    consumed_hours double precision DEFAULT 0.0
);


--
-- Name: contract_consolidations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contract_consolidations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contract_consolidations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contract_consolidations_id_seq OWNED BY public.contract_consolidations.id;


--
-- Name: contract_estimation_change_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contract_estimation_change_histories (
    id bigint NOT NULL,
    contract_id integer NOT NULL,
    change_date timestamp without time zone NOT NULL,
    hours_per_demand integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: contract_estimation_change_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contract_estimation_change_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contract_estimation_change_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contract_estimation_change_histories_id_seq OWNED BY public.contract_estimation_change_histories.id;


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contracts (
    id bigint NOT NULL,
    product_id integer NOT NULL,
    customer_id integer NOT NULL,
    contract_id integer,
    start_date date NOT NULL,
    end_date date,
    renewal_period integer DEFAULT 0 NOT NULL,
    automatic_renewal boolean DEFAULT false,
    total_hours integer NOT NULL,
    total_value integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    hours_per_demand integer DEFAULT 1 NOT NULL
);


--
-- Name: contracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contracts_id_seq OWNED BY public.contracts.id;


--
-- Name: customer_consolidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_consolidations (
    id bigint NOT NULL,
    customer_id integer NOT NULL,
    consolidation_date date NOT NULL,
    last_data_in_week boolean DEFAULT false,
    last_data_in_month boolean DEFAULT false,
    last_data_in_year boolean DEFAULT false,
    consumed_hours numeric DEFAULT 0.0,
    consumed_hours_in_month numeric DEFAULT 0.0,
    average_consumed_hours_in_month numeric DEFAULT 0.0,
    flow_pressure numeric DEFAULT 0.0,
    lead_time_p80 numeric DEFAULT 0.0,
    lead_time_p80_in_month numeric DEFAULT 0.0,
    value_per_demand numeric DEFAULT 0.0,
    value_per_demand_in_month numeric DEFAULT 0.0,
    hours_per_demand numeric DEFAULT 0.0,
    hours_per_demand_in_month numeric DEFAULT 0.0,
    qty_demands_created integer DEFAULT 0,
    qty_demands_committed integer DEFAULT 0,
    qty_demands_finished integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    development_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    design_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    management_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    development_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL,
    design_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL,
    management_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL
);


--
-- Name: customer_consolidations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_consolidations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_consolidations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_consolidations_id_seq OWNED BY public.customer_consolidations.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    products_count integer DEFAULT 0,
    projects_count integer DEFAULT 0,
    customer_id integer
);


--
-- Name: customers_devise_customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers_devise_customers (
    id bigint NOT NULL,
    customer_id integer NOT NULL,
    devise_customer_id integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: customers_devise_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_devise_customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_devise_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_devise_customers_id_seq OWNED BY public.customers_devise_customers.id;


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: customers_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers_projects (
    id bigint NOT NULL,
    customer_id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: customers_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_projects_id_seq OWNED BY public.customers_projects.id;


--
-- Name: demand_block_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demand_block_notifications (
    id bigint NOT NULL,
    demand_block_id integer NOT NULL,
    block_state integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: demand_block_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demand_block_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demand_block_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demand_block_notifications_id_seq OWNED BY public.demand_block_notifications.id;


--
-- Name: demand_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demand_blocks (
    id bigint NOT NULL,
    demand_id integer NOT NULL,
    block_time timestamp without time zone NOT NULL,
    unblock_time timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true NOT NULL,
    block_type integer DEFAULT 0 NOT NULL,
    discarded_at timestamp without time zone,
    stage_id integer,
    block_reason character varying,
    blocker_id integer NOT NULL,
    unblocker_id integer,
    unblock_reason character varying,
    risk_review_id integer,
    block_working_time_duration numeric,
    lock_version integer
);


--
-- Name: demand_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demand_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demand_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demand_blocks_id_seq OWNED BY public.demand_blocks.id;


--
-- Name: demand_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demand_comments (
    id bigint NOT NULL,
    demand_id integer NOT NULL,
    comment_date timestamp without time zone NOT NULL,
    comment_text character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team_member_id integer,
    discarded_at timestamp without time zone
);


--
-- Name: demand_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demand_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demand_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demand_comments_id_seq OWNED BY public.demand_comments.id;


--
-- Name: demand_efforts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demand_efforts (
    id bigint NOT NULL,
    item_assignment_id integer NOT NULL,
    demand_transition_id integer NOT NULL,
    demand_id integer NOT NULL,
    main_effort_in_transition boolean DEFAULT false NOT NULL,
    automatic_update boolean DEFAULT true NOT NULL,
    start_time_to_computation timestamp without time zone NOT NULL,
    finish_time_to_computation timestamp without time zone NOT NULL,
    effort_value numeric DEFAULT 0.0 NOT NULL,
    management_percentage numeric DEFAULT 0.0 NOT NULL,
    pairing_percentage numeric DEFAULT 0.0 NOT NULL,
    stage_percentage numeric DEFAULT 0.0 NOT NULL,
    total_blocked numeric DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    lock_version integer,
    membership_effort_percentage numeric
);


--
-- Name: demand_efforts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demand_efforts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demand_efforts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demand_efforts_id_seq OWNED BY public.demand_efforts.id;


--
-- Name: demand_score_matrices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demand_score_matrices (
    id bigint NOT NULL,
    demand_id integer NOT NULL,
    user_id integer NOT NULL,
    score_matrix_answer_id integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: demand_score_matrices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demand_score_matrices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demand_score_matrices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demand_score_matrices_id_seq OWNED BY public.demand_score_matrices.id;


--
-- Name: demand_transitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demand_transitions (
    id bigint NOT NULL,
    demand_id integer NOT NULL,
    stage_id integer NOT NULL,
    last_time_in timestamp without time zone NOT NULL,
    last_time_out timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    transition_notified boolean DEFAULT false NOT NULL,
    team_member_id integer,
    lock_version integer,
    transition_time_in_sec integer DEFAULT 0
);


--
-- Name: demand_transitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demand_transitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demand_transitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demand_transitions_id_seq OWNED BY public.demand_transitions.id;


--
-- Name: demands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demands (
    id bigint NOT NULL,
    external_id character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    demand_url character varying,
    commitment_date timestamp without time zone,
    end_date timestamp without time zone,
    created_date timestamp without time zone NOT NULL,
    external_url character varying,
    class_of_service integer DEFAULT 0 NOT NULL,
    project_id integer,
    effort_downstream numeric DEFAULT 0,
    effort_upstream numeric DEFAULT 0,
    leadtime numeric,
    manual_effort boolean DEFAULT false,
    total_queue_time integer DEFAULT 0,
    total_touch_time integer DEFAULT 0,
    demand_title character varying,
    discarded_at timestamp without time zone,
    slug character varying,
    company_id integer NOT NULL,
    portfolio_unit_id integer,
    product_id integer,
    team_id integer NOT NULL,
    cost_to_project numeric DEFAULT 0,
    total_bloked_working_time numeric DEFAULT 0,
    total_touch_blocked_time numeric DEFAULT 0,
    risk_review_id integer,
    demand_score numeric DEFAULT 0.0,
    service_delivery_review_id integer,
    current_stage_id integer,
    customer_id integer,
    demand_tags character varying[] DEFAULT '{}'::character varying[],
    contract_id integer,
    effort_development numeric DEFAULT 0.0 NOT NULL,
    effort_design numeric DEFAULT 0.0 NOT NULL,
    effort_management numeric DEFAULT 0.0 NOT NULL,
    lead_time_percentile_project_ranking double precision,
    work_item_type_id integer NOT NULL
);


--
-- Name: demands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demands_id_seq OWNED BY public.demands.id;


--
-- Name: devise_customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devise_customers (
    id bigint NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    language character varying DEFAULT 'pt-BR'::character varying NOT NULL
);


--
-- Name: devise_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.devise_customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devise_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.devise_customers_id_seq OWNED BY public.devise_customers.id;


--
-- Name: financial_informations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.financial_informations (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    finances_date date NOT NULL,
    income_total numeric NOT NULL,
    expenses_total numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: financial_informations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.financial_informations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: financial_informations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.financial_informations_id_seq OWNED BY public.financial_informations.id;


--
-- Name: flow_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_events (
    id bigint NOT NULL,
    project_id integer,
    event_type integer NOT NULL,
    event_description character varying NOT NULL,
    event_date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    risk_review_id integer,
    discarded_at timestamp without time zone,
    event_size integer DEFAULT 0 NOT NULL,
    user_id integer,
    event_end_date date,
    company_id integer NOT NULL,
    team_id integer
);


--
-- Name: flow_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flow_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flow_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flow_events_id_seq OWNED BY public.flow_events.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: integration_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integration_errors (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    occured_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    integration_type integer NOT NULL,
    integration_error_text character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id integer,
    integratable_model_name character varying
);


--
-- Name: integration_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.integration_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: integration_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.integration_errors_id_seq OWNED BY public.integration_errors.id;


--
-- Name: item_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_assignments (
    id bigint NOT NULL,
    demand_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    start_time timestamp without time zone NOT NULL,
    finish_time timestamp without time zone,
    discarded_at timestamp without time zone,
    item_assignment_effort numeric DEFAULT 0.0 NOT NULL,
    assignment_for_role boolean DEFAULT false,
    membership_id integer NOT NULL,
    pull_interval numeric DEFAULT 0.0,
    assignment_notified boolean DEFAULT false NOT NULL,
    lock_version integer
);


--
-- Name: item_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.item_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.item_assignments_id_seq OWNED BY public.item_assignments.id;


--
-- Name: jira_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jira_accounts (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    username character varying NOT NULL,
    encrypted_api_token character varying NOT NULL,
    base_uri character varying NOT NULL,
    customer_domain character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jira_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jira_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jira_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jira_accounts_id_seq OWNED BY public.jira_accounts.id;


--
-- Name: jira_api_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jira_api_errors (
    id bigint NOT NULL,
    demand_id integer NOT NULL,
    processed boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: jira_api_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jira_api_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jira_api_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jira_api_errors_id_seq OWNED BY public.jira_api_errors.id;


--
-- Name: jira_custom_field_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jira_custom_field_mappings (
    id bigint NOT NULL,
    jira_account_id integer NOT NULL,
    custom_field_type integer NOT NULL,
    custom_field_machine_name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jira_custom_field_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jira_custom_field_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jira_custom_field_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jira_custom_field_mappings_id_seq OWNED BY public.jira_custom_field_mappings.id;


--
-- Name: jira_portfolio_unit_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jira_portfolio_unit_configs (
    id bigint NOT NULL,
    portfolio_unit_id integer NOT NULL,
    jira_field_name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jira_portfolio_unit_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jira_portfolio_unit_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jira_portfolio_unit_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jira_portfolio_unit_configs_id_seq OWNED BY public.jira_portfolio_unit_configs.id;


--
-- Name: jira_product_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jira_product_configs (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    product_id integer NOT NULL,
    jira_product_key character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jira_product_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jira_product_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jira_product_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jira_product_configs_id_seq OWNED BY public.jira_product_configs.id;


--
-- Name: jira_project_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jira_project_configs (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fix_version_name character varying NOT NULL,
    jira_product_config_id integer NOT NULL
);


--
-- Name: jira_project_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jira_project_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jira_project_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jira_project_configs_id_seq OWNED BY public.jira_project_configs.id;


--
-- Name: membership_available_hours_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_available_hours_histories (
    id bigint NOT NULL,
    membership_id integer NOT NULL,
    available_hours integer NOT NULL,
    change_date timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: membership_available_hours_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.membership_available_hours_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: membership_available_hours_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.membership_available_hours_histories_id_seq OWNED BY public.membership_available_hours_histories.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id bigint NOT NULL,
    team_member_id integer NOT NULL,
    team_id integer NOT NULL,
    member_role integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hours_per_month integer,
    start_date date NOT NULL,
    end_date date,
    effort_percentage numeric
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: operations_dashboard_pairings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operations_dashboard_pairings (
    id bigint NOT NULL,
    operations_dashboard_id integer NOT NULL,
    pair_id integer NOT NULL,
    pair_times integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: operations_dashboard_pairings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.operations_dashboard_pairings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operations_dashboard_pairings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.operations_dashboard_pairings_id_seq OWNED BY public.operations_dashboard_pairings.id;


--
-- Name: operations_dashboards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operations_dashboards (
    id bigint NOT NULL,
    dashboard_date date NOT NULL,
    last_data_in_week boolean DEFAULT false NOT NULL,
    last_data_in_month boolean DEFAULT false NOT NULL,
    last_data_in_year boolean DEFAULT false NOT NULL,
    team_member_id integer NOT NULL,
    demands_ids integer[],
    first_delivery_id integer,
    delivered_demands_count integer DEFAULT 0 NOT NULL,
    bugs_count integer DEFAULT 0 NOT NULL,
    lead_time_min numeric DEFAULT 0.0 NOT NULL,
    lead_time_max numeric DEFAULT 0.0 NOT NULL,
    lead_time_p80 numeric DEFAULT 0.0 NOT NULL,
    projects_count integer DEFAULT 0 NOT NULL,
    member_effort numeric,
    pull_interval integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: operations_dashboards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.operations_dashboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operations_dashboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.operations_dashboards_id_seq OWNED BY public.operations_dashboards.id;


--
-- Name: plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plans (
    id bigint NOT NULL,
    plan_value integer NOT NULL,
    plan_type integer NOT NULL,
    plan_period integer NOT NULL,
    plan_details character varying NOT NULL,
    max_number_of_downloads integer NOT NULL,
    max_number_of_users integer NOT NULL,
    max_days_in_history integer NOT NULL,
    extra_download_value numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plans_id_seq OWNED BY public.plans.id;


--
-- Name: portfolio_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.portfolio_units (
    id bigint NOT NULL,
    product_id integer NOT NULL,
    parent_id integer,
    name character varying NOT NULL,
    portfolio_unit_type integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id character varying
);


--
-- Name: portfolio_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.portfolio_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: portfolio_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.portfolio_units_id_seq OWNED BY public.portfolio_units.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    customer_id integer,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    company_id integer NOT NULL,
    slug character varying NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: products_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products_projects (
    id bigint NOT NULL,
    product_id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: products_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_projects_id_seq OWNED BY public.products_projects.id;


--
-- Name: project_additional_hours; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_additional_hours (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    event_date date NOT NULL,
    hours_type integer DEFAULT 0 NOT NULL,
    hours double precision DEFAULT 0.0 NOT NULL,
    obs character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: project_additional_hours_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_additional_hours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_additional_hours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_additional_hours_id_seq OWNED BY public.project_additional_hours.id;


--
-- Name: project_broken_wip_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_broken_wip_logs (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    project_wip integer NOT NULL,
    demands_ids integer[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: project_broken_wip_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_broken_wip_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_broken_wip_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_broken_wip_logs_id_seq OWNED BY public.project_broken_wip_logs.id;


--
-- Name: project_change_deadline_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_change_deadline_histories (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    previous_date date,
    new_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: project_change_deadline_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_change_deadline_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_change_deadline_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_change_deadline_histories_id_seq OWNED BY public.project_change_deadline_histories.id;


--
-- Name: project_consolidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_consolidations (
    id bigint NOT NULL,
    consolidation_date date NOT NULL,
    project_id integer NOT NULL,
    demands_ids integer[],
    demands_finished_ids integer[],
    wip_limit integer,
    current_wip integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_data_in_week boolean DEFAULT false NOT NULL,
    last_data_in_month boolean DEFAULT false NOT NULL,
    last_data_in_year boolean DEFAULT false NOT NULL,
    project_scope integer DEFAULT 0,
    flow_pressure numeric DEFAULT 0.0,
    project_quality numeric DEFAULT 0.0,
    value_per_demand numeric DEFAULT 0.0,
    monte_carlo_weeks_min integer DEFAULT 0,
    monte_carlo_weeks_max integer DEFAULT 0,
    monte_carlo_weeks_std_dev numeric DEFAULT 0,
    monte_carlo_weeks_p80 numeric DEFAULT 0.0,
    operational_risk numeric DEFAULT 0.0,
    team_based_monte_carlo_weeks_min integer DEFAULT 0,
    team_based_monte_carlo_weeks_max integer DEFAULT 0,
    team_based_monte_carlo_weeks_std_dev numeric DEFAULT 0,
    team_based_monte_carlo_weeks_p80 numeric DEFAULT 0.0,
    lead_time_min numeric DEFAULT 0.0,
    lead_time_max numeric DEFAULT 0.0,
    lead_time_p25 numeric DEFAULT 0.0,
    lead_time_p75 numeric DEFAULT 0.0,
    lead_time_p80 numeric DEFAULT 0.0,
    lead_time_average numeric DEFAULT 0.0,
    lead_time_std_dev numeric DEFAULT 0.0,
    lead_time_histogram_bin_min numeric DEFAULT 0.0,
    lead_time_histogram_bin_max numeric DEFAULT 0.0,
    weeks_by_little_law numeric DEFAULT 0.0,
    project_throughput integer DEFAULT 0,
    hours_per_demand numeric DEFAULT 0.0,
    flow_efficiency numeric DEFAULT 0.0,
    bugs_opened integer DEFAULT 0,
    bugs_closed integer DEFAULT 0,
    lead_time_p65 numeric DEFAULT 0.0,
    lead_time_p95 numeric DEFAULT 0.0,
    lead_time_min_month numeric DEFAULT 0.0,
    lead_time_max_month numeric DEFAULT 0.0,
    lead_time_p80_month numeric DEFAULT 0.0,
    lead_time_std_dev_month numeric DEFAULT 0.0,
    flow_efficiency_month numeric DEFAULT 0.0,
    hours_per_demand_month numeric DEFAULT 0.0,
    code_needed_blocks_count integer DEFAULT 0,
    code_needed_blocks_per_demand numeric DEFAULT 0.0,
    project_scope_hours integer DEFAULT 0,
    project_throughput_hours numeric DEFAULT 0.0,
    project_throughput_hours_upstream numeric DEFAULT 0.0,
    project_throughput_hours_downstream numeric DEFAULT 0.0,
    project_throughput_hours_in_month numeric,
    project_throughput_hours_upstream_in_month numeric,
    project_throughput_hours_downstream_in_month numeric,
    project_throughput_hours_development numeric DEFAULT 0.0 NOT NULL,
    project_throughput_hours_design numeric DEFAULT 0.0 NOT NULL,
    project_throughput_hours_management numeric DEFAULT 0.0 NOT NULL,
    project_throughput_hours_development_in_month numeric DEFAULT 0.0 NOT NULL,
    project_throughput_hours_design_in_month numeric DEFAULT 0.0 NOT NULL,
    project_throughput_hours_management_in_month numeric DEFAULT 0.0 NOT NULL,
    project_throughput_hours_additional double precision,
    project_throughput_hours_additional_in_month double precision,
    team_based_operational_risk numeric
);


--
-- Name: project_consolidations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_consolidations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_consolidations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_consolidations_id_seq OWNED BY public.project_consolidations.id;


--
-- Name: project_risk_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_risk_alerts (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    project_risk_config_id integer NOT NULL,
    alert_color integer NOT NULL,
    alert_value numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: project_risk_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_risk_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_risk_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_risk_alerts_id_seq OWNED BY public.project_risk_alerts.id;


--
-- Name: project_risk_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_risk_configs (
    id bigint NOT NULL,
    risk_type integer NOT NULL,
    high_yellow_value numeric NOT NULL,
    low_yellow_value numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id integer NOT NULL,
    active boolean DEFAULT true
);


--
-- Name: project_risk_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_risk_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_risk_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_risk_configs_id_seq OWNED BY public.project_risk_configs.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    name character varying NOT NULL,
    status integer NOT NULL,
    project_type integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    value numeric,
    qty_hours numeric,
    hour_value numeric,
    initial_scope integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nickname character varying,
    percentage_effort_to_bugs integer DEFAULT 0 NOT NULL,
    team_id integer NOT NULL,
    max_work_in_progress numeric DEFAULT 1.0 NOT NULL,
    company_id integer NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: replenishing_consolidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.replenishing_consolidations (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    consolidation_date date NOT NULL,
    project_based_risks_to_deadline numeric,
    flow_pressure numeric,
    relative_flow_pressure numeric,
    qty_using_pressure numeric,
    leadtime_80 numeric,
    qty_selected_last_week numeric,
    work_in_progress numeric,
    montecarlo_80_percent numeric,
    customer_happiness numeric,
    max_work_in_progress integer,
    project_throughput_data integer[],
    team_wip integer,
    team_throughput_data integer[],
    team_lead_time numeric,
    team_based_montecarlo_80_percent numeric,
    team_monte_carlo_weeks_std_dev numeric,
    team_monte_carlo_weeks_min numeric,
    team_monte_carlo_weeks_max numeric,
    team_based_odds_to_deadline numeric,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: replenishing_consolidations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.replenishing_consolidations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: replenishing_consolidations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.replenishing_consolidations_id_seq OWNED BY public.replenishing_consolidations.id;


--
-- Name: risk_review_action_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.risk_review_action_items (
    id bigint NOT NULL,
    risk_review_id integer NOT NULL,
    membership_id integer NOT NULL,
    created_date date NOT NULL,
    action_type integer DEFAULT 0 NOT NULL,
    description character varying NOT NULL,
    deadline date NOT NULL,
    done_date date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: risk_review_action_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.risk_review_action_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: risk_review_action_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.risk_review_action_items_id_seq OWNED BY public.risk_review_action_items.id;


--
-- Name: risk_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.risk_reviews (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    product_id integer NOT NULL,
    meeting_date date NOT NULL,
    lead_time_outlier_limit numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    weekly_avg_blocked_time numeric[],
    monthly_avg_blocked_time numeric[]
);


--
-- Name: risk_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.risk_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: risk_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.risk_reviews_id_seq OWNED BY public.risk_reviews.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: score_matrices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.score_matrices (
    id bigint NOT NULL,
    product_id integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: score_matrices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.score_matrices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: score_matrices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.score_matrices_id_seq OWNED BY public.score_matrices.id;


--
-- Name: score_matrix_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.score_matrix_answers (
    id bigint NOT NULL,
    score_matrix_question_id integer NOT NULL,
    description character varying NOT NULL,
    answer_value integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: score_matrix_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.score_matrix_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: score_matrix_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.score_matrix_answers_id_seq OWNED BY public.score_matrix_answers.id;


--
-- Name: score_matrix_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.score_matrix_questions (
    id bigint NOT NULL,
    score_matrix_id integer NOT NULL,
    question_type integer DEFAULT 0 NOT NULL,
    description character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    question_weight integer NOT NULL
);


--
-- Name: score_matrix_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.score_matrix_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: score_matrix_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.score_matrix_questions_id_seq OWNED BY public.score_matrix_questions.id;


--
-- Name: service_delivery_review_action_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_delivery_review_action_items (
    id bigint NOT NULL,
    service_delivery_review_id integer NOT NULL,
    membership_id integer NOT NULL,
    action_type integer DEFAULT 0 NOT NULL,
    description character varying NOT NULL,
    deadline date NOT NULL,
    done_date date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: service_delivery_review_action_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.service_delivery_review_action_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_delivery_review_action_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.service_delivery_review_action_items_id_seq OWNED BY public.service_delivery_review_action_items.id;


--
-- Name: service_delivery_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_delivery_reviews (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    product_id integer NOT NULL,
    meeting_date date NOT NULL,
    lead_time_top_threshold numeric NOT NULL,
    lead_time_bottom_threshold numeric NOT NULL,
    quality_top_threshold numeric NOT NULL,
    quality_bottom_threshold numeric NOT NULL,
    expedite_max_pull_time_sla integer NOT NULL,
    delayed_expedite_top_threshold numeric NOT NULL,
    delayed_expedite_bottom_threshold numeric NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    bugs_ids integer[]
);


--
-- Name: service_delivery_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.service_delivery_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_delivery_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.service_delivery_reviews_id_seq OWNED BY public.service_delivery_reviews.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    session_id character varying NOT NULL,
    data text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: slack_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slack_configurations (
    id bigint NOT NULL,
    team_id integer,
    room_webhook character varying NOT NULL,
    notification_hour integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    info_type integer DEFAULT 0 NOT NULL,
    weekday_to_notify integer DEFAULT 0 NOT NULL,
    notification_minute integer,
    active boolean DEFAULT true,
    stages_to_notify_transition integer[],
    customer_id integer,
    config_type integer DEFAULT 0
);


--
-- Name: slack_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slack_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slack_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slack_configurations_id_seq OWNED BY public.slack_configurations.id;


--
-- Name: stage_project_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stage_project_configs (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    stage_id integer NOT NULL,
    compute_effort boolean DEFAULT false,
    stage_percentage integer DEFAULT 0 NOT NULL,
    management_percentage integer DEFAULT 0 NOT NULL,
    pairing_percentage integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    max_seconds_in_stage integer DEFAULT 0
);


--
-- Name: stage_project_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stage_project_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stage_project_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stage_project_configs_id_seq OWNED BY public.stage_project_configs.id;


--
-- Name: stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stages (
    id bigint NOT NULL,
    integration_id character varying NOT NULL,
    name character varying NOT NULL,
    stage_type integer DEFAULT 0 NOT NULL,
    stage_stream integer DEFAULT 0 NOT NULL,
    commitment_point boolean DEFAULT false,
    end_point boolean DEFAULT false,
    queue boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    company_id integer NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    integration_pipe_id character varying,
    parent_id integer,
    stage_level integer DEFAULT 0 NOT NULL
);


--
-- Name: stages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stages_id_seq OWNED BY public.stages.id;


--
-- Name: stages_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stages_teams (
    id bigint NOT NULL,
    stage_id integer NOT NULL,
    team_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stages_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stages_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stages_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stages_teams_id_seq OWNED BY public.stages_teams.id;


--
-- Name: team_consolidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_consolidations (
    id bigint NOT NULL,
    team_id integer NOT NULL,
    consolidation_date date NOT NULL,
    last_data_in_week boolean DEFAULT false,
    last_data_in_month boolean DEFAULT false,
    last_data_in_year boolean DEFAULT false,
    consumed_hours_in_month numeric DEFAULT 0.0,
    lead_time_p80 numeric DEFAULT 0.0,
    lead_time_p80_in_week numeric DEFAULT 0.0,
    lead_time_p80_in_month numeric DEFAULT 0.0,
    lead_time_p80_in_quarter numeric DEFAULT 0.0,
    lead_time_p80_in_semester numeric DEFAULT 0.0,
    lead_time_p80_in_year numeric DEFAULT 0.0,
    flow_efficiency numeric DEFAULT 0.0,
    flow_efficiency_in_month numeric DEFAULT 0.0,
    flow_efficiency_in_quarter numeric DEFAULT 0.0,
    flow_efficiency_in_semester numeric DEFAULT 0.0,
    flow_efficiency_in_year numeric DEFAULT 0.0,
    hours_per_demand numeric DEFAULT 0.0,
    hours_per_demand_in_month numeric DEFAULT 0.0,
    hours_per_demand_in_quarter numeric DEFAULT 0.0,
    hours_per_demand_in_semester numeric DEFAULT 0.0,
    hours_per_demand_in_year numeric DEFAULT 0.0,
    value_per_demand numeric DEFAULT 0.0,
    value_per_demand_in_month numeric DEFAULT 0.0,
    value_per_demand_in_quarter numeric DEFAULT 0.0,
    value_per_demand_in_semester numeric DEFAULT 0.0,
    value_per_demand_in_year numeric DEFAULT 0.0,
    qty_demands_created integer DEFAULT 0,
    qty_demands_created_in_week integer DEFAULT 0,
    qty_demands_committed integer DEFAULT 0,
    qty_demands_committed_in_week integer DEFAULT 0,
    qty_demands_finished_upstream integer DEFAULT 0,
    qty_demands_finished_upstream_in_week integer DEFAULT 0,
    qty_demands_finished_upstream_in_month integer DEFAULT 0,
    qty_demands_finished_upstream_in_quarter integer DEFAULT 0,
    qty_demands_finished_upstream_in_semester integer DEFAULT 0,
    qty_demands_finished_upstream_in_year integer DEFAULT 0,
    qty_demands_finished_downstream integer DEFAULT 0,
    qty_demands_finished_downstream_in_week integer DEFAULT 0,
    qty_demands_finished_downstream_in_month integer DEFAULT 0,
    qty_demands_finished_downstream_in_quarter integer DEFAULT 0,
    qty_demands_finished_downstream_in_semester integer DEFAULT 0,
    qty_demands_finished_downstream_in_year integer DEFAULT 0,
    qty_bugs_opened integer DEFAULT 0,
    qty_bugs_opened_in_month integer DEFAULT 0,
    qty_bugs_opened_in_quarter integer DEFAULT 0,
    qty_bugs_opened_in_semester integer DEFAULT 0,
    qty_bugs_opened_in_year integer DEFAULT 0,
    qty_bugs_closed integer DEFAULT 0,
    qty_bugs_closed_in_month integer DEFAULT 0,
    qty_bugs_closed_in_quarter integer DEFAULT 0,
    qty_bugs_closed_in_semester integer DEFAULT 0,
    qty_bugs_closed_in_year integer DEFAULT 0,
    bugs_share numeric DEFAULT 0.0,
    bugs_share_in_month numeric DEFAULT 0.0,
    bugs_share_in_quarter numeric DEFAULT 0.0,
    bugs_share_in_semester numeric DEFAULT 0.0,
    bugs_share_in_year numeric DEFAULT 0.0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    development_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    design_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    management_consumed_hours numeric DEFAULT 0.0 NOT NULL,
    development_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL,
    design_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL,
    management_consumed_hours_in_month numeric DEFAULT 0.0 NOT NULL
);


--
-- Name: team_consolidations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_consolidations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_consolidations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_consolidations_id_seq OWNED BY public.team_consolidations.id;


--
-- Name: team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_members (
    id bigint NOT NULL,
    name character varying NOT NULL,
    monthly_payment numeric,
    billable boolean DEFAULT true,
    billable_type integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    start_date date,
    end_date date,
    jira_account_user_email character varying,
    jira_account_id character varying,
    company_id integer NOT NULL,
    user_id integer,
    hours_per_month integer DEFAULT 0
);


--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_members_id_seq OWNED BY public.team_members.id;


--
-- Name: team_resource_allocations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_resource_allocations (
    id bigint NOT NULL,
    team_resource_id integer NOT NULL,
    team_id integer NOT NULL,
    monthly_payment numeric NOT NULL,
    start_date date NOT NULL,
    end_date date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: team_resource_allocations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_resource_allocations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_resource_allocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_resource_allocations_id_seq OWNED BY public.team_resource_allocations.id;


--
-- Name: team_resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_resources (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    resource_type integer NOT NULL,
    resource_name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: team_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_resources_id_seq OWNED BY public.team_resources.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    max_work_in_progress integer DEFAULT 0 NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: user_company_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_company_roles (
    user_id integer,
    company_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id integer NOT NULL,
    user_role integer DEFAULT 0 NOT NULL,
    start_date date,
    end_date date,
    slack_user character varying
);


--
-- Name: user_company_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_company_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_company_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_company_roles_id_seq OWNED BY public.user_company_roles.id;


--
-- Name: user_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_invites (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    invite_status integer NOT NULL,
    invite_type integer NOT NULL,
    invite_object_id integer NOT NULL,
    invite_email character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_invites_id_seq OWNED BY public.user_invites.id;


--
-- Name: user_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_plans (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    plan_id integer NOT NULL,
    plan_billing_period integer DEFAULT 0 NOT NULL,
    plan_value numeric DEFAULT 0 NOT NULL,
    start_at timestamp without time zone NOT NULL,
    finish_at timestamp without time zone NOT NULL,
    active boolean DEFAULT false NOT NULL,
    paid boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_plans_id_seq OWNED BY public.user_plans.id;


--
-- Name: user_project_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_project_roles (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    role_in_project integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_project_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_project_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_project_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_project_roles_id_seq OWNED BY public.user_project_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    last_company_id integer,
    email_notifications boolean DEFAULT false NOT NULL,
    user_money_credits numeric DEFAULT 0 NOT NULL,
    avatar character varying,
    language character varying DEFAULT 'pt-BR'::character varying NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: work_item_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_item_types (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    name character varying NOT NULL,
    item_level integer DEFAULT 0 NOT NULL,
    quality_indicator_type boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: work_item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_item_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_item_types_id_seq OWNED BY public.work_item_types.id;


--
-- Name: remote_schemas id; Type: DEFAULT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.remote_schemas ALTER COLUMN id SET DEFAULT nextval('hdb_catalog.remote_schemas_id_seq'::regclass);


--
-- Name: class_of_service_change_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_of_service_change_histories ALTER COLUMN id SET DEFAULT nextval('public.class_of_service_change_histories_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: company_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_settings ALTER COLUMN id SET DEFAULT nextval('public.company_settings_id_seq'::regclass);


--
-- Name: contract_consolidations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_consolidations ALTER COLUMN id SET DEFAULT nextval('public.contract_consolidations_id_seq'::regclass);


--
-- Name: contract_estimation_change_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_estimation_change_histories ALTER COLUMN id SET DEFAULT nextval('public.contract_estimation_change_histories_id_seq'::regclass);


--
-- Name: contracts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts ALTER COLUMN id SET DEFAULT nextval('public.contracts_id_seq'::regclass);


--
-- Name: customer_consolidations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_consolidations ALTER COLUMN id SET DEFAULT nextval('public.customer_consolidations_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: customers_devise_customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_devise_customers ALTER COLUMN id SET DEFAULT nextval('public.customers_devise_customers_id_seq'::regclass);


--
-- Name: customers_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_projects ALTER COLUMN id SET DEFAULT nextval('public.customers_projects_id_seq'::regclass);


--
-- Name: demand_block_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_block_notifications ALTER COLUMN id SET DEFAULT nextval('public.demand_block_notifications_id_seq'::regclass);


--
-- Name: demand_blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks ALTER COLUMN id SET DEFAULT nextval('public.demand_blocks_id_seq'::regclass);


--
-- Name: demand_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_comments ALTER COLUMN id SET DEFAULT nextval('public.demand_comments_id_seq'::regclass);


--
-- Name: demand_efforts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_efforts ALTER COLUMN id SET DEFAULT nextval('public.demand_efforts_id_seq'::regclass);


--
-- Name: demand_score_matrices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_score_matrices ALTER COLUMN id SET DEFAULT nextval('public.demand_score_matrices_id_seq'::regclass);


--
-- Name: demand_transitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_transitions ALTER COLUMN id SET DEFAULT nextval('public.demand_transitions_id_seq'::regclass);


--
-- Name: demands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands ALTER COLUMN id SET DEFAULT nextval('public.demands_id_seq'::regclass);


--
-- Name: devise_customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devise_customers ALTER COLUMN id SET DEFAULT nextval('public.devise_customers_id_seq'::regclass);


--
-- Name: financial_informations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_informations ALTER COLUMN id SET DEFAULT nextval('public.financial_informations_id_seq'::regclass);


--
-- Name: flow_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_events ALTER COLUMN id SET DEFAULT nextval('public.flow_events_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: integration_errors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_errors ALTER COLUMN id SET DEFAULT nextval('public.integration_errors_id_seq'::regclass);


--
-- Name: item_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_assignments ALTER COLUMN id SET DEFAULT nextval('public.item_assignments_id_seq'::regclass);


--
-- Name: jira_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_accounts ALTER COLUMN id SET DEFAULT nextval('public.jira_accounts_id_seq'::regclass);


--
-- Name: jira_api_errors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_api_errors ALTER COLUMN id SET DEFAULT nextval('public.jira_api_errors_id_seq'::regclass);


--
-- Name: jira_custom_field_mappings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_custom_field_mappings ALTER COLUMN id SET DEFAULT nextval('public.jira_custom_field_mappings_id_seq'::regclass);


--
-- Name: jira_portfolio_unit_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_portfolio_unit_configs ALTER COLUMN id SET DEFAULT nextval('public.jira_portfolio_unit_configs_id_seq'::regclass);


--
-- Name: jira_product_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_product_configs ALTER COLUMN id SET DEFAULT nextval('public.jira_product_configs_id_seq'::regclass);


--
-- Name: jira_project_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_project_configs ALTER COLUMN id SET DEFAULT nextval('public.jira_project_configs_id_seq'::regclass);


--
-- Name: membership_available_hours_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_available_hours_histories ALTER COLUMN id SET DEFAULT nextval('public.membership_available_hours_histories_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: operations_dashboard_pairings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operations_dashboard_pairings ALTER COLUMN id SET DEFAULT nextval('public.operations_dashboard_pairings_id_seq'::regclass);


--
-- Name: operations_dashboards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operations_dashboards ALTER COLUMN id SET DEFAULT nextval('public.operations_dashboards_id_seq'::regclass);


--
-- Name: plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plans ALTER COLUMN id SET DEFAULT nextval('public.plans_id_seq'::regclass);


--
-- Name: portfolio_units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.portfolio_units ALTER COLUMN id SET DEFAULT nextval('public.portfolio_units_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: products_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products_projects ALTER COLUMN id SET DEFAULT nextval('public.products_projects_id_seq'::regclass);


--
-- Name: project_additional_hours id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_additional_hours ALTER COLUMN id SET DEFAULT nextval('public.project_additional_hours_id_seq'::regclass);


--
-- Name: project_broken_wip_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_broken_wip_logs ALTER COLUMN id SET DEFAULT nextval('public.project_broken_wip_logs_id_seq'::regclass);


--
-- Name: project_change_deadline_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_change_deadline_histories ALTER COLUMN id SET DEFAULT nextval('public.project_change_deadline_histories_id_seq'::regclass);


--
-- Name: project_consolidations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_consolidations ALTER COLUMN id SET DEFAULT nextval('public.project_consolidations_id_seq'::regclass);


--
-- Name: project_risk_alerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_risk_alerts ALTER COLUMN id SET DEFAULT nextval('public.project_risk_alerts_id_seq'::regclass);


--
-- Name: project_risk_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_risk_configs ALTER COLUMN id SET DEFAULT nextval('public.project_risk_configs_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: replenishing_consolidations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.replenishing_consolidations ALTER COLUMN id SET DEFAULT nextval('public.replenishing_consolidations_id_seq'::regclass);


--
-- Name: risk_review_action_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_review_action_items ALTER COLUMN id SET DEFAULT nextval('public.risk_review_action_items_id_seq'::regclass);


--
-- Name: risk_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_reviews ALTER COLUMN id SET DEFAULT nextval('public.risk_reviews_id_seq'::regclass);


--
-- Name: score_matrices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrices ALTER COLUMN id SET DEFAULT nextval('public.score_matrices_id_seq'::regclass);


--
-- Name: score_matrix_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrix_answers ALTER COLUMN id SET DEFAULT nextval('public.score_matrix_answers_id_seq'::regclass);


--
-- Name: score_matrix_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrix_questions ALTER COLUMN id SET DEFAULT nextval('public.score_matrix_questions_id_seq'::regclass);


--
-- Name: service_delivery_review_action_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_delivery_review_action_items ALTER COLUMN id SET DEFAULT nextval('public.service_delivery_review_action_items_id_seq'::regclass);


--
-- Name: service_delivery_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_delivery_reviews ALTER COLUMN id SET DEFAULT nextval('public.service_delivery_reviews_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: slack_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations ALTER COLUMN id SET DEFAULT nextval('public.slack_configurations_id_seq'::regclass);


--
-- Name: stage_project_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stage_project_configs ALTER COLUMN id SET DEFAULT nextval('public.stage_project_configs_id_seq'::regclass);


--
-- Name: stages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages ALTER COLUMN id SET DEFAULT nextval('public.stages_id_seq'::regclass);


--
-- Name: stages_teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages_teams ALTER COLUMN id SET DEFAULT nextval('public.stages_teams_id_seq'::regclass);


--
-- Name: team_consolidations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_consolidations ALTER COLUMN id SET DEFAULT nextval('public.team_consolidations_id_seq'::regclass);


--
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members ALTER COLUMN id SET DEFAULT nextval('public.team_members_id_seq'::regclass);


--
-- Name: team_resource_allocations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_resource_allocations ALTER COLUMN id SET DEFAULT nextval('public.team_resource_allocations_id_seq'::regclass);


--
-- Name: team_resources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_resources ALTER COLUMN id SET DEFAULT nextval('public.team_resources_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: user_company_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_company_roles ALTER COLUMN id SET DEFAULT nextval('public.user_company_roles_id_seq'::regclass);


--
-- Name: user_invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_invites ALTER COLUMN id SET DEFAULT nextval('public.user_invites_id_seq'::regclass);


--
-- Name: user_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_plans ALTER COLUMN id SET DEFAULT nextval('public.user_plans_id_seq'::regclass);


--
-- Name: user_project_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_project_roles ALTER COLUMN id SET DEFAULT nextval('public.user_project_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: work_item_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_item_types ALTER COLUMN id SET DEFAULT nextval('public.work_item_types_id_seq'::regclass);


--
-- Name: event_invocation_logs event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: event_log event_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.event_log
    ADD CONSTRAINT event_log_pkey PRIMARY KEY (id);


--
-- Name: event_triggers event_triggers_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_pkey PRIMARY KEY (name);


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_action_permission hdb_action_permission_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_action_permission
    ADD CONSTRAINT hdb_action_permission_pkey PRIMARY KEY (action_name, role_name);


--
-- Name: hdb_action hdb_action_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_action
    ADD CONSTRAINT hdb_action_pkey PRIMARY KEY (action_name);


--
-- Name: hdb_allowlist hdb_allowlist_collection_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_allowlist
    ADD CONSTRAINT hdb_allowlist_collection_name_key UNIQUE (collection_name);


--
-- Name: hdb_computed_field hdb_computed_field_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_computed_field
    ADD CONSTRAINT hdb_computed_field_pkey PRIMARY KEY (table_schema, table_name, computed_field_name);


--
-- Name: hdb_function hdb_function_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_function
    ADD CONSTRAINT hdb_function_pkey PRIMARY KEY (function_schema, function_name);


--
-- Name: hdb_permission hdb_permission_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_pkey PRIMARY KEY (table_schema, table_name, role_name, perm_type);


--
-- Name: hdb_query_collection hdb_query_collection_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_query_collection
    ADD CONSTRAINT hdb_query_collection_pkey PRIMARY KEY (collection_name);


--
-- Name: hdb_relationship hdb_relationship_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_pkey PRIMARY KEY (table_schema, table_name, rel_name);


--
-- Name: hdb_table hdb_table_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_table
    ADD CONSTRAINT hdb_table_pkey PRIMARY KEY (table_schema, table_name);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: remote_schemas remote_schemas_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_name_key UNIQUE (name);


--
-- Name: remote_schemas remote_schemas_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: class_of_service_change_histories class_of_service_change_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_of_service_change_histories
    ADD CONSTRAINT class_of_service_change_histories_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: company_settings company_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_settings
    ADD CONSTRAINT company_settings_pkey PRIMARY KEY (id);


--
-- Name: contract_consolidations contract_consolidations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_consolidations
    ADD CONSTRAINT contract_consolidations_pkey PRIMARY KEY (id);


--
-- Name: contract_estimation_change_histories contract_estimation_change_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_estimation_change_histories
    ADD CONSTRAINT contract_estimation_change_histories_pkey PRIMARY KEY (id);


--
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);


--
-- Name: customer_consolidations customer_consolidations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_consolidations
    ADD CONSTRAINT customer_consolidations_pkey PRIMARY KEY (id);


--
-- Name: customers_devise_customers customers_devise_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_devise_customers
    ADD CONSTRAINT customers_devise_customers_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: customers_projects customers_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_projects
    ADD CONSTRAINT customers_projects_pkey PRIMARY KEY (id);


--
-- Name: demand_block_notifications demand_block_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_block_notifications
    ADD CONSTRAINT demand_block_notifications_pkey PRIMARY KEY (id);


--
-- Name: demand_blocks demand_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks
    ADD CONSTRAINT demand_blocks_pkey PRIMARY KEY (id);


--
-- Name: demand_comments demand_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_comments
    ADD CONSTRAINT demand_comments_pkey PRIMARY KEY (id);


--
-- Name: demand_efforts demand_efforts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_efforts
    ADD CONSTRAINT demand_efforts_pkey PRIMARY KEY (id);


--
-- Name: demand_score_matrices demand_score_matrices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_score_matrices
    ADD CONSTRAINT demand_score_matrices_pkey PRIMARY KEY (id);


--
-- Name: demand_transitions demand_transitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_transitions
    ADD CONSTRAINT demand_transitions_pkey PRIMARY KEY (id);


--
-- Name: demands demands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT demands_pkey PRIMARY KEY (id);


--
-- Name: devise_customers devise_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devise_customers
    ADD CONSTRAINT devise_customers_pkey PRIMARY KEY (id);


--
-- Name: financial_informations financial_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_informations
    ADD CONSTRAINT financial_informations_pkey PRIMARY KEY (id);


--
-- Name: flow_events flow_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_events
    ADD CONSTRAINT flow_events_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: integration_errors integration_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_errors
    ADD CONSTRAINT integration_errors_pkey PRIMARY KEY (id);


--
-- Name: item_assignments item_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_assignments
    ADD CONSTRAINT item_assignments_pkey PRIMARY KEY (id);


--
-- Name: jira_accounts jira_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_accounts
    ADD CONSTRAINT jira_accounts_pkey PRIMARY KEY (id);


--
-- Name: jira_api_errors jira_api_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_api_errors
    ADD CONSTRAINT jira_api_errors_pkey PRIMARY KEY (id);


--
-- Name: jira_custom_field_mappings jira_custom_field_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_custom_field_mappings
    ADD CONSTRAINT jira_custom_field_mappings_pkey PRIMARY KEY (id);


--
-- Name: jira_portfolio_unit_configs jira_portfolio_unit_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_portfolio_unit_configs
    ADD CONSTRAINT jira_portfolio_unit_configs_pkey PRIMARY KEY (id);


--
-- Name: jira_product_configs jira_product_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_product_configs
    ADD CONSTRAINT jira_product_configs_pkey PRIMARY KEY (id);


--
-- Name: jira_project_configs jira_project_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_project_configs
    ADD CONSTRAINT jira_project_configs_pkey PRIMARY KEY (id);


--
-- Name: membership_available_hours_histories membership_available_hours_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_available_hours_histories
    ADD CONSTRAINT membership_available_hours_histories_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: operations_dashboard_pairings operations_dashboard_pairings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operations_dashboard_pairings
    ADD CONSTRAINT operations_dashboard_pairings_pkey PRIMARY KEY (id);


--
-- Name: operations_dashboards operations_dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operations_dashboards
    ADD CONSTRAINT operations_dashboards_pkey PRIMARY KEY (id);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: portfolio_units portfolio_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.portfolio_units
    ADD CONSTRAINT portfolio_units_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products_projects products_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products_projects
    ADD CONSTRAINT products_projects_pkey PRIMARY KEY (id);


--
-- Name: project_additional_hours project_additional_hours_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_additional_hours
    ADD CONSTRAINT project_additional_hours_pkey PRIMARY KEY (id);


--
-- Name: project_broken_wip_logs project_broken_wip_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_broken_wip_logs
    ADD CONSTRAINT project_broken_wip_logs_pkey PRIMARY KEY (id);


--
-- Name: project_change_deadline_histories project_change_deadline_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_change_deadline_histories
    ADD CONSTRAINT project_change_deadline_histories_pkey PRIMARY KEY (id);


--
-- Name: project_consolidations project_consolidations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_consolidations
    ADD CONSTRAINT project_consolidations_pkey PRIMARY KEY (id);


--
-- Name: project_risk_alerts project_risk_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_risk_alerts
    ADD CONSTRAINT project_risk_alerts_pkey PRIMARY KEY (id);


--
-- Name: project_risk_configs project_risk_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_risk_configs
    ADD CONSTRAINT project_risk_configs_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: replenishing_consolidations replenishing_consolidations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.replenishing_consolidations
    ADD CONSTRAINT replenishing_consolidations_pkey PRIMARY KEY (id);


--
-- Name: risk_review_action_items risk_review_action_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_review_action_items
    ADD CONSTRAINT risk_review_action_items_pkey PRIMARY KEY (id);


--
-- Name: risk_reviews risk_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_reviews
    ADD CONSTRAINT risk_reviews_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: score_matrices score_matrices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrices
    ADD CONSTRAINT score_matrices_pkey PRIMARY KEY (id);


--
-- Name: score_matrix_answers score_matrix_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrix_answers
    ADD CONSTRAINT score_matrix_answers_pkey PRIMARY KEY (id);


--
-- Name: score_matrix_questions score_matrix_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrix_questions
    ADD CONSTRAINT score_matrix_questions_pkey PRIMARY KEY (id);


--
-- Name: service_delivery_review_action_items service_delivery_review_action_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_delivery_review_action_items
    ADD CONSTRAINT service_delivery_review_action_items_pkey PRIMARY KEY (id);


--
-- Name: service_delivery_reviews service_delivery_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_delivery_reviews
    ADD CONSTRAINT service_delivery_reviews_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: slack_configurations slack_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations
    ADD CONSTRAINT slack_configurations_pkey PRIMARY KEY (id);


--
-- Name: stage_project_configs stage_project_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stage_project_configs
    ADD CONSTRAINT stage_project_configs_pkey PRIMARY KEY (id);


--
-- Name: stages stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages
    ADD CONSTRAINT stages_pkey PRIMARY KEY (id);


--
-- Name: stages_teams stages_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages_teams
    ADD CONSTRAINT stages_teams_pkey PRIMARY KEY (id);


--
-- Name: team_consolidations team_consolidations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_consolidations
    ADD CONSTRAINT team_consolidations_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: team_resource_allocations team_resource_allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_resource_allocations
    ADD CONSTRAINT team_resource_allocations_pkey PRIMARY KEY (id);


--
-- Name: team_resources team_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_resources
    ADD CONSTRAINT team_resources_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: user_company_roles user_company_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_company_roles
    ADD CONSTRAINT user_company_roles_pkey PRIMARY KEY (id);


--
-- Name: user_invites user_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_invites
    ADD CONSTRAINT user_invites_pkey PRIMARY KEY (id);


--
-- Name: user_plans user_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_plans
    ADD CONSTRAINT user_plans_pkey PRIMARY KEY (id);


--
-- Name: user_project_roles user_project_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_project_roles
    ADD CONSTRAINT user_project_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: work_item_types work_item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_item_types
    ADD CONSTRAINT work_item_types_pkey PRIMARY KEY (id);


--
-- Name: event_invocation_logs_event_id_idx; Type: INDEX; Schema: hdb_catalog; Owner: -
--

CREATE INDEX event_invocation_logs_event_id_idx ON hdb_catalog.event_invocation_logs USING btree (event_id);


--
-- Name: event_log_created_at_idx; Type: INDEX; Schema: hdb_catalog; Owner: -
--

CREATE INDEX event_log_created_at_idx ON hdb_catalog.event_log USING btree (created_at);


--
-- Name: event_log_delivered_idx; Type: INDEX; Schema: hdb_catalog; Owner: -
--

CREATE INDEX event_log_delivered_idx ON hdb_catalog.event_log USING btree (delivered);


--
-- Name: event_log_locked_idx; Type: INDEX; Schema: hdb_catalog; Owner: -
--

CREATE INDEX event_log_locked_idx ON hdb_catalog.event_log USING btree (locked);


--
-- Name: event_log_trigger_name_idx; Type: INDEX; Schema: hdb_catalog; Owner: -
--

CREATE INDEX event_log_trigger_name_idx ON hdb_catalog.event_log USING btree (trigger_name);


--
-- Name: hdb_schema_update_event_one_row; Type: INDEX; Schema: hdb_catalog; Owner: -
--

CREATE UNIQUE INDEX hdb_schema_update_event_one_row ON hdb_catalog.hdb_schema_update_event USING btree (((occurred_at IS NOT NULL)));


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: -
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: cos_history_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cos_history_unique ON public.class_of_service_change_histories USING btree (demand_id, change_date);


--
-- Name: customer_consolidation_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX customer_consolidation_unique ON public.customer_consolidations USING btree (customer_id, consolidation_date);


--
-- Name: idx_contract_consolidation_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_contract_consolidation_unique ON public.contract_consolidations USING btree (contract_id, consolidation_date);


--
-- Name: idx_customers_devise_customer_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_customers_devise_customer_unique ON public.customers_devise_customers USING btree (customer_id, devise_customer_id);


--
-- Name: idx_demand_efforts_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_demand_efforts_unique ON public.demand_efforts USING btree (item_assignment_id, demand_transition_id, start_time_to_computation);


--
-- Name: idx_demand_score_answers_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_demand_score_answers_unique ON public.score_matrix_answers USING btree (answer_value, score_matrix_question_id);


--
-- Name: idx_on_demand_id_membership_id_start_time_573dd337cc; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_demand_id_membership_id_start_time_573dd337cc ON public.item_assignments USING btree (demand_id, membership_id, start_time);


--
-- Name: idx_on_item_assignment_id_demand_transition_id_star_ae07e90298; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_item_assignment_id_demand_transition_id_star_ae07e90298 ON public.demand_efforts USING btree (item_assignment_id, demand_transition_id, start_time_to_computation);


--
-- Name: idx_portfolio_unit_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_portfolio_unit_name ON public.portfolio_units USING btree (name, product_id, parent_id);


--
-- Name: idx_replenishing_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_replenishing_unique ON public.replenishing_consolidations USING btree (project_id, consolidation_date);


--
-- Name: idx_transitions_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_transitions_unique ON public.demand_transitions USING btree (demand_id, stage_id, last_time_in);


--
-- Name: index_class_of_service_change_histories_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_class_of_service_change_histories_on_demand_id ON public.class_of_service_change_histories USING btree (demand_id);


--
-- Name: index_companies_on_abbreviation; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_abbreviation ON public.companies USING btree (abbreviation);


--
-- Name: index_companies_on_api_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_api_token ON public.companies USING btree (api_token);


--
-- Name: index_companies_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_slug ON public.companies USING btree (slug);


--
-- Name: index_company_settings_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_company_settings_on_company_id ON public.company_settings USING btree (company_id);


--
-- Name: index_contract_consolidations_on_consolidation_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contract_consolidations_on_consolidation_date ON public.contract_consolidations USING btree (consolidation_date);


--
-- Name: index_contract_consolidations_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contract_consolidations_on_contract_id ON public.contract_consolidations USING btree (contract_id);


--
-- Name: index_contracts_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contract_id ON public.contracts USING btree (contract_id);


--
-- Name: index_contracts_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_customer_id ON public.contracts USING btree (customer_id);


--
-- Name: index_contracts_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_product_id ON public.contracts USING btree (product_id);


--
-- Name: index_customer_consolidations_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customer_consolidations_on_customer_id ON public.customer_consolidations USING btree (customer_id);


--
-- Name: index_customer_consolidations_on_last_data_in_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customer_consolidations_on_last_data_in_month ON public.customer_consolidations USING btree (last_data_in_month);


--
-- Name: index_customer_consolidations_on_last_data_in_week; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customer_consolidations_on_last_data_in_week ON public.customer_consolidations USING btree (last_data_in_week);


--
-- Name: index_customer_consolidations_on_last_data_in_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customer_consolidations_on_last_data_in_year ON public.customer_consolidations USING btree (last_data_in_year);


--
-- Name: index_customers_devise_customers_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_devise_customers_on_customer_id ON public.customers_devise_customers USING btree (customer_id);


--
-- Name: index_customers_devise_customers_on_devise_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_devise_customers_on_devise_customer_id ON public.customers_devise_customers USING btree (devise_customer_id);


--
-- Name: index_customers_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_on_company_id ON public.customers USING btree (company_id);


--
-- Name: index_customers_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_customers_on_company_id_and_name ON public.customers USING btree (company_id, name);


--
-- Name: index_customers_projects_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_projects_on_customer_id ON public.customers_projects USING btree (customer_id);


--
-- Name: index_customers_projects_on_customer_id_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_customers_projects_on_customer_id_and_project_id ON public.customers_projects USING btree (customer_id, project_id);


--
-- Name: index_customers_projects_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_projects_on_project_id ON public.customers_projects USING btree (project_id);


--
-- Name: index_demand_block_notifications_on_block_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_block_notifications_on_block_state ON public.demand_block_notifications USING btree (block_state);


--
-- Name: index_demand_block_notifications_on_demand_block_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_block_notifications_on_demand_block_id ON public.demand_block_notifications USING btree (demand_block_id);


--
-- Name: index_demand_blocks_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_blocks_on_demand_id ON public.demand_blocks USING btree (demand_id);


--
-- Name: index_demand_comments_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_comments_on_demand_id ON public.demand_comments USING btree (demand_id);


--
-- Name: index_demand_efforts_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_efforts_on_demand_id ON public.demand_efforts USING btree (demand_id);


--
-- Name: index_demand_efforts_on_demand_transition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_efforts_on_demand_transition_id ON public.demand_efforts USING btree (demand_transition_id);


--
-- Name: index_demand_efforts_on_item_assignment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_efforts_on_item_assignment_id ON public.demand_efforts USING btree (item_assignment_id);


--
-- Name: index_demand_score_matrices_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_score_matrices_on_demand_id ON public.demand_score_matrices USING btree (demand_id);


--
-- Name: index_demand_score_matrices_on_score_matrix_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_score_matrices_on_score_matrix_answer_id ON public.demand_score_matrices USING btree (score_matrix_answer_id);


--
-- Name: index_demand_score_matrices_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_score_matrices_on_user_id ON public.demand_score_matrices USING btree (user_id);


--
-- Name: index_demand_transitions_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_transitions_on_demand_id ON public.demand_transitions USING btree (demand_id);


--
-- Name: index_demand_transitions_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_transitions_on_discarded_at ON public.demand_transitions USING btree (discarded_at);


--
-- Name: index_demand_transitions_on_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_transitions_on_stage_id ON public.demand_transitions USING btree (stage_id);


--
-- Name: index_demand_transitions_on_team_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_transitions_on_team_member_id ON public.demand_transitions USING btree (team_member_id);


--
-- Name: index_demand_transitions_on_transition_notified; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_transitions_on_transition_notified ON public.demand_transitions USING btree (transition_notified);


--
-- Name: index_demands_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demands_on_contract_id ON public.demands USING btree (contract_id);


--
-- Name: index_demands_on_current_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demands_on_current_stage_id ON public.demands USING btree (current_stage_id);


--
-- Name: index_demands_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demands_on_discarded_at ON public.demands USING btree (discarded_at);


--
-- Name: index_demands_on_external_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_demands_on_external_id_and_company_id ON public.demands USING btree (external_id, company_id);


--
-- Name: index_demands_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_demands_on_slug ON public.demands USING btree (slug);


--
-- Name: index_demands_on_work_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demands_on_work_item_type_id ON public.demands USING btree (work_item_type_id);


--
-- Name: index_devise_customers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_devise_customers_on_email ON public.devise_customers USING btree (email);


--
-- Name: index_devise_customers_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_devise_customers_on_reset_password_token ON public.devise_customers USING btree (reset_password_token);


--
-- Name: index_financial_informations_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_informations_on_company_id ON public.financial_informations USING btree (company_id);


--
-- Name: index_flow_events_on_event_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_events_on_event_size ON public.flow_events USING btree (event_size);


--
-- Name: index_flow_events_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_events_on_event_type ON public.flow_events USING btree (event_type);


--
-- Name: index_flow_events_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_events_on_project_id ON public.flow_events USING btree (project_id);


--
-- Name: index_flow_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_events_on_user_id ON public.flow_events USING btree (user_id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_type_and_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type_and_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_type, sluggable_id);


--
-- Name: index_integration_errors_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_integration_errors_on_company_id ON public.integration_errors USING btree (company_id);


--
-- Name: index_integration_errors_on_integration_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_integration_errors_on_integration_type ON public.integration_errors USING btree (integration_type);


--
-- Name: index_item_assignments_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_assignments_on_demand_id ON public.item_assignments USING btree (demand_id);


--
-- Name: index_item_assignments_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_assignments_on_membership_id ON public.item_assignments USING btree (membership_id);


--
-- Name: index_jira_accounts_on_base_uri; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jira_accounts_on_base_uri ON public.jira_accounts USING btree (base_uri);


--
-- Name: index_jira_accounts_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jira_accounts_on_company_id ON public.jira_accounts USING btree (company_id);


--
-- Name: index_jira_accounts_on_customer_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jira_accounts_on_customer_domain ON public.jira_accounts USING btree (customer_domain);


--
-- Name: index_jira_api_errors_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jira_api_errors_on_demand_id ON public.jira_api_errors USING btree (demand_id);


--
-- Name: index_jira_custom_field_mappings_on_jira_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jira_custom_field_mappings_on_jira_account_id ON public.jira_custom_field_mappings USING btree (jira_account_id);


--
-- Name: index_jira_portfolio_unit_configs_on_portfolio_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jira_portfolio_unit_configs_on_portfolio_unit_id ON public.jira_portfolio_unit_configs USING btree (portfolio_unit_id);


--
-- Name: index_jira_product_configs_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jira_product_configs_on_company_id ON public.jira_product_configs USING btree (company_id);


--
-- Name: index_jira_product_configs_on_company_id_and_jira_product_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jira_product_configs_on_company_id_and_jira_product_key ON public.jira_product_configs USING btree (company_id, jira_product_key);


--
-- Name: index_jira_product_configs_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jira_product_configs_on_product_id ON public.jira_product_configs USING btree (product_id);


--
-- Name: index_jira_project_configs_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jira_project_configs_on_project_id ON public.jira_project_configs USING btree (project_id);


--
-- Name: index_membership_available_hours_histories_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_membership_available_hours_histories_on_membership_id ON public.membership_available_hours_histories USING btree (membership_id);


--
-- Name: index_memberships_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_team_id ON public.memberships USING btree (team_id);


--
-- Name: index_memberships_on_team_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_team_member_id ON public.memberships USING btree (team_member_id);


--
-- Name: index_operations_dashboard_pairings_on_operations_dashboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_operations_dashboard_pairings_on_operations_dashboard_id ON public.operations_dashboard_pairings USING btree (operations_dashboard_id);


--
-- Name: index_operations_dashboard_pairings_on_pair_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_operations_dashboard_pairings_on_pair_id ON public.operations_dashboard_pairings USING btree (pair_id);


--
-- Name: index_operations_dashboards_on_team_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_operations_dashboards_on_team_member_id ON public.operations_dashboards USING btree (team_member_id);


--
-- Name: index_portfolio_units_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_portfolio_units_on_external_id ON public.portfolio_units USING btree (external_id);


--
-- Name: index_portfolio_units_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_portfolio_units_on_name ON public.portfolio_units USING btree (name);


--
-- Name: index_portfolio_units_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_portfolio_units_on_parent_id ON public.portfolio_units USING btree (parent_id);


--
-- Name: index_portfolio_units_on_portfolio_unit_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_portfolio_units_on_portfolio_unit_type ON public.portfolio_units USING btree (portfolio_unit_type);


--
-- Name: index_portfolio_units_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_portfolio_units_on_product_id ON public.portfolio_units USING btree (product_id);


--
-- Name: index_products_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_company_id ON public.products USING btree (company_id);


--
-- Name: index_products_on_company_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_products_on_company_id_and_slug ON public.products USING btree (company_id, slug);


--
-- Name: index_products_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_customer_id ON public.products USING btree (customer_id);


--
-- Name: index_products_on_customer_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_products_on_customer_id_and_name ON public.products USING btree (customer_id, name);


--
-- Name: index_products_projects_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_projects_on_product_id ON public.products_projects USING btree (product_id);


--
-- Name: index_products_projects_on_product_id_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_products_projects_on_product_id_and_project_id ON public.products_projects USING btree (product_id, project_id);


--
-- Name: index_products_projects_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_projects_on_project_id ON public.products_projects USING btree (project_id);


--
-- Name: index_project_additional_hours_on_event_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_additional_hours_on_event_date ON public.project_additional_hours USING btree (event_date);


--
-- Name: index_project_additional_hours_on_hours_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_additional_hours_on_hours_type ON public.project_additional_hours USING btree (hours_type);


--
-- Name: index_project_additional_hours_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_additional_hours_on_project_id ON public.project_additional_hours USING btree (project_id);


--
-- Name: index_project_broken_wip_logs_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_broken_wip_logs_on_project_id ON public.project_broken_wip_logs USING btree (project_id);


--
-- Name: index_project_change_deadline_histories_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_change_deadline_histories_on_project_id ON public.project_change_deadline_histories USING btree (project_id);


--
-- Name: index_project_change_deadline_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_change_deadline_histories_on_user_id ON public.project_change_deadline_histories USING btree (user_id);


--
-- Name: index_project_risk_alerts_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_risk_alerts_on_project_id ON public.project_risk_alerts USING btree (project_id);


--
-- Name: index_project_risk_alerts_on_project_risk_config_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_risk_alerts_on_project_risk_config_id ON public.project_risk_alerts USING btree (project_risk_config_id);


--
-- Name: index_projects_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_company_id_and_name ON public.projects USING btree (company_id, name);


--
-- Name: index_replenishing_consolidations_on_consolidation_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_replenishing_consolidations_on_consolidation_date ON public.replenishing_consolidations USING btree (consolidation_date);


--
-- Name: index_replenishing_consolidations_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_replenishing_consolidations_on_project_id ON public.replenishing_consolidations USING btree (project_id);


--
-- Name: index_risk_review_action_items_on_action_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_risk_review_action_items_on_action_type ON public.risk_review_action_items USING btree (action_type);


--
-- Name: index_risk_review_action_items_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_risk_review_action_items_on_membership_id ON public.risk_review_action_items USING btree (membership_id);


--
-- Name: index_risk_review_action_items_on_risk_review_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_risk_review_action_items_on_risk_review_id ON public.risk_review_action_items USING btree (risk_review_id);


--
-- Name: index_risk_reviews_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_risk_reviews_on_company_id ON public.risk_reviews USING btree (company_id);


--
-- Name: index_risk_reviews_on_meeting_date_and_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_risk_reviews_on_meeting_date_and_product_id ON public.risk_reviews USING btree (meeting_date, product_id);


--
-- Name: index_risk_reviews_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_risk_reviews_on_product_id ON public.risk_reviews USING btree (product_id);


--
-- Name: index_score_matrices_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_score_matrices_on_product_id ON public.score_matrices USING btree (product_id);


--
-- Name: index_score_matrix_answers_on_score_matrix_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_score_matrix_answers_on_score_matrix_question_id ON public.score_matrix_answers USING btree (score_matrix_question_id);


--
-- Name: index_score_matrix_questions_on_score_matrix_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_score_matrix_questions_on_score_matrix_id ON public.score_matrix_questions USING btree (score_matrix_id);


--
-- Name: index_service_delivery_review_action_items_on_action_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_delivery_review_action_items_on_action_type ON public.service_delivery_review_action_items USING btree (action_type);


--
-- Name: index_service_delivery_review_action_items_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_delivery_review_action_items_on_membership_id ON public.service_delivery_review_action_items USING btree (membership_id);


--
-- Name: index_service_delivery_reviews_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_delivery_reviews_on_company_id ON public.service_delivery_reviews USING btree (company_id);


--
-- Name: index_service_delivery_reviews_on_meeting_date_and_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_service_delivery_reviews_on_meeting_date_and_product_id ON public.service_delivery_reviews USING btree (meeting_date, product_id);


--
-- Name: index_service_delivery_reviews_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_delivery_reviews_on_product_id ON public.service_delivery_reviews USING btree (product_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_slack_configurations_on_config_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slack_configurations_on_config_type ON public.slack_configurations USING btree (config_type);


--
-- Name: index_slack_configurations_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slack_configurations_on_customer_id ON public.slack_configurations USING btree (customer_id);


--
-- Name: index_slack_configurations_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slack_configurations_on_team_id ON public.slack_configurations USING btree (team_id);


--
-- Name: index_stage_project_configs_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stage_project_configs_on_project_id ON public.stage_project_configs USING btree (project_id);


--
-- Name: index_stage_project_configs_on_project_id_and_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stage_project_configs_on_project_id_and_stage_id ON public.stage_project_configs USING btree (project_id, stage_id);


--
-- Name: index_stage_project_configs_on_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stage_project_configs_on_stage_id ON public.stage_project_configs USING btree (stage_id);


--
-- Name: index_stages_on_integration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stages_on_integration_id ON public.stages USING btree (integration_id);


--
-- Name: index_stages_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stages_on_name ON public.stages USING btree (name);


--
-- Name: index_stages_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stages_on_parent_id ON public.stages USING btree (parent_id);


--
-- Name: index_stages_on_stage_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stages_on_stage_level ON public.stages USING btree (stage_level);


--
-- Name: index_stages_teams_on_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stages_teams_on_stage_id ON public.stages_teams USING btree (stage_id);


--
-- Name: index_stages_teams_on_stage_id_and_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stages_teams_on_stage_id_and_team_id ON public.stages_teams USING btree (stage_id, team_id);


--
-- Name: index_stages_teams_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stages_teams_on_team_id ON public.stages_teams USING btree (team_id);


--
-- Name: index_team_consolidations_on_last_data_in_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_consolidations_on_last_data_in_month ON public.team_consolidations USING btree (last_data_in_month);


--
-- Name: index_team_consolidations_on_last_data_in_week; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_consolidations_on_last_data_in_week ON public.team_consolidations USING btree (last_data_in_week);


--
-- Name: index_team_consolidations_on_last_data_in_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_consolidations_on_last_data_in_year ON public.team_consolidations USING btree (last_data_in_year);


--
-- Name: index_team_consolidations_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_consolidations_on_team_id ON public.team_consolidations USING btree (team_id);


--
-- Name: index_team_members_on_company_id_and_name_and_jira_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_team_members_on_company_id_and_name_and_jira_account_id ON public.team_members USING btree (company_id, name, jira_account_id);


--
-- Name: index_team_resource_allocations_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_resource_allocations_on_team_id ON public.team_resource_allocations USING btree (team_id);


--
-- Name: index_team_resource_allocations_on_team_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_resource_allocations_on_team_resource_id ON public.team_resource_allocations USING btree (team_resource_id);


--
-- Name: index_team_resources_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_resources_on_company_id ON public.team_resources USING btree (company_id);


--
-- Name: index_team_resources_on_resource_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_resources_on_resource_name ON public.team_resources USING btree (resource_name);


--
-- Name: index_team_resources_on_resource_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_resources_on_resource_type ON public.team_resources USING btree (resource_type);


--
-- Name: index_teams_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_company_id ON public.teams USING btree (company_id);


--
-- Name: index_teams_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_company_id_and_name ON public.teams USING btree (company_id, name);


--
-- Name: index_user_company_roles_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_company_roles_on_company_id ON public.user_company_roles USING btree (company_id);


--
-- Name: index_user_company_roles_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_company_roles_on_id ON public.user_company_roles USING btree (id);


--
-- Name: index_user_company_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_company_roles_on_user_id ON public.user_company_roles USING btree (user_id);


--
-- Name: index_user_company_roles_on_user_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_company_roles_on_user_id_and_company_id ON public.user_company_roles USING btree (user_id, company_id);


--
-- Name: index_user_company_roles_on_user_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_company_roles_on_user_role ON public.user_company_roles USING btree (user_role);


--
-- Name: index_user_invites_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_invites_on_company_id ON public.user_invites USING btree (company_id);


--
-- Name: index_user_invites_on_invite_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_invites_on_invite_email ON public.user_invites USING btree (invite_email);


--
-- Name: index_user_invites_on_invite_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_invites_on_invite_object_id ON public.user_invites USING btree (invite_object_id);


--
-- Name: index_user_invites_on_invite_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_invites_on_invite_status ON public.user_invites USING btree (invite_status);


--
-- Name: index_user_invites_on_invite_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_invites_on_invite_type ON public.user_invites USING btree (invite_type);


--
-- Name: index_user_plans_on_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_plans_on_plan_id ON public.user_plans USING btree (plan_id);


--
-- Name: index_user_plans_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_plans_on_user_id ON public.user_plans USING btree (user_id);


--
-- Name: index_user_project_roles_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_project_roles_on_project_id ON public.user_project_roles USING btree (project_id);


--
-- Name: index_user_project_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_project_roles_on_user_id ON public.user_project_roles USING btree (user_id);


--
-- Name: index_user_project_roles_on_user_id_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_project_roles_on_user_id_and_project_id ON public.user_project_roles USING btree (user_id, project_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_work_item_types_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_item_types_on_company_id ON public.work_item_types USING btree (company_id);


--
-- Name: index_work_item_types_on_company_id_and_item_level_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_work_item_types_on_company_id_and_item_level_and_name ON public.work_item_types USING btree (company_id, item_level, name);


--
-- Name: index_work_item_types_on_item_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_item_types_on_item_level ON public.work_item_types USING btree (item_level);


--
-- Name: index_work_item_types_on_quality_indicator_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_item_types_on_quality_indicator_type ON public.work_item_types USING btree (quality_indicator_type);


--
-- Name: operations_dashboard_cache_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX operations_dashboard_cache_unique ON public.operations_dashboards USING btree (team_member_id, dashboard_date);


--
-- Name: operations_dashboard_pairings_cache_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX operations_dashboard_pairings_cache_unique ON public.operations_dashboard_pairings USING btree (operations_dashboard_id, pair_id);


--
-- Name: service_delivery_review_action_items_sdr_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX service_delivery_review_action_items_sdr_id ON public.service_delivery_review_action_items USING btree (service_delivery_review_id);


--
-- Name: slack_configuration_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX slack_configuration_unique ON public.slack_configurations USING btree (info_type, team_id, room_webhook);


--
-- Name: team_consolidation_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_consolidation_unique ON public.team_consolidations USING btree (team_id, consolidation_date);


--
-- Name: unique_custom_field_to_jira_account; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_custom_field_to_jira_account ON public.jira_custom_field_mappings USING btree (jira_account_id, custom_field_type);


--
-- Name: unique_fix_version_to_jira_product; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_fix_version_to_jira_product ON public.jira_project_configs USING btree (jira_product_config_id, fix_version_name);


--
-- Name: hdb_schema_update_event hdb_schema_update_event_notifier; Type: TRIGGER; Schema: hdb_catalog; Owner: -
--

CREATE TRIGGER hdb_schema_update_event_notifier AFTER INSERT OR UPDATE ON hdb_catalog.hdb_schema_update_event FOR EACH ROW EXECUTE FUNCTION hdb_catalog.hdb_schema_update_event_notifier();


--
-- Name: event_invocation_logs event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.event_log(id);


--
-- Name: event_triggers event_triggers_schema_name_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_schema_name_fkey FOREIGN KEY (schema_name, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;


--
-- Name: hdb_action_permission hdb_action_permission_action_name_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_action_permission
    ADD CONSTRAINT hdb_action_permission_action_name_fkey FOREIGN KEY (action_name) REFERENCES hdb_catalog.hdb_action(action_name) ON UPDATE CASCADE;


--
-- Name: hdb_allowlist hdb_allowlist_collection_name_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_allowlist
    ADD CONSTRAINT hdb_allowlist_collection_name_fkey FOREIGN KEY (collection_name) REFERENCES hdb_catalog.hdb_query_collection(collection_name);


--
-- Name: hdb_computed_field hdb_computed_field_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_computed_field
    ADD CONSTRAINT hdb_computed_field_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;


--
-- Name: hdb_permission hdb_permission_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;


--
-- Name: hdb_relationship hdb_relationship_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: -
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;


--
-- Name: jira_project_configs fk_rails_039cb02c5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_project_configs
    ADD CONSTRAINT fk_rails_039cb02c5a FOREIGN KEY (jira_product_config_id) REFERENCES public.jira_product_configs(id);


--
-- Name: score_matrix_answers fk_rails_0429e0abf2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrix_answers
    ADD CONSTRAINT fk_rails_0429e0abf2 FOREIGN KEY (score_matrix_question_id) REFERENCES public.score_matrix_questions(id);


--
-- Name: demands fk_rails_095fb2481e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_095fb2481e FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: project_consolidations fk_rails_09ca62cd76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_consolidations
    ADD CONSTRAINT fk_rails_09ca62cd76 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: item_assignments fk_rails_0af34c141e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_assignments
    ADD CONSTRAINT fk_rails_0af34c141e FOREIGN KEY (demand_id) REFERENCES public.demands(id);


--
-- Name: demand_blocks fk_rails_0c8fa8d3a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks
    ADD CONSTRAINT fk_rails_0c8fa8d3a7 FOREIGN KEY (demand_id) REFERENCES public.demands(id);


--
-- Name: risk_reviews fk_rails_0e13c6d551; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_reviews
    ADD CONSTRAINT fk_rails_0e13c6d551 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: team_resources fk_rails_0e82f4e026; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_resources
    ADD CONSTRAINT fk_rails_0e82f4e026 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: portfolio_units fk_rails_111d0b277b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.portfolio_units
    ADD CONSTRAINT fk_rails_111d0b277b FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: memberships fk_rails_1138510838; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_1138510838 FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);


--
-- Name: demand_score_matrices fk_rails_11c172ae9a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_score_matrices
    ADD CONSTRAINT fk_rails_11c172ae9a FOREIGN KEY (score_matrix_answer_id) REFERENCES public.score_matrix_answers(id);


--
-- Name: demand_blocks fk_rails_11fee31fef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks
    ADD CONSTRAINT fk_rails_11fee31fef FOREIGN KEY (blocker_id) REFERENCES public.team_members(id);


--
-- Name: demand_efforts fk_rails_13a84decd9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_efforts
    ADD CONSTRAINT fk_rails_13a84decd9 FOREIGN KEY (demand_transition_id) REFERENCES public.demand_transitions(id);


--
-- Name: products_projects fk_rails_170b9c6651; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products_projects
    ADD CONSTRAINT fk_rails_170b9c6651 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: demand_blocks fk_rails_196a395613; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks
    ADD CONSTRAINT fk_rails_196a395613 FOREIGN KEY (unblocker_id) REFERENCES public.team_members(id);


--
-- Name: demands fk_rails_19bdd8aa1e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_19bdd8aa1e FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: risk_review_action_items fk_rails_1c155aea3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_review_action_items
    ADD CONSTRAINT fk_rails_1c155aea3e FOREIGN KEY (risk_review_id) REFERENCES public.risk_reviews(id);


--
-- Name: jira_custom_field_mappings fk_rails_1c34addc50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_custom_field_mappings
    ADD CONSTRAINT fk_rails_1c34addc50 FOREIGN KEY (jira_account_id) REFERENCES public.jira_accounts(id);


--
-- Name: project_change_deadline_histories fk_rails_1f60eef53a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_change_deadline_histories
    ADD CONSTRAINT fk_rails_1f60eef53a FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: products fk_rails_252452a41b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_rails_252452a41b FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: user_company_roles fk_rails_27539b2fc9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_company_roles
    ADD CONSTRAINT fk_rails_27539b2fc9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: replenishing_consolidations fk_rails_278fac0d87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.replenishing_consolidations
    ADD CONSTRAINT fk_rails_278fac0d87 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: slack_configurations fk_rails_27c3678ff8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations
    ADD CONSTRAINT fk_rails_27c3678ff8 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: demand_transitions fk_rails_2a5bc4c3f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_transitions
    ADD CONSTRAINT fk_rails_2a5bc4c3f8 FOREIGN KEY (demand_id) REFERENCES public.demands(id);


--
-- Name: portfolio_units fk_rails_2af43d471c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.portfolio_units
    ADD CONSTRAINT fk_rails_2af43d471c FOREIGN KEY (parent_id) REFERENCES public.portfolio_units(id);


--
-- Name: service_delivery_reviews fk_rails_2ee3d597b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_delivery_reviews
    ADD CONSTRAINT fk_rails_2ee3d597b3 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: customer_consolidations fk_rails_34ed62881e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_consolidations
    ADD CONSTRAINT fk_rails_34ed62881e FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: demands fk_rails_34f0dad22e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_34f0dad22e FOREIGN KEY (risk_review_id) REFERENCES public.risk_reviews(id);


--
-- Name: integration_errors fk_rails_3505c123da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_errors
    ADD CONSTRAINT fk_rails_3505c123da FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: demands fk_rails_35680c72ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_35680c72ae FOREIGN KEY (current_stage_id) REFERENCES public.stages(id);


--
-- Name: jira_portfolio_unit_configs fk_rails_36a483c30d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_portfolio_unit_configs
    ADD CONSTRAINT fk_rails_36a483c30d FOREIGN KEY (portfolio_unit_id) REFERENCES public.portfolio_units(id);


--
-- Name: demand_block_notifications fk_rails_37865053c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_block_notifications
    ADD CONSTRAINT fk_rails_37865053c5 FOREIGN KEY (demand_block_id) REFERENCES public.demand_blocks(id);


--
-- Name: score_matrix_questions fk_rails_383aa02a04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrix_questions
    ADD CONSTRAINT fk_rails_383aa02a04 FOREIGN KEY (score_matrix_id) REFERENCES public.score_matrices(id);


--
-- Name: demand_efforts fk_rails_3a63adbf96; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_efforts
    ADD CONSTRAINT fk_rails_3a63adbf96 FOREIGN KEY (demand_id) REFERENCES public.demands(id);


--
-- Name: jira_product_configs fk_rails_3b969f1e33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_product_configs
    ADD CONSTRAINT fk_rails_3b969f1e33 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: operations_dashboards fk_rails_3c55d6de97; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operations_dashboards
    ADD CONSTRAINT fk_rails_3c55d6de97 FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);


--
-- Name: team_members fk_rails_3ec60e399b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_3ec60e399b FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: contract_consolidations fk_rails_3ff1f4bb7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_consolidations
    ADD CONSTRAINT fk_rails_3ff1f4bb7a FOREIGN KEY (contract_id) REFERENCES public.contracts(id);


--
-- Name: user_plans fk_rails_406c835a0f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_plans
    ADD CONSTRAINT fk_rails_406c835a0f FOREIGN KEY (plan_id) REFERENCES public.plans(id);


--
-- Name: products fk_rails_438d5b34ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_rails_438d5b34ce FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: projects fk_rails_44a549d7b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_44a549d7b3 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: project_risk_alerts fk_rails_4685dfa1bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_risk_alerts
    ADD CONSTRAINT fk_rails_4685dfa1bb FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: customers_devise_customers fk_rails_49f9a1ee28; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_devise_customers
    ADD CONSTRAINT fk_rails_49f9a1ee28 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: contracts fk_rails_4bd5aca47c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_rails_4bd5aca47c FOREIGN KEY (contract_id) REFERENCES public.contracts(id);


--
-- Name: user_project_roles fk_rails_4bed04fd76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_project_roles
    ADD CONSTRAINT fk_rails_4bed04fd76 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: customers fk_rails_4f8eb9d458; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_rails_4f8eb9d458 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: project_additional_hours fk_rails_51a0d1b6fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_additional_hours
    ADD CONSTRAINT fk_rails_51a0d1b6fa FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: slack_configurations fk_rails_52597683c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slack_configurations
    ADD CONSTRAINT fk_rails_52597683c1 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: financial_informations fk_rails_573f757bcf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_informations
    ADD CONSTRAINT fk_rails_573f757bcf FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: jira_project_configs fk_rails_5de62c9ca2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_project_configs
    ADD CONSTRAINT fk_rails_5de62c9ca2 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: team_resource_allocations fk_rails_600e78ae6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_resource_allocations
    ADD CONSTRAINT fk_rails_600e78ae6c FOREIGN KEY (team_resource_id) REFERENCES public.team_resources(id);


--
-- Name: contract_estimation_change_histories fk_rails_61bdbf3322; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_estimation_change_histories
    ADD CONSTRAINT fk_rails_61bdbf3322 FOREIGN KEY (contract_id) REFERENCES public.contracts(id);


--
-- Name: company_settings fk_rails_6434bf6768; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_settings
    ADD CONSTRAINT fk_rails_6434bf6768 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: integration_errors fk_rails_6533e9d0da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_errors
    ADD CONSTRAINT fk_rails_6533e9d0da FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: user_company_roles fk_rails_667cd952fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_company_roles
    ADD CONSTRAINT fk_rails_667cd952fb FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: item_assignments fk_rails_6ab6a3b3a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_assignments
    ADD CONSTRAINT fk_rails_6ab6a3b3a4 FOREIGN KEY (membership_id) REFERENCES public.memberships(id);


--
-- Name: user_plans fk_rails_6bb6a01b63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_plans
    ADD CONSTRAINT fk_rails_6bb6a01b63 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: demand_blocks fk_rails_6c21b271de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks
    ADD CONSTRAINT fk_rails_6c21b271de FOREIGN KEY (risk_review_id) REFERENCES public.risk_reviews(id);


--
-- Name: stage_project_configs fk_rails_713ceb31a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stage_project_configs
    ADD CONSTRAINT fk_rails_713ceb31a3 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: demand_score_matrices fk_rails_73167e8e2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_score_matrices
    ADD CONSTRAINT fk_rails_73167e8e2c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: demands fk_rails_73cc77780a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_73cc77780a FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: user_project_roles fk_rails_7402a518b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_project_roles
    ADD CONSTRAINT fk_rails_7402a518b4 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: membership_available_hours_histories fk_rails_76a71f84ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_available_hours_histories
    ADD CONSTRAINT fk_rails_76a71f84ba FOREIGN KEY (membership_id) REFERENCES public.memberships(id);


--
-- Name: project_broken_wip_logs fk_rails_79ce1654a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_broken_wip_logs
    ADD CONSTRAINT fk_rails_79ce1654a8 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_change_deadline_histories fk_rails_7e0b9bce8f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_change_deadline_histories
    ADD CONSTRAINT fk_rails_7e0b9bce8f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: flow_events fk_rails_80b183dabb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_events
    ADD CONSTRAINT fk_rails_80b183dabb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: work_item_types fk_rails_8c3c9d6119; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_item_types
    ADD CONSTRAINT fk_rails_8c3c9d6119 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: stages_teams fk_rails_8d8a97b7b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages_teams
    ADD CONSTRAINT fk_rails_8d8a97b7b3 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: users fk_rails_971bf2d9a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_971bf2d9a1 FOREIGN KEY (last_company_id) REFERENCES public.companies(id);


--
-- Name: operations_dashboards fk_rails_985b6d0e91; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operations_dashboards
    ADD CONSTRAINT fk_rails_985b6d0e91 FOREIGN KEY (first_delivery_id) REFERENCES public.demands(id);


--
-- Name: customers_projects fk_rails_9b68bbaf49; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_projects
    ADD CONSTRAINT fk_rails_9b68bbaf49 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customers_devise_customers fk_rails_9c6f3519a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_devise_customers
    ADD CONSTRAINT fk_rails_9c6f3519a8 FOREIGN KEY (devise_customer_id) REFERENCES public.devise_customers(id);


--
-- Name: team_members fk_rails_9ec2d5e75e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_9ec2d5e75e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: contracts fk_rails_a00d802491; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_rails_a00d802491 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: score_matrices fk_rails_a144912394; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.score_matrices
    ADD CONSTRAINT fk_rails_a144912394 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: stages fk_rails_a976eabc6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages
    ADD CONSTRAINT fk_rails_a976eabc6c FOREIGN KEY (parent_id) REFERENCES public.stages(id);


--
-- Name: memberships fk_rails_ae2aedcfaf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_ae2aedcfaf FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: demands fk_rails_b14b9efb68; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_b14b9efb68 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: class_of_service_change_histories fk_rails_b150af85df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.class_of_service_change_histories
    ADD CONSTRAINT fk_rails_b150af85df FOREIGN KEY (demand_id) REFERENCES public.demands(id);


--
-- Name: jira_accounts fk_rails_b16d2de302; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_accounts
    ADD CONSTRAINT fk_rails_b16d2de302 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: stage_project_configs fk_rails_b25c287b60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stage_project_configs
    ADD CONSTRAINT fk_rails_b25c287b60 FOREIGN KEY (stage_id) REFERENCES public.stages(id);


--
-- Name: user_invites fk_rails_b2aa9bf2c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_invites
    ADD CONSTRAINT fk_rails_b2aa9bf2c0 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: demand_comments fk_rails_b68ee35cab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_comments
    ADD CONSTRAINT fk_rails_b68ee35cab FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);


--
-- Name: service_delivery_review_action_items fk_rails_b7142151f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_delivery_review_action_items
    ADD CONSTRAINT fk_rails_b7142151f8 FOREIGN KEY (service_delivery_review_id) REFERENCES public.service_delivery_reviews(id);


--
-- Name: project_risk_alerts fk_rails_b8b501e2eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_risk_alerts
    ADD CONSTRAINT fk_rails_b8b501e2eb FOREIGN KEY (project_risk_config_id) REFERENCES public.project_risk_configs(id);


--
-- Name: demand_transitions fk_rails_b9c641c4b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_transitions
    ADD CONSTRAINT fk_rails_b9c641c4b5 FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);


--
-- Name: service_delivery_review_action_items fk_rails_bcb8a4f6b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_delivery_review_action_items
    ADD CONSTRAINT fk_rails_bcb8a4f6b9 FOREIGN KEY (membership_id) REFERENCES public.memberships(id);


--
-- Name: service_delivery_reviews fk_rails_bfbae75414; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_delivery_reviews
    ADD CONSTRAINT fk_rails_bfbae75414 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: jira_product_configs fk_rails_c55dd7e748; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_product_configs
    ADD CONSTRAINT fk_rails_c55dd7e748 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: demand_transitions fk_rails_c63024fc81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_transitions
    ADD CONSTRAINT fk_rails_c63024fc81 FOREIGN KEY (stage_id) REFERENCES public.stages(id);


--
-- Name: products_projects fk_rails_c648f2cd3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products_projects
    ADD CONSTRAINT fk_rails_c648f2cd3e FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: flow_events fk_rails_c718f8e04c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_events
    ADD CONSTRAINT fk_rails_c718f8e04c FOREIGN KEY (risk_review_id) REFERENCES public.risk_reviews(id);


--
-- Name: demands fk_rails_c9b5eaaa7f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_c9b5eaaa7f FOREIGN KEY (portfolio_unit_id) REFERENCES public.portfolio_units(id);


--
-- Name: stages_teams fk_rails_cb288435d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages_teams
    ADD CONSTRAINT fk_rails_cb288435d9 FOREIGN KEY (stage_id) REFERENCES public.stages(id);


--
-- Name: jira_api_errors fk_rails_cc434c098b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_api_errors
    ADD CONSTRAINT fk_rails_cc434c098b FOREIGN KEY (demand_id) REFERENCES public.demands(id);


--
-- Name: flow_events fk_rails_cda32ac094; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_events
    ADD CONSTRAINT fk_rails_cda32ac094 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: demand_efforts fk_rails_ce4f1e0c32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_efforts
    ADD CONSTRAINT fk_rails_ce4f1e0c32 FOREIGN KEY (item_assignment_id) REFERENCES public.item_assignments(id);


--
-- Name: demands fk_rails_d084bb511c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_d084bb511c FOREIGN KEY (contract_id) REFERENCES public.contracts(id);


--
-- Name: demand_blocks fk_rails_d25cb2ae7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks
    ADD CONSTRAINT fk_rails_d25cb2ae7e FOREIGN KEY (stage_id) REFERENCES public.stages(id);


--
-- Name: contracts fk_rails_d9e2e7cf99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_rails_d9e2e7cf99 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: operations_dashboard_pairings fk_rails_db85e736aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operations_dashboard_pairings
    ADD CONSTRAINT fk_rails_db85e736aa FOREIGN KEY (operations_dashboard_id) REFERENCES public.operations_dashboards(id);


--
-- Name: demand_comments fk_rails_dc14d53db5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_comments
    ADD CONSTRAINT fk_rails_dc14d53db5 FOREIGN KEY (demand_id) REFERENCES public.demands(id);


--
-- Name: risk_reviews fk_rails_dd98df4301; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_reviews
    ADD CONSTRAINT fk_rails_dd98df4301 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: teams fk_rails_e080df8a94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_rails_e080df8a94 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: team_resource_allocations fk_rails_e11bdf0f2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_resource_allocations
    ADD CONSTRAINT fk_rails_e11bdf0f2c FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: operations_dashboard_pairings fk_rails_ea51fcd7c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operations_dashboard_pairings
    ADD CONSTRAINT fk_rails_ea51fcd7c0 FOREIGN KEY (pair_id) REFERENCES public.team_members(id);


--
-- Name: demand_score_matrices fk_rails_ea77f40fb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_score_matrices
    ADD CONSTRAINT fk_rails_ea77f40fb8 FOREIGN KEY (demand_id) REFERENCES public.demands(id);


--
-- Name: projects fk_rails_ecc227a0c2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_ecc227a0c2 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: demands fk_rails_ed5f6df6d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_ed5f6df6d6 FOREIGN KEY (work_item_type_id) REFERENCES public.work_item_types(id);


--
-- Name: customers_projects fk_rails_ee14b8e6f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_projects
    ADD CONSTRAINT fk_rails_ee14b8e6f4 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: team_consolidations fk_rails_ee628d9f6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_consolidations
    ADD CONSTRAINT fk_rails_ee628d9f6b FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: customers fk_rails_ef51a916ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_rails_ef51a916ef FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: demands fk_rails_fcc44c0e5d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_fcc44c0e5d FOREIGN KEY (service_delivery_review_id) REFERENCES public.service_delivery_reviews(id);


--
-- Name: risk_review_action_items fk_rails_fdf17a6550; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_review_action_items
    ADD CONSTRAINT fk_rails_fdf17a6550 FOREIGN KEY (membership_id) REFERENCES public.memberships(id);


--
-- Name: stages fk_rails_ffd4cca0d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages
    ADD CONSTRAINT fk_rails_ffd4cca0d4 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20241127165114'),
('20241127161643'),
('20241127151940'),
('20241127142153'),
('20241112185524'),
('20240305001433'),
('20231205130509'),
('20230920134031'),
('20230919172827'),
('20230518190043'),
('20230131205424'),
('20221205155616'),
('20221130114226'),
('20220914141949'),
('20220804162133'),
('20220718213803'),
('20220718205253'),
('20220714235702'),
('20220711193708'),
('20220705145931'),
('20220622174041'),
('20220602123818'),
('20220512123859'),
('20220509115356'),
('20220503213916'),
('20220503152313'),
('20220408194012'),
('20220401124201'),
('20220311184239'),
('20220221210259'),
('20220214141346'),
('20220202200413'),
('20220131144645'),
('20220128210845'),
('20220128154551'),
('20220127194418'),
('20220125153405'),
('20220120130408'),
('20220115003017'),
('20220114200925'),
('20220113205638'),
('20220113205250'),
('20220113202204'),
('20220113160252'),
('20220113132547'),
('20211110122935'),
('20211011222247'),
('20210927200741'),
('20210927183909'),
('20210920220915'),
('20210913214858'),
('20210519163200'),
('20210518140127'),
('20210513135325'),
('20210430222819'),
('20210418214342'),
('20210107143637'),
('20210105172949'),
('20201215181752'),
('20201214235753'),
('20201209134542'),
('20201111160327'),
('20201020185804'),
('20201019125426'),
('20200929125717'),
('20200928150830'),
('20200831153123'),
('20200813131313'),
('20200812153534'),
('20200807131518'),
('20200721155315'),
('20200717214156'),
('20200716215041'),
('20200716155407'),
('20200714214845'),
('20200711165002'),
('20200707184608'),
('20200703124334'),
('20200627151758'),
('20200615173415'),
('20200601145121'),
('20200528154520'),
('20200520142236'),
('20200511192312'),
('20200507203439'),
('20200504193716'),
('20200430140032'),
('20200423211631'),
('20200423204628'),
('20200406175435'),
('20200330185149'),
('20200328160133'),
('20200130181814'),
('20200114190057'),
('20200114153736'),
('20191223134739'),
('20191028155108'),
('20191025150906'),
('20191024212617'),
('20191021222025'),
('20191015185615'),
('20191002140915'),
('20190917120310'),
('20190906135154'),
('20190905215441'),
('20190905151751'),
('20190830144220'),
('20190821145655'),
('20190816185103'),
('20190815151526'),
('20190812154723'),
('20190807202613'),
('20190806135316'),
('20190805181747'),
('20190730122201'),
('20190723195649'),
('20190719194438'),
('20190716135342'),
('20190711211958'),
('20190709144816'),
('20190708211541'),
('20190705190605'),
('20190704193534'),
('20190701194645'),
('20190701193809'),
('20190624141355'),
('20190621191628'),
('20190621150621'),
('20190614134919'),
('20190613192708'),
('20190613135818'),
('20190612195656'),
('20190611195749'),
('20190607143157'),
('20190606204533'),
('20190606144211'),
('20190603153315'),
('20190531215933'),
('20190531191855'),
('20190531184111'),
('20190527200450'),
('20190527172016'),
('20190525161036'),
('20190517141230'),
('20190507222549'),
('20190507183550'),
('20190501044600'),
('20190430215107'),
('20190430205947'),
('20190423164537'),
('20190403162125'),
('20190403153943'),
('20190402135917'),
('20190323215103'),
('20190318221048'),
('20190216181219'),
('20190215153227'),
('20190212183127'),
('20190212181729'),
('20190212180201'),
('20190212180057'),
('20190211141716'),
('20190124222658'),
('20190121231612'),
('20190108182426'),
('20181210193253'),
('20181210181733'),
('20181022220910'),
('20181008191022'),
('20180915020210'),
('20180830205543'),
('20180822231503'),
('20180820175021'),
('20180731181345'),
('20180703233113'),
('20180627232834'),
('20180620014718'),
('20180619150458'),
('20180618185639'),
('20180615182356'),
('20180604224141'),
('20180530210436'),
('20180529194024'),
('20180516150858'),
('20180514210852'),
('20180510203203'),
('20180417193029'),
('20180412202504'),
('20180411164401'),
('20180410163615'),
('20180407032019'),
('20180403230254'),
('20180331235053'),
('20180320180443'),
('20180316210405'),
('20180316131931'),
('20180315163004'),
('20180313152829'),
('20180312220710'),
('20180307203657'),
('20180306142224'),
('20180303002459'),
('20180302225234'),
('20180302152036'),
('20180224142451'),
('20180224031304'),
('20180223211920'),
('20180221160521'),
('20180216231515'),
('20180216160706'),
('20180215201832'),
('20180215151505'),
('20180213155318'),
('20180209223011'),
('20180209180125'),
('20180208112930'),
('20180207231739'),
('20180206183551'),
('20180204213721'),
('20180204121055'),
('20180203152518'),
('20180128155627'),
('20180128150500'),
('20180127180639'),
('20180126175210'),
('20180126155811'),
('20180126152312'),
('20180126021945'),
('20180123032144'),
('20180122211258'),
('20180117150255'),
('20180116235900'),
('20180116205144'),
('20180116022142'),
('20180115152551'),
('20180113231517'),
('20180112182233'),
('20180112161621'),
('20180112010152'),
('20180112010014'),
('20180112002920'),
('20180111234624'),
('20180111232828'),
('20180111180016'),
('20180111170136'),
('20180111164501');

