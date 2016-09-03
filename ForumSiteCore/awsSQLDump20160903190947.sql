--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.5
-- Dumped by pg_dump version 9.5.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: dom_text_no_whitespace; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN dom_text_no_whitespace AS text
	CONSTRAINT no_whitespace CHECK ((VALUE ~ '^[A-Za-z0-9]+$'::text));


ALTER DOMAIN dom_text_no_whitespace OWNER TO postgres;

--
-- Name: get_save_target_id(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_save_target_id(item bigint, savetype bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE save_target_id bigint;	
BEGIN
SELECT INTO save_target_id id from savetarget where itemid = item and savetypeid = savetype;
RETURN save_target_id;	
END;
$$;


ALTER FUNCTION public.get_save_target_id(item bigint, savetype bigint) OWNER TO postgres;

--
-- Name: insert_save(bigint, smallint, bigint, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insert_save(account bigint, savetype smallint, itemid bigint, created timestamp without time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE savetarget bigint := get_save_target_id(itemid, saveetype);	
BEGIN    	
	INSERT INTO save(accountid, savetypeid, savetargetid, saved, created) 
	VALUES (account, savetype, savetarget, true, created);
	RETURN;
END;
$$;


ALTER FUNCTION public.insert_save(account bigint, savetype smallint, itemid bigint, created timestamp without time zone) OWNER TO postgres;

--
-- Name: insert_savetarget(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insert_savetarget() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO savetarget(itemid, savetypeid) VALUES (new.id, new.savetypeid);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_savetarget() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE account (
    id bigint NOT NULL,
    username dom_text_no_whitespace NOT NULL,
    email character varying(254) NOT NULL,
    passhash character(60) NOT NULL,
    created timestamp without time zone,
    updated timestamp without time zone
);


ALTER TABLE account OWNER TO postgres;

--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_id_seq OWNER TO postgres;

--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE account_id_seq OWNED BY account.id;


--
-- Name: comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE comment (
    id bigint NOT NULL,
    parentid bigint,
    accountid bigint NOT NULL,
    postid bigint NOT NULL,
    description text NOT NULL,
    created timestamp without time zone,
    updated timestamp without time zone,
    savetypeid smallint DEFAULT 3
);


ALTER TABLE comment OWNER TO postgres;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE comment_id_seq OWNER TO postgres;

--
-- Name: comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE comment_id_seq OWNED BY comment.id;


--
-- Name: forum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE forum (
    id bigint NOT NULL,
    name dom_text_no_whitespace NOT NULL,
    description text,
    created timestamp without time zone,
    updated timestamp without time zone,
    inactive boolean,
    savetypeid smallint DEFAULT 1
);


ALTER TABLE forum OWNER TO postgres;

--
-- Name: forum_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE forum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE forum_id_seq OWNER TO postgres;

--
-- Name: forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE forum_id_seq OWNED BY forum.id;


--
-- Name: post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE post (
    id bigint NOT NULL,
    name text NOT NULL,
    description text,
    url text,
    forumid bigint NOT NULL,
    accountid bigint NOT NULL,
    created timestamp without time zone,
    updated timestamp without time zone,
    savetypeid smallint DEFAULT 2
);


ALTER TABLE post OWNER TO postgres;

--
-- Name: post_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE post_id_seq OWNER TO postgres;

--
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE post_id_seq OWNED BY post.id;


--
-- Name: save; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE save (
    id bigint NOT NULL,
    created timestamp without time zone,
    accountid bigint,
    savetargetid bigint,
    saved boolean,
    savetypeid smallint
);


ALTER TABLE save OWNER TO postgres;

--
-- Name: savetarget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE savetarget (
    itemid bigint NOT NULL,
    savetypeid smallint NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE savetarget OWNER TO postgres;

--
-- Name: savetype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE savetype (
    id smallint NOT NULL,
    name text
);


ALTER TABLE savetype OWNER TO postgres;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subscription_id_seq OWNER TO postgres;

--
-- Name: subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE subscription_id_seq OWNED BY save.id;


--
-- Name: subscriptiontarget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE subscriptiontarget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subscriptiontarget_id_seq OWNER TO postgres;

--
-- Name: subscriptiontarget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE subscriptiontarget_id_seq OWNED BY savetarget.itemid;


--
-- Name: subscriptiontarget_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE subscriptiontarget_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subscriptiontarget_id_seq1 OWNER TO postgres;

--
-- Name: subscriptiontarget_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE subscriptiontarget_id_seq1 OWNED BY savetarget.id;


--
-- Name: subscriptiontype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE subscriptiontype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subscriptiontype_id_seq OWNER TO postgres;

--
-- Name: subscriptiontype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE subscriptiontype_id_seq OWNED BY savetype.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account ALTER COLUMN id SET DEFAULT nextval('account_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment ALTER COLUMN id SET DEFAULT nextval('comment_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum ALTER COLUMN id SET DEFAULT nextval('forum_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post ALTER COLUMN id SET DEFAULT nextval('post_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY save ALTER COLUMN id SET DEFAULT nextval('subscription_id_seq'::regclass);


--
-- Name: itemid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY savetarget ALTER COLUMN itemid SET DEFAULT nextval('subscriptiontarget_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY savetarget ALTER COLUMN id SET DEFAULT nextval('subscriptiontarget_id_seq1'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY savetype ALTER COLUMN id SET DEFAULT nextval('subscriptiontype_id_seq'::regclass);


--
-- Name: account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: forum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forum
    ADD CONSTRAINT forum_pkey PRIMARY KEY (id);


--
-- Name: post_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- Name: savetarget_savetypeid_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY savetarget
    ADD CONSTRAINT savetarget_savetypeid_id_key UNIQUE (savetypeid, id);


--
-- Name: savetype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY savetype
    ADD CONSTRAINT savetype_pkey PRIMARY KEY (id);


--
-- Name: subscriptiontarget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY savetarget
    ADD CONSTRAINT subscriptiontarget_pkey PRIMARY KEY (id);


--
-- Name: fki_subscription_subscriptiontypeid_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_subscription_subscriptiontypeid_fkey ON save USING btree (savetypeid);


--
-- Name: unique_account_username_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_account_username_idx ON account USING btree (lower((username)::text));


--
-- Name: unique_forum_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_forum_name_idx ON forum USING btree (lower((name)::text));


--
-- Name: trig_comment_insert_savetarget; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trig_comment_insert_savetarget AFTER INSERT ON comment FOR EACH ROW EXECUTE PROCEDURE insert_savetarget();


--
-- Name: trig_forum_insert_savetarget; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trig_forum_insert_savetarget AFTER INSERT ON forum FOR EACH ROW EXECUTE PROCEDURE insert_savetarget();


--
-- Name: trig_post_insert_savetarget; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trig_post_insert_savetarget AFTER INSERT ON post FOR EACH ROW EXECUTE PROCEDURE insert_savetarget();


--
-- Name: comment_accountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_accountid_fkey FOREIGN KEY (accountid) REFERENCES account(id);


--
-- Name: comment_postid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_postid_fkey FOREIGN KEY (postid) REFERENCES post(id);


--
-- Name: post_accountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT post_accountid_fkey FOREIGN KEY (accountid) REFERENCES account(id);


--
-- Name: post_forumid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT post_forumid_fkey FOREIGN KEY (forumid) REFERENCES forum(id);


--
-- Name: save_savetypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY save
    ADD CONSTRAINT save_savetypeid_fkey FOREIGN KEY (savetypeid) REFERENCES savetype(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

