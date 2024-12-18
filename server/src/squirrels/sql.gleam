import decode/zero
import gleam/option.{type Option}
import pog

/// A row you get from running the `get_user_by_username` query
/// defined in `./src/squirrels/sql/get_user_by_username.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByUsernameRow {
  GetUserByUsernameRow(
    id: Int,
    username: String,
    email: String,
    password: String,
    invited_by: Option(Int),
  )
}

/// Runs the `get_user_by_username` query
/// defined in `./src/squirrels/sql/get_user_by_username.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_username(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use username <- zero.field(1, zero.string)
    use email <- zero.field(2, zero.string)
    use password <- zero.field(3, zero.string)
    use invited_by <- zero.field(4, zero.optional(zero.int))
    zero.success(
      GetUserByUsernameRow(id:, username:, email:, password:, invited_by:),
    )
  }

  let query = "SELECT
    \"user\".id,
    \"user\".username,
    \"user\".email,
    \"user\".password,
    \"user\".invited_by
FROM
    \"user\"
WHERE
    \"user\".username = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_tags` query
/// defined in `./src/squirrels/sql/get_tags.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetTagsRow {
  GetTagsRow(id: Int, name: String, category: Category, permission: Permission)
}

/// Runs the `get_tags` query
/// defined in `./src/squirrels/sql/get_tags.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_tags(db) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use name <- zero.field(1, zero.string)
    use category <- zero.field(2, category_decoder())
    use permission <- zero.field(3, permission_decoder())
    zero.success(GetTagsRow(id:, name:, category:, permission:))
  }

  let query = "SELECT
    tag.id,
    tag.name,
    tag.category,
    tag.permission
FROM
    tag
"

  pog.query(query)
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_user_id_from_session` query
/// defined in `./src/squirrels/sql/get_user_id_from_session.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserIdFromSessionRow {
  GetUserIdFromSessionRow(id: Int, user_id: Int)
}

/// Runs the `get_user_id_from_session` query
/// defined in `./src/squirrels/sql/get_user_id_from_session.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_id_from_session(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use user_id <- zero.field(1, zero.int)
    zero.success(GetUserIdFromSessionRow(id:, user_id:))
  }

  let query = "SELECT
    user_session.id,
    user_session.user_id
FROM
    user_session
WHERE
    user_session.token = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_id` query
/// defined in `./src/squirrels/sql/get_user_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByIdRow {
  GetUserByIdRow(
    id: Int,
    username: String,
    email: String,
    password: String,
    invited_by: Option(Int),
  )
}

/// Runs the `get_user_by_id` query
/// defined in `./src/squirrels/sql/get_user_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_id(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use username <- zero.field(1, zero.string)
    use email <- zero.field(2, zero.string)
    use password <- zero.field(3, zero.string)
    use invited_by <- zero.field(4, zero.optional(zero.int))
    zero.success(GetUserByIdRow(id:, username:, email:, password:, invited_by:))
  }

  let query = "SELECT
    \"user\".id,
    \"user\".username,
    \"user\".email,
    \"user\".password,
    \"user\".invited_by
FROM
    \"user\"
WHERE
    \"user\".id = $1"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_post_by_id` query
/// defined in `./src/squirrels/sql/get_post_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPostByIdRow {
  GetPostByIdRow(
    id: Int,
    title: String,
    href: Option(String),
    body: Option(String),
    username: Option(String),
    original_creator: Bool,
    like_count: Int,
    comment_count: Int,
    created_at: Float,
  )
}

/// Runs the `get_post_by_id` query
/// defined in `./src/squirrels/sql/get_post_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_post_by_id(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use title <- zero.field(1, zero.string)
    use href <- zero.field(2, zero.optional(zero.string))
    use body <- zero.field(3, zero.optional(zero.string))
    use username <- zero.field(4, zero.optional(zero.string))
    use original_creator <- zero.field(5, zero.bool)
    use like_count <- zero.field(6, zero.int)
    use comment_count <- zero.field(7, zero.int)
    use created_at <- zero.field(8, zero.float)
    zero.success(
      GetPostByIdRow(
        id:,
        title:,
        href:,
        body:,
        username:,
        original_creator:,
        like_count:,
        comment_count:,
        created_at:,
      ),
    )
  }

  let query = "SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    \"user\".username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    EXTRACT(
        EPOCH
        FROM
            post.created_at
    ) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN \"user\" ON post.user_id = \"user\".id
