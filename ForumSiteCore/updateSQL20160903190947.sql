
DROP TABLE account;

DROP TABLE comment;

DROP TABLE forum;

DROP TABLE post;

DROP TABLE save;

DROP TABLE savetarget;

DROP TABLE savetype;

CREATE SEQUENCE accountrole_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE role_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE account_id_seq
	OWNED BY accounts.id;

ALTER SEQUENCE comment_id_seq
	OWNED BY comments.id;

ALTER SEQUENCE forum_id_seq
	OWNED BY forums.id;

ALTER SEQUENCE post_id_seq
	OWNED BY posts.id;

ALTER SEQUENCE subscription_id_seq
	OWNED BY saves.id;

ALTER SEQUENCE subscriptiontarget_id_seq
	OWNED BY savetargets.itemid;

ALTER SEQUENCE subscriptiontarget_id_seq1
	OWNED BY savetargets.id;

ALTER SEQUENCE subscriptiontype_id_seq
	OWNED BY savetypes.id;

CREATE TABLE accounts (
	id bigint DEFAULT nextval('account_id_seq'::regclass) NOT NULL,
	username dom_text_no_whitespace NOT NULL,
	email character varying(254) NOT NULL,
	passwordhash character(60) NOT NULL,
	created timestamp without time zone,
	updated timestamp without time zone
);

CREATE TABLE accountroles (
	id bigint DEFAULT nextval('accountrole_id_seq'::regclass) NOT NULL,
	accountid bigint,
	roleid integer
);

CREATE TABLE comments (
	id bigint DEFAULT nextval('comment_id_seq'::regclass) NOT NULL,
	parentid bigint,
	accountid bigint NOT NULL,
	postid bigint NOT NULL,
	description text NOT NULL,
	created timestamp without time zone,
	updated timestamp without time zone,
	savetypeid smallint DEFAULT 3
);

CREATE TABLE forums (
	id bigint DEFAULT nextval('forum_id_seq'::regclass) NOT NULL,
	name dom_text_no_whitespace NOT NULL,
	description text,
	created timestamp without time zone,
	updated timestamp without time zone,
	inactive boolean,
	savetypeid smallint DEFAULT 1
);

CREATE TABLE posts (
	id bigint DEFAULT nextval('post_id_seq'::regclass) NOT NULL,
	name text NOT NULL,
	description text,
	url text,
	forumid bigint NOT NULL,
	accountid bigint NOT NULL,
	created timestamp without time zone,
	updated timestamp without time zone,
	savetypeid smallint DEFAULT 2
);

CREATE TABLE roles (
	id integer DEFAULT nextval('role_id_seq'::regclass) NOT NULL,
	name text
);

CREATE TABLE saves (
	id bigint DEFAULT nextval('subscription_id_seq'::regclass) NOT NULL,
	created timestamp without time zone,
	accountid bigint,
	savetargetid bigint,
	saved boolean,
	savetypeid smallint
);

CREATE TABLE savetargets (
	itemid bigint DEFAULT nextval('subscriptiontarget_id_seq'::regclass) NOT NULL,
	savetypeid smallint NOT NULL,
	id bigint DEFAULT nextval('subscriptiontarget_id_seq1'::regclass) NOT NULL
);

CREATE TABLE savetypes (
	id smallint DEFAULT nextval('subscriptiontype_id_seq'::regclass) NOT NULL,
	name text
);

ALTER SEQUENCE accountrole_id_seq
	OWNED BY accountroles.id;

ALTER SEQUENCE role_id_seq
	OWNED BY roles.id;

ALTER TABLE accounts
	ADD CONSTRAINT account_pkey PRIMARY KEY (id);

ALTER TABLE accountroles
	ADD CONSTRAINT accountrole_pkey PRIMARY KEY (id);

ALTER TABLE comments
	ADD CONSTRAINT comment_pkey PRIMARY KEY (id);

ALTER TABLE forums
	ADD CONSTRAINT forum_pkey PRIMARY KEY (id);

ALTER TABLE posts
	ADD CONSTRAINT post_pkey PRIMARY KEY (id);

ALTER TABLE roles
	ADD CONSTRAINT role_pkey PRIMARY KEY (id);

ALTER TABLE savetargets
	ADD CONSTRAINT subscriptiontarget_pkey PRIMARY KEY (id);

ALTER TABLE savetypes
	ADD CONSTRAINT savetype_pkey PRIMARY KEY (id);

ALTER TABLE accountroles
	ADD CONSTRAINT accountrole_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(id);

ALTER TABLE accountroles
	ADD CONSTRAINT accountrole_roleid_fkey FOREIGN KEY (roleid) REFERENCES roles(id);

ALTER TABLE comments
	ADD CONSTRAINT comment_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(id);

ALTER TABLE comments
	ADD CONSTRAINT comment_postid_fkey FOREIGN KEY (postid) REFERENCES posts(id);

ALTER TABLE posts
	ADD CONSTRAINT post_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(id);

ALTER TABLE posts
	ADD CONSTRAINT post_forumid_fkey FOREIGN KEY (forumid) REFERENCES forums(id);

ALTER TABLE saves
	ADD CONSTRAINT save_savetypeid_fkey FOREIGN KEY (savetypeid) REFERENCES savetypes(id);

ALTER TABLE savetargets
	ADD CONSTRAINT savetarget_savetypeid_id_key UNIQUE (savetypeid, id);

CREATE UNIQUE INDEX unique_account_username_idx ON accounts USING btree (lower((username)::text));

CREATE UNIQUE INDEX unique_forum_name_idx ON forums USING btree (lower((name)::text));

CREATE INDEX fki_subscription_subscriptiontypeid_fkey ON saves USING btree (savetypeid);

CREATE TRIGGER trig_comment_insert_savetarget
	AFTER INSERT ON comments
	FOR EACH ROW
	EXECUTE PROCEDURE insert_savetarget();

CREATE TRIGGER trig_forum_insert_savetarget
	AFTER INSERT ON forums
	FOR EACH ROW
	EXECUTE PROCEDURE insert_savetarget();

CREATE TRIGGER trig_post_insert_savetarget
	AFTER INSERT ON posts
	FOR EACH ROW
	EXECUTE PROCEDURE insert_savetarget();
