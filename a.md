```gleam
pub type Legacy {
  Model(
    route: Route,
    inviter: String,
    auth_user: Option(AuthUser),
    sign_up_username: String,
    sign_up_email: String,
    sign_up_password: String,
    sign_up_error: Option(String),
    login_email_username: String,
    login_password: String,
    login_error: Option(String),
    create_post_title: String,
    create_post_href: String,
    create_post_body: String,
    create_post_original_creator: Bool,
    create_post_use_body: Bool,
    create_post_tags: List(Int),
    create_post_error: Option(String),
    posts: List(Post),
    show_post: Option(Post),
    create_comment_body: String,
    create_comment_error: Option(String),
    create_comment_parent_id: Option(Int),
    tags: List(Tag),
    invite_link: Option(String),
  )
}

pub type SiteModel {
  SiteModel(route: Route, user: Option(AuthUser))
}

pub type RootModel {
  RootModel(posts: List(Post))
}

pub type PostModel {
  PostModel(post: Option(Post))
}

pub type LoginModel {
  LoginModel(email_or_username: String, password: String, error: Option(String))
}

pub type SignupModel {
  SignupModel(
    email: String,
    password: String,
    username: String,
    error: Option(String),
  )
}

pub type CreatePostModel {
  CreatePostModel(
    title: String,
    href: Option(String),
    body: Option(String),
    original_creator: Bool,
    tags: List(Tag),
    selected_tags: List(Int),
    error: Option(String),
  )
}

pub type CreateCommentModel {
  CreateCommentModel(
    body: String,
    parent_id: Option(Int),
    error: Option(String),
  )
}

pub type UserSettingsModel {
  UserSettingsModel(
    username: String,
    email: String,
    password: String,
    error: Option(String),
  )
}
```