WHERE
    post.id = $1
GROUP BY
    post.id, \"user\".username
ORDER BY
    post.created_at DESC
LIMIT
    25
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_user_like_post_comment` query
/// defined in `./src/squirrels/sql/create_user_like_post_comment.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user_like_post_comment(db, arg_1, arg_2, arg_3) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    user_like_post(user_id, post_id, status)
VALUES
    ($1, $2, $3)
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(likestatus_encoder(arg_3))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_user_is_admin` query
/// defined in `./src/squirrels/sql/get_user_is_admin.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserIsAdminRow {
  GetUserIsAdminRow(id: Int, user_id: Int)
}

/// Runs the `get_user_is_admin` query
/// defined in `./src/squirrels/sql/get_user_is_admin.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_is_admin(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use user_id <- zero.field(1, zero.int)
    zero.success(GetUserIsAdminRow(id:, user_id:))
  }

  let query = "SELECT
    user_admin.id,
    user_admin.user_id
FROM
    user_admin
WHERE 
    user_admin.user_id = $1"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_post_tags` query
/// defined in `./src/squirrels/sql/get_post_tags.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPostTagsRow {
  GetPostTagsRow(post_id: Int, tag_id: Int)
}

/// Runs the `get_post_tags` query
/// defined in `./src/squirrels/sql/get_post_tags.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_post_tags(db, arg_1, arg_2) {
  let decoder = {
    use post_id <- zero.field(0, zero.int)
    use tag_id <- zero.field(1, zero.int)
    zero.success(GetPostTagsRow(post_id:, tag_id:))
  }

  let query = "SELECT
    post_tag.post_id, post_tag.tag_id
FROM
    post_tag
WHERE
    post_tag.post_id = $1
    AND post_tag.tag_id = $2
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_auth_code_by_token` query
/// defined in `./src/squirrels/sql/get_auth_code_by_token.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAuthCodeByTokenRow {
  GetAuthCodeByTokenRow(id: Int, token: String, creator_id: Int, used: Bool)
}

/// Runs the `get_auth_code_by_token` query
/// defined in `./src/squirrels/sql/get_auth_code_by_token.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_auth_code_by_token(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use token <- zero.field(1, zero.string)
    use creator_id <- zero.field(2, zero.int)
    use used <- zero.field(3, zero.bool)
    zero.success(GetAuthCodeByTokenRow(id:, token:, creator_id:, used:))
  }

  let query = "SELECT
    auth_code.id,
    auth_code.token,
    auth_code.creator_id,
    auth_code.used
FROM
    auth_code
WHERE
    auth_code.token = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_tags_by_id` query
/// defined in `./src/squirrels/sql/get_tags_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetTagsByIdRow {
  GetTagsByIdRow(
    id: Int,
    name: String,
    category: Category,
    permission: Permission,
  )
}

/// Runs the `get_tags_by_id` query
/// defined in `./src/squirrels/sql/get_tags_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_tags_by_id(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use name <- zero.field(1, zero.string)
    use category <- zero.field(2, category_decoder())
    use permission <- zero.field(3, permission_decoder())
    zero.success(GetTagsByIdRow(id:, name:, category:, permission:))
  }

  let query = "SELECT
    tag.id, tag.name, tag.category, tag.permission
FROM
    tag
WHERE
    tag.id = $1
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_posts_unlimited` query
/// defined in `./src/squirrels/sql/get_posts_unlimited.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPostsUnlimitedRow {
  GetPostsUnlimitedRow(
    id: Int,
    title: String,
    href: Option(String),
    body: Option(String),
    username: Option(String),
    original_creator: Bool,
    like_count: Int,
    comment_count: Int,
    created_at: Float,
  )
}

