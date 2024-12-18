-- Drop tables if they exist
DROP TABLE IF EXISTS auth_code CASCADE;

DROP TABLE IF EXISTS user_forgot_password CASCADE;

DROP TABLE IF EXISTS "user" CASCADE;

DROP TABLE IF EXISTS user_admin CASCADE;

DROP TABLE IF EXISTS post CASCADE;

DROP TABLE IF EXISTS post_comment CASCADE;

DROP TABLE IF EXISTS user_like_post CASCADE;

DROP TABLE IF EXISTS user_like_post_comment CASCADE;

DROP TABLE IF EXISTS user_session CASCADE;

DROP TABLE IF EXISTS tag CASCADE;

DROP TABLE IF EXISTS post_tag CASCADE;

-- Table structure for table `user`
CREATE TABLE "user" (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(128) NOT NULL,
    invited_by BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT user_invited_by_user_id FOREIGN KEY (invited_by) REFERENCES "user" (id) ON DELETE CASCADE
);

-- Table structure for table `auth_code`
CREATE TABLE auth_code (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(64) NOT NULL,
    creator_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    used BOOLEAN DEFAULT FALSE,
    CONSTRAINT auth_code_creator_id_user_id FOREIGN KEY (creator_id) REFERENCES "user" (id) ON DELETE CASCADE
);

-- Table structure for table `user_forgot_password`
CREATE TABLE user_forgot_password (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(64) NOT NULL,
    user_id BIGINT NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT user_forgot_password_user_id_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE
);

-- Table structure for table `user_admin`
CREATE TABLE user_admin (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT user_admin_user_id_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE
);

-- Table structure for table `post`
CREATE TABLE post (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    href VARCHAR(255),
    body TEXT,
    user_id BIGINT NOT NULL,
    original_creator BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT post_user_id_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE
);

-- Table structure for table `post_comment`
CREATE TABLE post_comment (
    id BIGSERIAL PRIMARY KEY,
    body TEXT NOT NULL,
    user_id BIGINT NOT NULL,
    post_id BIGINT NOT NULL,
    parent_id BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT post_comment_user_id_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE,
    CONSTRAINT post_comment_post_id_post_id FOREIGN KEY (post_id) REFERENCES post (id) ON DELETE CASCADE,
    CONSTRAINT post_comment_parent_id_post_comment_id FOREIGN KEY (parent_id) REFERENCES post_comment (id) ON DELETE CASCADE
);

CREATE TYPE likestatus AS ENUM ('like', 'neutral');

-- Table structure for table `user_like_post`
CREATE TABLE user_like_post (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    post_id BIGINT NOT NULL,
    status likestatus NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT user_like_post_post_id_post_id FOREIGN KEY (post_id) REFERENCES post (id) ON DELETE CASCADE,
    CONSTRAINT user_like_post_user_id_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE
);

-- Table structure for table `user_like_post_comment`
CREATE TABLE user_like_post_comment (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    post_comment_id BIGINT NOT NULL,
    status likestatus NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT user_like_post_comment_post_comment_id_post_comment_id FOREIGN KEY (post_comment_id) REFERENCES post_comment (id) ON DELETE CASCADE,
    CONSTRAINT user_like_post_commnet_user_id_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE
);

-- Table structure for table `user_session`
CREATE TABLE user_session (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(64) NOT NULL,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT user_session_user_id_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE
);

CREATE TYPE CATEGORY AS ENUM (
    'format',
    'genre',
    'kirakira',
    'platforms',
    'practices',
    'tools'
);

CREATE TYPE PERMISSION AS ENUM ('member', 'admin');

-- Table structure for table `tag`
CREATE TABLE tag (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    category CATEGORY NOT NULL,
    permission PERMISSION NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL
);

-- Table structure for table `post_tag`
CREATE TABLE post_tag (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT post_tag_post_id_post_id FOREIGN KEY (post_id) REFERENCES post (id) ON DELETE CASCADE,
    CONSTRAINT post_tag_tag_id_tag_id FOREIGN KEY (tag_id) REFERENCES tag (id) ON DELETE CASCADE
);

-- Insert statements for `tag` table
INSERT INTO
    tag (category, name, permission)
VALUES
    ('format', 'ask', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('format', 'audio', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('format', 'book', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('format', 'pdf', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('format', 'show', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('format', 'slides', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('format', 'video', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('genre', 'art', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('genre', 'event', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('genre', 'job', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('genre', 'rant', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('genre', 'release', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('genre', 'satire', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('kirakira', 'announce', 'admin');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('kirakira', 'meta', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('platforms', 'erlang', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('platforms', 'javascript', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'api', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'debugging', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'devops', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'performance', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'practices', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'privacy', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'scaling', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'security', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'testing', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('practices', 'virtualization', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('tools', 'compilers', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('tools', 'editors', 'member');

INSERT INTO
    tag (category, name, permission)
VALUES
    ('tools', 'cli', 'member');