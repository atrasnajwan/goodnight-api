SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: followings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.followings (
    id bigint NOT NULL,
    follower_id bigint NOT NULL,
    followed_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: followings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.followings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: followings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.followings_id_seq OWNED BY public.followings.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sleep_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sleep_records (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    clocked_in_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    clocked_out_at timestamp(6) without time zone,
    duration_hours numeric(10,2),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
)
PARTITION BY RANGE (clocked_in_at);


--
-- Name: sleep_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sleep_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sleep_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sleep_records_id_seq OWNED BY public.sleep_records.id;


--
-- Name: sleep_records_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sleep_records_template (
    id bigint DEFAULT nextval('public.sleep_records_id_seq'::regclass) NOT NULL,
    user_id bigint NOT NULL,
    clocked_in_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    clocked_out_at timestamp(6) without time zone,
    duration_hours numeric(10,2),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
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
-- Name: followings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followings ALTER COLUMN id SET DEFAULT nextval('public.followings_id_seq'::regclass);


--
-- Name: sleep_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sleep_records ALTER COLUMN id SET DEFAULT nextval('public.sleep_records_id_seq'::regclass);


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
-- Name: followings followings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followings
    ADD CONSTRAINT followings_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sleep_records_template sleep_records_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sleep_records_template
    ADD CONSTRAINT sleep_records_template_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_followings_on_followed_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_followings_on_followed_id ON public.followings USING btree (followed_id);


--
-- Name: index_followings_on_followed_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_followings_on_followed_id_and_created_at ON public.followings USING btree (followed_id, created_at);


--
-- Name: index_followings_on_followed_id_and_follower_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_followings_on_followed_id_and_follower_id ON public.followings USING btree (followed_id, follower_id);


--
-- Name: index_followings_on_follower_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_followings_on_follower_id ON public.followings USING btree (follower_id);


--
-- Name: index_followings_on_follower_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_followings_on_follower_id_and_created_at ON public.followings USING btree (follower_id, created_at);


--
-- Name: index_sleep_records_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sleep_records_on_user_id ON ONLY public.sleep_records USING btree (user_id);


--
-- Name: index_sleep_records_on_user_id_and_clocked_in_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sleep_records_on_user_id_and_clocked_in_at ON ONLY public.sleep_records USING btree (user_id, clocked_in_at);


--
-- Name: index_sleep_records_on_user_id_and_clocked_out_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sleep_records_on_user_id_and_clocked_out_at ON ONLY public.sleep_records USING btree (user_id, clocked_out_at);


--
-- Name: index_sleep_records_on_user_id_and_duration_hours; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sleep_records_on_user_id_and_duration_hours ON ONLY public.sleep_records USING btree (user_id, duration_hours) WHERE (clocked_out_at IS NOT NULL);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name ON public.users USING btree (name);


--
-- Name: sleep_records_template_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sleep_records_template_user_id_idx ON public.sleep_records_template USING btree (user_id);


--
-- Name: sleep_records fk_rails_0f78b0de7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.sleep_records
    ADD CONSTRAINT fk_rails_0f78b0de7b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: followings fk_rails_1668ccdb36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followings
    ADD CONSTRAINT fk_rails_1668ccdb36 FOREIGN KEY (follower_id) REFERENCES public.users(id);


--
-- Name: followings fk_rails_a56ad8ead3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followings
    ADD CONSTRAINT fk_rails_a56ad8ead3 FOREIGN KEY (followed_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250907105932'),
('20250907105510'),
('20250907105404'),
('20250906033903'),
('20250906033552');