/// Runs the `get_posts_unlimited` query
/// defined in `./src/squirrels/sql/get_posts_unlimited.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_posts_unlimited(db) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use title <- zero.field(1, zero.string)
    use href <- zero.field(2, zero.optional(zero.string))
    use body <- zero.field(3, zero.optional(zero.string))
    use username <- zero.field(4, zero.optional(zero.string))
    use original_creator <- zero.field(5, zero.bool)
    use like_count <- zero.field(6, zero.int)
    use comment_count <- zero.field(7, zero.int)
    use created_at <- zero.field(8, zero.float)
    zero.success(
      GetPostsUnlimitedRow(
        id:,
        title:,
        href:,
        body:,
        username:,
        original_creator:,
        like_count:,
        comment_count:,
        created_at:,
      ),
    )
  }

  let query = "SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    \"user\".username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    EXTRACT(
        EPOCH
        FROM
            post.created_at
    ) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN \"user\" ON post.user_id = \"user\".id
GROUP BY
    post.id,
    \"user\".username
ORDER BY
    post.created_at DESC
LIMIT
    25
"

  pog.query(query)
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_forgot_password` query
/// defined in `./src/squirrels/sql/create_forgot_password.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_forgot_password(db, arg_1, arg_2) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    user_forgot_password(user_id, token)
VALUES
    ($1, $2)"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_email_or_username` query
/// defined in `./src/squirrels/sql/get_user_by_email_or_username.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByEmailOrUsernameRow {
  GetUserByEmailOrUsernameRow(email: String, username: String)
}

/// Runs the `get_user_by_email_or_username` query
/// defined in `./src/squirrels/sql/get_user_by_email_or_username.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_email_or_username(db, arg_1, arg_2) {
  let decoder = {
    use email <- zero.field(0, zero.string)
    use username <- zero.field(1, zero.string)
    zero.success(GetUserByEmailOrUsernameRow(email:, username:))
  }

  let query = "SELECT
    \"user\".email, \"user\".username
FROM
    \"user\"
WHERE
    \"user\".email = $1
    OR \"user\".username = $2
"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_user_like_post` query
/// defined in `./src/squirrels/sql/create_user_like_post.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user_like_post(db, arg_1, arg_2, arg_3) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    user_like_post(user_id, post_id, status)
VALUES
    ($1, $2, $3)
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(likestatus_encoder(arg_3))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_post_by_href` query
/// defined in `./src/squirrels/sql/get_post_by_href.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPostByHrefRow {
  GetPostByHrefRow(title: String, href: Option(String))
}

/// Runs the `get_post_by_href` query
/// defined in `./src/squirrels/sql/get_post_by_href.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_post_by_href(db, arg_1) {
  let decoder = {
    use title <- zero.field(0, zero.string)
    use href <- zero.field(1, zero.optional(zero.string))
    zero.success(GetPostByHrefRow(title:, href:))
  }

  let query = "SELECT
    post.title, post.href
FROM
    post
WHERE post.href = $1
"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_user_session` query
/// defined in `./src/squirrels/sql/create_user_session.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user_session(db, arg_1, arg_2) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    user_session(user_id, token)
VALUES
    ($1, $2)"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_auth_code` query
/// defined in `./src/squirrels/sql/create_auth_code.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_auth_code(db, arg_1, arg_2) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    auth_code(token, creator_id)
VALUES
    ($1, $2)
"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `update_user_password` query
/// defined in `./src/squirrels/sql/update_user_password.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_user_password(db, arg_1, arg_2) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "UPDATE
    \"user\"
SET
    password = $2
