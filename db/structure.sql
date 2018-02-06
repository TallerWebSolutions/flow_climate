SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE companies (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    abbreviation character varying NOT NULL,
    customers_count integer DEFAULT 0
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE companies_id_seq OWNED BY companies.id;


--
-- Name: companies_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE companies_users (
    user_id integer,
    company_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE customers (
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

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: demands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE demands (
    id bigint NOT NULL,
    project_result_id integer NOT NULL,
    demand_id character varying NOT NULL,
    effort numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: demands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE demands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: demands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE demands_id_seq OWNED BY demands.id;


--
-- Name: financial_informations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE financial_informations (
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

CREATE SEQUENCE financial_informations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: financial_informations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE financial_informations_id_seq OWNED BY financial_informations.id;


--
-- Name: operation_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE operation_results (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    result_date date NOT NULL,
    people_billable_count integer NOT NULL,
    operation_week_value numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    available_hours integer NOT NULL,
    delivered_hours integer NOT NULL,
    total_th integer NOT NULL,
    total_opened_bugs integer NOT NULL,
    total_accumulated_closed_bugs integer NOT NULL
);


--
-- Name: operation_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE operation_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operation_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE operation_results_id_seq OWNED BY operation_results.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE products (
    id bigint NOT NULL,
    customer_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    projects_count integer DEFAULT 0
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: project_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_results (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    result_date date NOT NULL,
    known_scope integer NOT NULL,
    qty_hours_upstream integer NOT NULL,
    qty_hours_downstream integer NOT NULL,
    throughput integer NOT NULL,
    qty_bugs_opened integer NOT NULL,
    qty_bugs_closed integer NOT NULL,
    qty_hours_bug integer NOT NULL,
    leadtime numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team_id integer NOT NULL,
    monte_carlo_date date,
    demands_count integer,
    flow_pressure numeric NOT NULL,
    remaining_days integer NOT NULL,
    cost_in_week numeric NOT NULL,
    average_demand_cost numeric NOT NULL
);


--
-- Name: project_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_results_id_seq OWNED BY project_results.id;


--
-- Name: project_risk_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_risk_alerts (
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

CREATE SEQUENCE project_risk_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_risk_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_risk_alerts_id_seq OWNED BY project_risk_alerts.id;


--
-- Name: project_risk_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_risk_configs (
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

CREATE SEQUENCE project_risk_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_risk_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_risk_configs_id_seq OWNED BY project_risk_configs.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE projects (
    id bigint NOT NULL,
    customer_id integer NOT NULL,
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
    product_id integer
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE team_members (
    id bigint NOT NULL,
    name character varying NOT NULL,
    monthly_payment numeric NOT NULL,
    hours_per_month integer NOT NULL,
    active boolean DEFAULT true,
    billable boolean DEFAULT true,
    billable_type integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team_id integer NOT NULL
);


--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE team_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE team_members_id_seq OWNED BY team_members.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE teams (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE teams_id_seq OWNED BY teams.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
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
    email_notifications boolean DEFAULT false NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies ALTER COLUMN id SET DEFAULT nextval('companies_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Name: demands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY demands ALTER COLUMN id SET DEFAULT nextval('demands_id_seq'::regclass);


--
-- Name: financial_informations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY financial_informations ALTER COLUMN id SET DEFAULT nextval('financial_informations_id_seq'::regclass);


--
-- Name: operation_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY operation_results ALTER COLUMN id SET DEFAULT nextval('operation_results_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: project_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_results ALTER COLUMN id SET DEFAULT nextval('project_results_id_seq'::regclass);


--
-- Name: project_risk_alerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_risk_alerts ALTER COLUMN id SET DEFAULT nextval('project_risk_alerts_id_seq'::regclass);


--
-- Name: project_risk_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_risk_configs ALTER COLUMN id SET DEFAULT nextval('project_risk_configs_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY team_members ALTER COLUMN id SET DEFAULT nextval('team_members_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams ALTER COLUMN id SET DEFAULT nextval('teams_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: demands demands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY demands
    ADD CONSTRAINT demands_pkey PRIMARY KEY (id);


--
-- Name: financial_informations financial_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY financial_informations
    ADD CONSTRAINT financial_informations_pkey PRIMARY KEY (id);


--
-- Name: operation_results operation_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY operation_results
    ADD CONSTRAINT operation_results_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: project_results project_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_results
    ADD CONSTRAINT project_results_pkey PRIMARY KEY (id);


--
-- Name: project_risk_alerts project_risk_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_risk_alerts
    ADD CONSTRAINT project_risk_alerts_pkey PRIMARY KEY (id);


--
-- Name: project_risk_configs project_risk_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_risk_configs
    ADD CONSTRAINT project_risk_configs_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_companies_users_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_company_id ON companies_users USING btree (company_id);


--
-- Name: index_companies_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_user_id ON companies_users USING btree (user_id);


--
-- Name: index_customers_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_on_company_id ON customers USING btree (company_id);


--
-- Name: index_customers_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_customers_on_company_id_and_name ON customers USING btree (company_id, name);


--
-- Name: index_demands_on_project_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_demands_on_project_result_id ON demands USING btree (project_result_id);


--
-- Name: index_financial_informations_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_financial_informations_on_company_id ON financial_informations USING btree (company_id);


--
-- Name: index_products_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_customer_id ON products USING btree (customer_id);


--
-- Name: index_products_on_customer_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_products_on_customer_id_and_name ON products USING btree (customer_id, name);


--
-- Name: index_project_results_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_results_on_project_id ON project_results USING btree (project_id);


--
-- Name: index_project_risk_alerts_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_risk_alerts_on_project_id ON project_risk_alerts USING btree (project_id);


--
-- Name: index_project_risk_alerts_on_project_risk_config_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_risk_alerts_on_project_risk_config_id ON project_risk_alerts USING btree (project_risk_config_id);


--
-- Name: index_projects_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_customer_id ON projects USING btree (customer_id);


--
-- Name: index_projects_on_product_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_product_id_and_name ON projects USING btree (product_id, name);


--
-- Name: index_teams_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_company_id ON teams USING btree (company_id);


--
-- Name: index_teams_on_company_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_company_id_and_name ON teams USING btree (company_id, name);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: team_members fk_rails_194b5b076d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY team_members
    ADD CONSTRAINT fk_rails_194b5b076d FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: projects fk_rails_21e11c2480; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_rails_21e11c2480 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: products fk_rails_252452a41b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT fk_rails_252452a41b FOREIGN KEY (customer_id) REFERENCES customers(id);


--
-- Name: companies_users fk_rails_27539b2fc9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies_users
    ADD CONSTRAINT fk_rails_27539b2fc9 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: project_risk_alerts fk_rails_4685dfa1bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_risk_alerts
    ADD CONSTRAINT fk_rails_4685dfa1bb FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: projects fk_rails_47c768ed16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_rails_47c768ed16 FOREIGN KEY (customer_id) REFERENCES customers(id);


--
-- Name: financial_informations fk_rails_573f757bcf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY financial_informations
    ADD CONSTRAINT fk_rails_573f757bcf FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: companies_users fk_rails_667cd952fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies_users
    ADD CONSTRAINT fk_rails_667cd952fb FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: users fk_rails_971bf2d9a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_971bf2d9a1 FOREIGN KEY (last_company_id) REFERENCES companies(id);


--
-- Name: project_results fk_rails_b11de7d28e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_results
    ADD CONSTRAINT fk_rails_b11de7d28e FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: project_risk_alerts fk_rails_b8b501e2eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_risk_alerts
    ADD CONSTRAINT fk_rails_b8b501e2eb FOREIGN KEY (project_risk_config_id) REFERENCES project_risk_configs(id);


--
-- Name: project_results fk_rails_c3c9938173; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_results
    ADD CONSTRAINT fk_rails_c3c9938173 FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: operation_results fk_rails_dbd0ae3c1c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY operation_results
    ADD CONSTRAINT fk_rails_dbd0ae3c1c FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: teams fk_rails_e080df8a94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams
    ADD CONSTRAINT fk_rails_e080df8a94 FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: customers fk_rails_ef51a916ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT fk_rails_ef51a916ef FOREIGN KEY (company_id) REFERENCES companies(id);


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
('20180206183551');


