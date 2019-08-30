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
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_with_oids = false;

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
    api_token character varying NOT NULL
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
-- Name: companies_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies_users (
    user_id integer,
    company_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


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
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    products_count integer DEFAULT 0,
    projects_count integer DEFAULT 0
);


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
-- Name: demand_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demand_blocks (
    id bigint NOT NULL,
    demand_id integer NOT NULL,
    block_time timestamp without time zone NOT NULL,
    unblock_time timestamp without time zone,
    block_duration integer,
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
    risk_review_id integer
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
    team_member_id integer
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
-- Name: demand_data_processments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.demand_data_processments (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    project_key character varying NOT NULL,
    downloaded_content text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_plan_id integer NOT NULL
);


--
-- Name: demand_data_processments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.demand_data_processments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demand_data_processments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.demand_data_processments_id_seq OWNED BY public.demand_data_processments.id;


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
    discarded_at timestamp without time zone
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
    demand_id character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    demand_type integer NOT NULL,
    demand_url character varying,
    commitment_date timestamp without time zone,
    end_date timestamp without time zone,
    created_date timestamp without time zone NOT NULL,
    url character varying,
    class_of_service integer DEFAULT 0 NOT NULL,
    project_id integer NOT NULL,
    effort_downstream numeric DEFAULT 0,
    effort_upstream numeric DEFAULT 0,
    leadtime numeric,
    manual_effort boolean DEFAULT false,
    total_queue_time integer DEFAULT 0,
    total_touch_time integer DEFAULT 0,
    demand_title character varying,
    discarded_at timestamp without time zone,
    artifact_type integer DEFAULT 0,
    parent_id integer,
    slug character varying,
    company_id integer NOT NULL,
    portfolio_unit_id integer,
    product_id integer,
    team_id integer NOT NULL,
    cost_to_project numeric DEFAULT 0,
    blocked_working_time_downstream numeric DEFAULT 0,
    blocked_working_time_upstream numeric DEFAULT 0,
    total_bloked_working_time numeric DEFAULT 0,
    total_touch_blocked_time numeric DEFAULT 0,
    risk_review_id integer,
    business_score numeric
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
-- Name: demands_lists; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.demands_lists AS
SELECT
    NULL::bigint AS id,
    NULL::character varying AS demand_id,
    NULL::character varying AS slug,
    NULL::bigint AS project_id,
    NULL::timestamp without time zone AS created_date,
    NULL::timestamp without time zone AS commitment_date,
    NULL::timestamp without time zone AS end_date,
    NULL::character varying AS project_name,
    NULL::integer AS artifact_type,
    NULL::integer AS demand_type,
    NULL::character varying AS demand_title,
    NULL::integer AS class_of_service,
    NULL::numeric AS effort_upstream,
    NULL::numeric AS effort_downstream,
    NULL::numeric AS leadtime,
    NULL::integer AS total_queue_time,
    NULL::integer AS total_touch_time,
    NULL::character varying AS url,
    NULL::timestamp without time zone AS discarded_at,
    NULL::bigint AS blocks_count,
    NULL::double precision AS blocked_time,
    NULL::double precision AS queued_time,
    NULL::double precision AS touch_time;


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
-- Name: flow_impacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flow_impacts (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    demand_id integer,
    impact_type integer NOT NULL,
    impact_description character varying NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flow_impacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flow_impacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flow_impacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flow_impacts_id_seq OWNED BY public.flow_impacts.id;


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
    team_member_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    start_time timestamp without time zone NOT NULL,
    finish_time timestamp without time zone
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
    encrypted_api_token_iv character varying NOT NULL,
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
-- Name: jira_custom_field_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jira_custom_field_mappings (
    id bigint NOT NULL,
    jira_account_id integer NOT NULL,
    demand_field integer NOT NULL,
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
    end_date date
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
    updated_at timestamp without time zone NOT NULL
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
    customer_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    population_start_date date,
    population_end_date date,
    project_id integer NOT NULL,
    demands_ids integer[],
    demands_finished_ids integer[],
    demands_lead_times numeric[],
    wip_limit integer,
    current_wip integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_weekly_throughput integer[],
    team_weekly_throughput integer[],
    products_weekly_throughput integer[],
    project_monte_carlo_weeks integer[],
    team_monte_carlo_weeks integer[],
    products_monte_carlo_weeks integer[]
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
    max_work_in_progress integer DEFAULT 0 NOT NULL,
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
-- Name: risk_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.risk_reviews (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    product_id integer NOT NULL,
    meeting_date date NOT NULL,
    lead_time_outlier_limit numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: slack_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slack_configurations (
    id bigint NOT NULL,
    team_id integer NOT NULL,
    room_webhook character varying NOT NULL,
    notification_hour integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    info_type integer DEFAULT 0 NOT NULL,
    weekday_to_notify integer DEFAULT 0 NOT NULL,
    notification_minute integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true
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
    stage_percentage integer DEFAULT 0,
    management_percentage integer DEFAULT 0,
    pairing_percentage integer DEFAULT 0,
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
    integration_pipe_id character varying
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
    company_id integer NOT NULL
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
    avatar character varying
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
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: company_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_settings ALTER COLUMN id SET DEFAULT nextval('public.company_settings_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: customers_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_projects ALTER COLUMN id SET DEFAULT nextval('public.customers_projects_id_seq'::regclass);


--
-- Name: demand_blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks ALTER COLUMN id SET DEFAULT nextval('public.demand_blocks_id_seq'::regclass);


--
-- Name: demand_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_comments ALTER COLUMN id SET DEFAULT nextval('public.demand_comments_id_seq'::regclass);


--
-- Name: demand_data_processments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_data_processments ALTER COLUMN id SET DEFAULT nextval('public.demand_data_processments_id_seq'::regclass);


--
-- Name: demand_transitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_transitions ALTER COLUMN id SET DEFAULT nextval('public.demand_transitions_id_seq'::regclass);


--
-- Name: demands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands ALTER COLUMN id SET DEFAULT nextval('public.demands_id_seq'::regclass);


--
-- Name: financial_informations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_informations ALTER COLUMN id SET DEFAULT nextval('public.financial_informations_id_seq'::regclass);


--
-- Name: flow_impacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_impacts ALTER COLUMN id SET DEFAULT nextval('public.flow_impacts_id_seq'::regclass);


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
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


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
-- Name: risk_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risk_reviews ALTER COLUMN id SET DEFAULT nextval('public.risk_reviews_id_seq'::regclass);


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
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members ALTER COLUMN id SET DEFAULT nextval('public.team_members_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


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
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


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
-- Name: demand_data_processments demand_data_processments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_data_processments
    ADD CONSTRAINT demand_data_processments_pkey PRIMARY KEY (id);


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
-- Name: financial_informations financial_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financial_informations
    ADD CONSTRAINT financial_informations_pkey PRIMARY KEY (id);


--
-- Name: flow_impacts flow_impacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_impacts
    ADD CONSTRAINT flow_impacts_pkey PRIMARY KEY (id);


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
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


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
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


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
-- Name: demand_member_start_time_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX demand_member_start_time_unique ON public.item_assignments USING btree (demand_id, team_member_id, start_time);


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
-- Name: index_companies_users_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_company_id ON public.companies_users USING btree (company_id);


--
-- Name: index_companies_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_user_id ON public.companies_users USING btree (user_id);


--
-- Name: index_company_settings_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_company_settings_on_company_id ON public.company_settings USING btree (company_id);


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
-- Name: index_demand_blocks_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_blocks_on_demand_id ON public.demand_blocks USING btree (demand_id);


--
-- Name: index_demand_comments_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_comments_on_demand_id ON public.demand_comments USING btree (demand_id);


--
-- Name: index_demand_data_processments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demand_data_processments_on_user_id ON public.demand_data_processments USING btree (user_id);


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
-- Name: index_demands_on_demand_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_demands_on_demand_id_and_company_id ON public.demands USING btree (demand_id, company_id);


--
-- Name: index_demands_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demands_on_discarded_at ON public.demands USING btree (discarded_at);


--
-- Name: index_demands_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_demands_on_slug ON public.demands USING btree (slug);


--
-- Name: index_financial_informations_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_informations_on_company_id ON public.financial_informations USING btree (company_id);


--
-- Name: index_flow_impacts_on_demand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_impacts_on_demand_id ON public.flow_impacts USING btree (demand_id);


--
-- Name: index_flow_impacts_on_impact_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_impacts_on_impact_type ON public.flow_impacts USING btree (impact_type);


--
-- Name: index_flow_impacts_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flow_impacts_on_project_id ON public.flow_impacts USING btree (project_id);


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
-- Name: index_item_assignments_on_team_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_assignments_on_team_member_id ON public.item_assignments USING btree (team_member_id);


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
-- Name: index_memberships_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_team_id ON public.memberships USING btree (team_id);


--
-- Name: index_memberships_on_team_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_team_member_id ON public.memberships USING btree (team_member_id);


--
-- Name: index_portfolio_units_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_portfolio_units_on_name ON public.portfolio_units USING btree (name);


--
-- Name: index_portfolio_units_on_name_and_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_portfolio_units_on_name_and_product_id ON public.portfolio_units USING btree (name, product_id);


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
-- Name: index_slack_configurations_on_info_type_and_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_slack_configurations_on_info_type_and_team_id ON public.slack_configurations USING btree (info_type, team_id);


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
-- Name: index_team_members_on_company_id_and_name_and_jira_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_team_members_on_company_id_and_name_and_jira_account_id ON public.team_members USING btree (company_id, name, jira_account_id);


--
-- Name: index_teams_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_company_id ON public.teams USING btree (company_id);


--
-- Name: index_teams_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_company_id_and_name ON public.teams USING btree (company_id, name);


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
-- Name: unique_custom_field_to_jira_account; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_custom_field_to_jira_account ON public.jira_custom_field_mappings USING btree (jira_account_id, demand_field);


--
-- Name: unique_fix_version_to_jira_product; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_fix_version_to_jira_product ON public.jira_project_configs USING btree (jira_product_config_id, fix_version_name);


--
-- Name: demands_lists _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.demands_lists AS
 SELECT d.id,
    d.demand_id,
    d.slug,
    proj.id AS project_id,
    d.created_date,
    d.commitment_date,
    d.end_date,
    proj.name AS project_name,
    d.artifact_type,
    d.demand_type,
    d.demand_title,
    d.class_of_service,
    d.effort_upstream,
    d.effort_downstream,
    d.leadtime,
    d.total_queue_time,
    d.total_touch_time,
    d.url,
    d.discarded_at,
    count(DISTINCT blocks.id) AS blocks_count,
    sum(date_part('epoch'::text, (blocks.unblock_time - blocks.block_time))) AS blocked_time,
    ( SELECT sum(date_part('epoch'::text, (queued_transitions.last_time_out - queued_transitions.last_time_in))) AS sum
           FROM public.demand_transitions queued_transitions,
            public.stages s
          WHERE ((queued_transitions.demand_id = d.id) AND (s.id = queued_transitions.stage_id) AND (s.queue = true))) AS queued_time,
    ( SELECT sum(date_part('epoch'::text, (touch_transitions.last_time_out - touch_transitions.last_time_in))) AS sum
           FROM public.demand_transitions touch_transitions,
            public.stages s
          WHERE ((touch_transitions.demand_id = d.id) AND (s.id = touch_transitions.stage_id) AND (s.queue = false))) AS touch_time
   FROM ((public.demands d
     JOIN public.projects proj ON ((d.project_id = proj.id)))
     LEFT JOIN public.demand_blocks blocks ON (((blocks.demand_id = d.id) AND (blocks.unblock_time >= blocks.block_time) AND (blocks.active = true) AND (blocks.unblock_time IS NOT NULL))))
  GROUP BY d.id, proj.id;


--
-- Name: jira_project_configs fk_rails_039cb02c5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_project_configs
    ADD CONSTRAINT fk_rails_039cb02c5a FOREIGN KEY (jira_product_config_id) REFERENCES public.jira_product_configs(id);


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
-- Name: demand_blocks fk_rails_11fee31fef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks
    ADD CONSTRAINT fk_rails_11fee31fef FOREIGN KEY (blocker_id) REFERENCES public.team_members(id);


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
-- Name: demands fk_rails_1abfdc9ca0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demands
    ADD CONSTRAINT fk_rails_1abfdc9ca0 FOREIGN KEY (parent_id) REFERENCES public.demands(id);


--
-- Name: jira_custom_field_mappings fk_rails_1c34addc50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_custom_field_mappings
    ADD CONSTRAINT fk_rails_1c34addc50 FOREIGN KEY (jira_account_id) REFERENCES public.jira_accounts(id);


--
-- Name: demand_data_processments fk_rails_1e9a84a8ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_data_processments
    ADD CONSTRAINT fk_rails_1e9a84a8ab FOREIGN KEY (user_plan_id) REFERENCES public.user_plans(id);


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
-- Name: companies_users fk_rails_27539b2fc9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_users
    ADD CONSTRAINT fk_rails_27539b2fc9 FOREIGN KEY (user_id) REFERENCES public.users(id);


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
-- Name: demand_data_processments fk_rails_337e2008a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_data_processments
    ADD CONSTRAINT fk_rails_337e2008a8 FOREIGN KEY (user_id) REFERENCES public.users(id);


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
-- Name: jira_portfolio_unit_configs fk_rails_36a483c30d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_portfolio_unit_configs
    ADD CONSTRAINT fk_rails_36a483c30d FOREIGN KEY (portfolio_unit_id) REFERENCES public.portfolio_units(id);


--
-- Name: jira_product_configs fk_rails_3b969f1e33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_product_configs
    ADD CONSTRAINT fk_rails_3b969f1e33 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: team_members fk_rails_3ec60e399b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_3ec60e399b FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: user_plans fk_rails_406c835a0f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_plans
    ADD CONSTRAINT fk_rails_406c835a0f FOREIGN KEY (plan_id) REFERENCES public.plans(id);


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
-- Name: user_project_roles fk_rails_4bed04fd76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_project_roles
    ADD CONSTRAINT fk_rails_4bed04fd76 FOREIGN KEY (user_id) REFERENCES public.users(id);


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
-- Name: companies_users fk_rails_667cd952fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_users
    ADD CONSTRAINT fk_rails_667cd952fb FOREIGN KEY (company_id) REFERENCES public.companies(id);


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
-- Name: item_assignments fk_rails_78b4938f25; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_assignments
    ADD CONSTRAINT fk_rails_78b4938f25 FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);


--
-- Name: project_change_deadline_histories fk_rails_7e0b9bce8f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_change_deadline_histories
    ADD CONSTRAINT fk_rails_7e0b9bce8f FOREIGN KEY (user_id) REFERENCES public.users(id);


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
-- Name: customers_projects fk_rails_9b68bbaf49; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_projects
    ADD CONSTRAINT fk_rails_9b68bbaf49 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: memberships fk_rails_ae2aedcfaf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_ae2aedcfaf FOREIGN KEY (team_id) REFERENCES public.teams(id);


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
-- Name: demand_comments fk_rails_b68ee35cab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_comments
    ADD CONSTRAINT fk_rails_b68ee35cab FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);


--
-- Name: project_risk_alerts fk_rails_b8b501e2eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_risk_alerts
    ADD CONSTRAINT fk_rails_b8b501e2eb FOREIGN KEY (project_risk_config_id) REFERENCES public.project_risk_configs(id);


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
-- Name: flow_impacts fk_rails_cda32ac094; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_impacts
    ADD CONSTRAINT fk_rails_cda32ac094 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: demand_blocks fk_rails_d25cb2ae7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.demand_blocks
    ADD CONSTRAINT fk_rails_d25cb2ae7e FOREIGN KEY (stage_id) REFERENCES public.stages(id);


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
-- Name: projects fk_rails_ecc227a0c2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_ecc227a0c2 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: customers_projects fk_rails_ee14b8e6f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers_projects
    ADD CONSTRAINT fk_rails_ee14b8e6f4 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: customers fk_rails_ef51a916ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_rails_ef51a916ef FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: flow_impacts fk_rails_f6118b7a74; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flow_impacts
    ADD CONSTRAINT fk_rails_f6118b7a74 FOREIGN KEY (demand_id) REFERENCES public.demands(id);


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
('20180111164501'),
('20180111170136'),
('20180111180016'),
('20180111232828'),
('20180111234624'),
('20180112002920'),
('20180112010014'),
('20180112010152'),
('20180112161621'),
('20180112182233'),
('20180113231517'),
('20180115152551'),
('20180116022142'),
('20180116205144'),
('20180116235900'),
('20180117150255'),
('20180122211258'),
('20180123032144'),
('20180126021945'),
('20180126152312'),
('20180126155811'),
('20180126175210'),
('20180127180639'),
('20180128150500'),
('20180128155627'),
('20180203152518'),
('20180204121055'),
('20180204213721'),
('20180206183551'),
('20180207231739'),
('20180208112930'),
('20180209180125'),
('20180209223011'),
('20180213155318'),
('20180215151505'),
('20180215201832'),
('20180216160706'),
('20180216231515'),
('20180221160521'),
('20180223211920'),
('20180224031304'),
('20180224142451'),
('20180302152036'),
('20180302225234'),
('20180303002459'),
('20180306142224'),
('20180307203657'),
('20180312220710'),
('20180313152829'),
('20180315163004'),
('20180316131931'),
('20180316210405'),
('20180320180443'),
('20180331235053'),
('20180403230254'),
('20180407032019'),
('20180410163615'),
('20180411164401'),
('20180412202504'),
('20180417193029'),
('20180510203203'),
('20180514210852'),
('20180516150858'),
('20180529194024'),
('20180530210436'),
('20180604224141'),
('20180615182356'),
('20180618185639'),
('20180619150458'),
('20180620014718'),
('20180627232834'),
('20180703233113'),
('20180731181345'),
('20180820175021'),
('20180822231503'),
('20180830205543'),
('20180915020210'),
('20181008191022'),
('20181022220910'),
('20181210181733'),
('20181210193253'),
('20190108182426'),
('20190121231612'),
('20190124222658'),
('20190211141716'),
('20190212180057'),
('20190212180201'),
('20190212181729'),
('20190212183127'),
('20190215153227'),
('20190216181219'),
('20190318221048'),
('20190323215103'),
('20190402135917'),
('20190403153943'),
('20190403162125'),
('20190423164537'),
('20190430205947'),
('20190430215107'),
('20190501044600'),
('20190507183550'),
('20190507222549'),
('20190517141230'),
('20190525161036'),
('20190527172016'),
('20190527200450'),
('20190531184111'),
('20190531191855'),
('20190531215933'),
('20190603153315'),
('20190606144211'),
('20190606204533'),
('20190607143157'),
('20190611195749'),
('20190612195656'),
('20190613135818'),
('20190613192708'),
('20190614134919'),
('20190621150621'),
('20190621191628'),
('20190624141355'),
('20190701193809'),
('20190701194645'),
('20190704193534'),
('20190705190605'),
('20190708211541'),
('20190709144816'),
('20190711211958'),
('20190716135342'),
('20190719194438'),
('20190723195649'),
('20190730122201'),
('20190805181747'),
('20190806135316'),
('20190807202613'),
('20190812154723'),
('20190815151526'),
('20190816185103'),
('20190821145655'),
('20190830144220');