WHERE
    \"user\".id = $1"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_post_comment` query
/// defined in `./src/squirrels/sql/create_post_comment.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_post_comment(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    post_comment(body, user_id, post_id, parent_id)
VALUES
    ($1, $2, $3, $4)
"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(pog.int(arg_3))
  |> pog.parameter(pog.int(arg_4))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_post_comments_by_id` query
/// defined in `./src/squirrels/sql/get_post_comments_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPostCommentsByIdRow {
  GetPostCommentsByIdRow(
    id: Int,
    body: String,
    username: Option(String),
    like_count: Int,
    parent_id: Option(Int),
    created_at: Float,
  )
}

/// Runs the `get_post_comments_by_id` query
/// defined in `./src/squirrels/sql/get_post_comments_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_post_comments_by_id(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use body <- zero.field(1, zero.string)
    use username <- zero.field(2, zero.optional(zero.string))
    use like_count <- zero.field(3, zero.int)
    use parent_id <- zero.field(4, zero.optional(zero.int))
    use created_at <- zero.field(5, zero.float)
    zero.success(
      GetPostCommentsByIdRow(
        id:,
        body:,
        username:,
        like_count:,
        parent_id:,
        created_at:,
      ),
    )
  }

  let query = "SELECT
    post_comment.id,
    post_comment.body,
    \"user\".username,
    COUNT(DISTINCT user_like_post_comment.id) AS like_count,
    post_comment.parent_id,
    EXTRACT(
        EPOCH
        FROM
            post_comment.created_at
    ) AS created_at
FROM
    post_comment
    LEFT JOIN user_like_post_comment ON post_comment.id = user_like_post_comment.post_comment_id
    AND user_like_post_comment.status = 'like'
    LEFT JOIN \"user\" ON post_comment.user_id = \"user\".id
WHERE
    post_comment.id = $1
GROUP BY
    post_comment.id,
    \"user\".username
ORDER BY
    post_comment.created_at DESC
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_post_with_body` query
/// defined in `./src/squirrels/sql/create_post_with_body.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_post_with_body(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    post(title, body, user_id, original_creator)
VALUES
    ($1, $2, $3, $4)
"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.int(arg_3))
  |> pog.parameter(pog.bool(arg_4))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_post_with_href` query
/// defined in `./src/squirrels/sql/create_post_with_href.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_post_with_href(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    post(title, href, user_id, original_creator)
VALUES
    ($1, $2, $3, $4)
"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.int(arg_3))
  |> pog.parameter(pog.bool(arg_4))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_forgot_password` query
/// defined in `./src/squirrels/sql/get_user_by_forgot_password.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByForgotPasswordRow {
  GetUserByForgotPasswordRow(id: Int, user_id: Int)
}

/// Runs the `get_user_by_forgot_password` query
/// defined in `./src/squirrels/sql/get_user_by_forgot_password.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_forgot_password(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use user_id <- zero.field(1, zero.int)
    zero.success(GetUserByForgotPasswordRow(id:, user_id:))
  }

  let query = "SELECT
    user_forgot_password.id,
    user_forgot_password.user_id
FROM
    user_forgot_password
WHERE
    user_forgot_password.token = $1
    AND user_forgot_password.used = FALSE"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `update_user_like_post_status` query
/// defined in `./src/squirrels/sql/update_user_like_post_status.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_user_like_post_status(db, arg_1, arg_2) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "UPDATE
    user_like_post
SET
    status = $1
WHERE
    id = $2
"

  pog.query(query)
  |> pog.parameter(likestatus_encoder(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_email` query
/// defined in `./src/squirrels/sql/get_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByEmailRow {
  GetUserByEmailRow(
    id: Int,
    username: String,
    email: String,
    password: String,
    invited_by: Option(Int),
  )
}

/// Runs the `get_user_by_email` query
/// defined in `./src/squirrels/sql/get_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_email(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use username <- zero.field(1, zero.string)
    use email <- zero.field(2, zero.string)
    use password <- zero.field(3, zero.string)
    use invited_by <- zero.field(4, zero.optional(zero.int))
    zero.success(
      GetUserByEmailRow(id:, username:, email:, password:, invited_by:),
    )
  }

  let query = "SELECT
    \"user\".id,
    \"user\".username,
    \"user\".email,
    \"user\".password,
    \"user\".invited_by
FROM
    \"user\"
WHERE
    \"user\".email = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_posts` query
/// defined in `./src/squirrels/sql/get_posts.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPostsRow {
  GetPostsRow(
    id: Int,
    title: String,
    href: Option(String),
    body: Option(String),
    username: Option(String),
    original_creator: Bool,
    like_count: Int,
    comment_count: Int,
    created_at: Float,
  )
}

/// Runs the `get_posts` query
/// defined in `./src/squirrels/sql/get_posts.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_posts(db) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use title <- zero.field(1, zero.string)
    use href <- zero.field(2, zero.optional(zero.string))
    use body <- zero.field(3, zero.optional(zero.string))
    use username <- zero.field(4, zero.optional(zero.string))
    use original_creator <- zero.field(5, zero.bool)
    use like_count <- zero.field(6, zero.int)
    use comment_count <- zero.field(7, zero.int)
    use created_at <- zero.field(8, zero.float)
    zero.success(
      GetPostsRow(
        id:,
        title:,
        href:,
        body:,
        username:,
        original_creator:,
        like_count:,
        comment_count:,
        created_at:,
      ),
    )
  }

  let query = "SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    \"user\".username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    EXTRACT(
        EPOCH
        FROM
            post.created_at
    ) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN \"user\" ON post.user_id = \"user\".id
