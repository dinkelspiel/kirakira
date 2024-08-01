import gleam/dynamic
import gleam/option.{type Option}
import lustre_http
import shared.{type Post, type Tag}

pub type Route {
  Active
  Login
  Signup(auth_code: String)
  CreatePost
  UserPage(username: String)
  ShowPost(post_id: Int)
  NotFound
}

pub type Model {
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

pub type Msg {
  OnRouteChange(Route)
  InviterRecieved(Result(AuthCodeResponse, lustre_http.HttpError))
  AuthUserRecieved(Result(AuthUser, lustre_http.HttpError))
  PostsRecieved(Result(GetPostsResponse, lustre_http.HttpError))
  ShowPostRecieved(Result(Post, lustre_http.HttpError))
  TagsRecieved(Result(GetTagsResponse, lustre_http.HttpError))

  SignUpUpdateUsername(value: String)
  SignUpUpdateEmail(value: String)
  SignUpUpdatePassword(value: String)
  SignUpUpdateError(value: Option(String))
  RequestSignUp
  SignUpResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )

  LoginUpdateEmailUsername(value: String)
  LoginUpdatePassword(value: String)
  LoginUpdateError(value: Option(String))
  RequestLogin
  LoginResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )

  RequestLogout
  LogoutResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )

  CreatePostUpdateTitle(value: String)
  CreatePostUpdateHref(value: String)
  CreatePostUpdateBody(value: String)
  CreatePostUpdateOriginalCreator(value: Bool)
  CreatePostUpdateUseBody(value: Bool)
  CreatePostUpdateTags(tag_id: Int)
  CreatePostUpdateError(value: Option(String))
  RequestCreatePost
  CreatePostResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )

  RequestLikePost(post_id: Int)
  LikePostResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )

  CreateCommentUpdateBody(value: String)
  CreateCommentUpdateParentId(value: Option(Int))
  CreateCommentUpdateError(value: Option(String))
  RequestCreateComment
  CreateCommentResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )

  RequestLikeComment(post_comment_id: Int)
  LikeCommentResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )

  RequestCreateAuthCode
  CreateAuthCodeResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )
}

// Responses

pub type AuthCodeResponse {
  AuthCodeResponse(username: String)
}

pub type MessageErrorResponse {
  MessageErrorResponse(message: Option(String), error: Option(String))
}

pub type GetPostsResponse {
  GetPostsResponse(posts: List(Post))
}

pub type GetTagsResponse {
  GetTagsResponse(tags: List(Tag))
}

pub fn message_error_decoder() {
  dynamic.decode2(
    MessageErrorResponse,
    dynamic.optional_field("message", dynamic.string),
    dynamic.optional_field("error", dynamic.string),
  )
}

pub type AuthUser {
  AuthUser(user_id: Int, username: String, is_admin: Bool)
}