GROUP BY
    post.id,
    \"user\".username
ORDER BY
    post.created_at DESC
"

  pog.query(query)
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_user` query
/// defined in `./src/squirrels/sql/create_user.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    \"user\"(username, email, password, invited_by)
VALUES
    ($1, $2, $3, $4)
"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.int(arg_4))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `update_auth_code_as_used` query
/// defined in `./src/squirrels/sql/update_auth_code_as_used.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_auth_code_as_used(db, arg_1) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "UPDATE
    auth_code
SET
    used = TRUE
WHERE
    id = $1
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_post_comment_parent_in_post` query
/// defined in `./src/squirrels/sql/get_post_comment_parent_in_post.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPostCommentParentInPostRow {
  GetPostCommentParentInPostRow(body: String, user_id: Int)
}

/// Runs the `get_post_comment_parent_in_post` query
/// defined in `./src/squirrels/sql/get_post_comment_parent_in_post.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_post_comment_parent_in_post(db, arg_1, arg_2) {
  let decoder = {
    use body <- zero.field(0, zero.string)
    use user_id <- zero.field(1, zero.int)
    zero.success(GetPostCommentParentInPostRow(body:, user_id:))
  }

  let query = "SELECT
    post_comment.body, post_comment.user_id
FROM
    post_comment
WHERE
    post_comment.post_id = $1
    AND post_comment.id = $2
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_user_post_likes` query
/// defined in `./src/squirrels/sql/get_user_post_likes.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserPostLikesRow {
  GetUserPostLikesRow(id: Int, user_id: Int, post_id: Int, status: Likestatus)
}

/// Runs the `get_user_post_likes` query
/// defined in `./src/squirrels/sql/get_user_post_likes.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_post_likes(db, arg_1, arg_2) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use user_id <- zero.field(1, zero.int)
    use post_id <- zero.field(2, zero.int)
    use status <- zero.field(3, likestatus_decoder())
    zero.success(GetUserPostLikesRow(id:, user_id:, post_id:, status:))
  }

  let query = "SELECT
    user_like_post.id,
    user_like_post.user_id,
    user_like_post.post_id,
    user_like_post.status
FROM
    user_like_post
WHERE
    user_like_post.user_id = $1
    AND user_like_post.post_id = $2"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_post_tag` query
/// defined in `./src/squirrels/sql/create_post_tag.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_post_tag(db, arg_1, arg_2) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    post_tag(post_id, tag_id)
VALUES
    ($1, $2)
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_user_post_comment_likes` query
/// defined in `./src/squirrels/sql/get_user_post_comment_likes.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserPostCommentLikesRow {
  GetUserPostCommentLikesRow(
    id: Int,
    user_id: Int,
    post_comment_id: Int,
    status: Likestatus,
  )
}

/// Runs the `get_user_post_comment_likes` query
/// defined in `./src/squirrels/sql/get_user_post_comment_likes.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_post_comment_likes(db, arg_1, arg_2) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use user_id <- zero.field(1, zero.int)
    use post_comment_id <- zero.field(2, zero.int)
    use status <- zero.field(3, likestatus_decoder())
    zero.success(
      GetUserPostCommentLikesRow(id:, user_id:, post_comment_id:, status:),
    )
  }

  let query = "SELECT
    user_like_post_comment.id,
    user_like_post_comment.user_id,
    user_like_post_comment.post_comment_id,
    user_like_post_comment.status
FROM
    user_like_post_comment
WHERE
    user_like_post_comment.user_id = $1
    AND user_like_post_comment.post_comment_id = $2"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_post_comment_no_parent` query
/// defined in `./src/squirrels/sql/create_post_comment_no_parent.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_post_comment_no_parent(db, arg_1, arg_2, arg_3) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    post_comment(body, user_id, post_id, parent_id)
VALUES
    ($1, $2, $3, NULL)
"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(pog.int(arg_3))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_latest_post_by_user_id` query
/// defined in `./src/squirrels/sql/get_latest_post_by_user_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetLatestPostByUserIdRow {
  GetLatestPostByUserIdRow(
    id: Int,
    title: String,
    href: Option(String),
    body: Option(String),
    username: Option(String),
    original_creator: Bool,
    like_count: Int,
    comment_count: Int,
    created_at: Float,
  )
}

/// Runs the `get_latest_post_by_user_id` query
/// defined in `./src/squirrels/sql/get_latest_post_by_user_id.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_latest_post_by_user_id(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use title <- zero.field(1, zero.string)
    use href <- zero.field(2, zero.optional(zero.string))
    use body <- zero.field(3, zero.optional(zero.string))
    use username <- zero.field(4, zero.optional(zero.string))
    use original_creator <- zero.field(5, zero.bool)
    use like_count <- zero.field(6, zero.int)
    use comment_count <- zero.field(7, zero.int)
    use created_at <- zero.field(8, zero.float)
    zero.success(
      GetLatestPostByUserIdRow(
        id:,
        title:,
        href:,
        body:,
        username:,
        original_creator:,
        like_count:,
        comment_count:,
        created_at:,
      ),
    )
  }

  let query = "SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    \"user\".username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    EXTRACT(
        EPOCH
        FROM
            post.created_at
    ) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN \"user\" ON post.user_id = \"user\".id
WHERE
    post.user_id = $1
GROUP BY
    post.id, \"user\".username
ORDER BY
    post.created_at DESC
LIMIT
    1
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_post_comments_by_post_id` query
/// defined in `./src/squirrels/sql/get_post_comments_by_post_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPostCommentsByPostIdRow {
  GetPostCommentsByPostIdRow(
    id: Int,
    body: String,
    username: Option(String),
    like_count: Int,
    parent_id: Option(Int),
    created_at: Float,
  )
}

/// Runs the `get_post_comments_by_post_id` query
/// defined in `./src/squirrels/sql/get_post_comments_by_post_id.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_post_comments_by_post_id(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use body <- zero.field(1, zero.string)
    use username <- zero.field(2, zero.optional(zero.string))
    use like_count <- zero.field(3, zero.int)
    use parent_id <- zero.field(4, zero.optional(zero.int))
    use created_at <- zero.field(5, zero.float)
    zero.success(
      GetPostCommentsByPostIdRow(
        id:,
        body:,
        username:,
        like_count:,
        parent_id:,
        created_at:,
      ),
    )
  }

  let query = "SELECT
    post_comment.id,
    post_comment.body,
    \"user\".username,
    COUNT(DISTINCT user_like_post_comment.id) AS like_count,
    post_comment.parent_id,
    EXTRACT(
        EPOCH
        FROM
            post_comment.created_at
    ) AS created_at
FROM
    post_comment
    LEFT JOIN user_like_post_comment ON post_comment.id = user_like_post_comment.post_comment_id
    AND user_like_post_comment.status = 'like'
    LEFT JOIN \"user\" ON post_comment.user_id = \"user\".id
WHERE
    post_comment.post_id = $1
GROUP BY
    post_comment.id,
    \"user\".username
ORDER BY
    post_comment.created_at DESC
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_tags_by_post_id` query
/// defined in `./src/squirrels/sql/get_tags_by_post_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetTagsByPostIdRow {
  GetTagsByPostIdRow(id: Option(Int), name: Option(String))
}

/// Runs the `get_tags_by_post_id` query
/// defined in `./src/squirrels/sql/get_tags_by_post_id.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_tags_by_post_id(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.optional(zero.int))
    use name <- zero.field(1, zero.optional(zero.string))
    zero.success(GetTagsByPostIdRow(id:, name:))
  }

  let query = "SELECT
    tag.id, tag.name
FROM
    post_tag
    LEFT JOIN tag
    ON tag.id = post_tag.tag_id
WHERE
    post_tag.post_id = $1
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `get_comments_for_sitemap` query
/// defined in `./src/squirrels/sql/get_comments_for_sitemap.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetCommentsForSitemapRow {
  GetCommentsForSitemapRow(id: Int, created_at: Float)
}

/// Runs the `get_comments_for_sitemap` query
/// defined in `./src/squirrels/sql/get_comments_for_sitemap.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_comments_for_sitemap(db, arg_1) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use created_at <- zero.field(1, zero.float)
    zero.success(GetCommentsForSitemapRow(id:, created_at:))
  }

  let query = "SELECT
    post_comment.id,
    EXTRACT(EPOCH FROM post_comment.created_at) AS created_at
FROM
    post_comment
WHERE
    post_comment.post_id = $1
ORDER BY post_comment.created_at DESC
"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `update_forgot_password_as_used` query
/// defined in `./src/squirrels/sql/update_forgot_password_as_used.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_forgot_password_as_used(db, arg_1) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "UPDATE
    user_forgot_password
SET
    used = TRUE
WHERE
    token = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `update_user_like_post_comment_status` query
/// defined in `./src/squirrels/sql/update_user_like_post_comment_status.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.5 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_user_like_post_comment_status(db, arg_1, arg_2) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "UPDATE
    user_like_post_comment
SET
    status = $1
WHERE
    id = $2
"

  pog.query(query)
  |> pog.parameter(likestatus_encoder(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

// --- Enums -------------------------------------------------------------------

/// Corresponds to the Postgres `category` enum.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type Category {
  Tools
  Practices
  Platforms
  Kirakira
  Genre
  Format
}

fn category_decoder() {
  use variant <- zero.then(zero.string)
  case variant {
    "tools" -> zero.success(Tools)
    "practices" -> zero.success(Practices)
    "platforms" -> zero.success(Platforms)
    "kirakira" -> zero.success(Kirakira)
    "genre" -> zero.success(Genre)
    "format" -> zero.success(Format)
    _ -> zero.failure(Tools, "Category")
  }
}/// Corresponds to the Postgres `likestatus` enum.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type Likestatus {
  Neutral
  Like
}

fn likestatus_decoder() {
  use variant <- zero.then(zero.string)
  case variant {
    "neutral" -> zero.success(Neutral)
    "like" -> zero.success(Like)
    _ -> zero.failure(Neutral, "Likestatus")
  }
}

fn likestatus_encoder(variant) {
  case variant {
    Neutral -> "neutral"
    Like -> "like"
  }
  |> pog.text
}/// Corresponds to the Postgres `permission` enum.
///
/// > 🐿️ This type definition was generated automatically using v2.0.5 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type Permission {
  Admin
  Member
}

fn permission_decoder() {
  use variant <- zero.then(zero.string)
  case variant {
    "admin" -> zero.success(Admin)
    "member" -> zero.success(Member)
    _ -> zero.failure(Admin, "Permission")
  }
}
