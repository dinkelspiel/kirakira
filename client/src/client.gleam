import client/components/button.{button_class}
import client/components/like.{like_comment, like_post}
import client/routes/change_password.{change_password}
import client/routes/create_post.{create_post_view}
import client/routes/forgot_password.{forgot_password}
import client/routes/latest.{latest_view}
import client/routes/login.{login, login_view}
import client/routes/post.{show_post_view}
import client/routes/signup.{signup_view}
import client/routes/user.{user_view}
import client/state.{
  type Model, type Msg, type Route, Active, AuthUser, AuthUserRecieved,
  ChangePassword, ChangePasswordResponded, ChangePasswordTargetRecieved,
  CreateAuthCodeResponded, CreateCommentResponded, CreateCommentUpdateBody,
  CreateCommentUpdateError, CreateCommentUpdateParentId, CreatePost,
  CreatePostResponded, CreatePostUpdateBody, CreatePostUpdateError,
  CreatePostUpdateHref, CreatePostUpdateOriginalCreator, CreatePostUpdateTags,
  CreatePostUpdateTitle, CreatePostUpdateUseBody, ForgotPassword,
  ForgotPasswordResponded, GetPostsResponse, GetTagsResponse, InviterRecieved,
  LikeCommentResponded, LikePostResponded, Login, LoginResponded,
  LoginUpdateEmailUsername, LoginUpdateError, LoginUpdatePassword,
  LogoutResponded, Model, NotFound, OnRouteChange, PostsRecieved,
  RequestChangePassword, RequestCreateAuthCode, RequestCreateComment,
  RequestCreatePost, RequestForgotPassword, RequestLikeComment, RequestLikePost,
  RequestLogin, RequestLogout, RequestSignUp, ShowPost, ShowPostRecieved,
  SignUpResponded, SignUpUpdateEmail, SignUpUpdateError, SignUpUpdatePassword,
  SignUpUpdateUsername, Signup, TagsRecieved, UserPage, UsernameResponse,
  message_error_decoder,
}
import decode
import env
import gleam/dynamic
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/uri.{type Uri}
import lustre
import lustre/attribute.{class, href, id, src}
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{a, body, footer, img, nav, p, span}
import lustre_http
import modem
import shared.{type Post, type PostComment, type Tag, Post, PostComment, Tag}

pub fn main() {
  lustre.application(init, update, view)
  |> lustre.start("#app", Nil)
}

fn init(_) -> #(Model, Effect(Msg)) {
  #(
    Model(
      route: get_route(),
      inviter: "",
      auth_user: None,
      sign_up_username: "",
      sign_up_email: "",
      sign_up_password: "",
      sign_up_error: None,
      login_email_username: "",
      login_password: "",
      login_error: None,
      create_post_title: "",
      create_post_href: "",
      create_post_body: "",
      create_post_original_creator: False,
      create_post_tags: [],
      create_post_use_body: False,
      create_post_error: None,
      posts: [],
      show_post: None,
      create_comment_body: "",
      create_comment_parent_id: None,
      create_comment_error: None,
      tags: [],
      invite_link: None,
      forgot_password_response: None,
      change_password_target: "",
    ),
    effect.batch(
      [modem.init(on_url_change), get_auth_user(), get_posts()]
      |> list.append(case get_route() {
        ShowPost(_) -> [get_show_post()]
        Signup(_) -> [get_inviter(get_auth_code())]
        ChangePassword(token) -> [get_change_password_target(token)]
        _ -> []
      }),
    ),
  )
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    OnRouteChange(route) -> #(
      Model(
        ..model,
        route: route,
        show_post: case route {
          ShowPost(_) -> None
          _ -> model.show_post
        },
      ),
      case route {
        ShowPost(_) -> get_show_post()
        CreatePost ->
          case model.tags {
            [] -> get_tags()
            _ -> effect.none()
          }
        _ -> effect.none()
      },
    )
    InviterRecieved(auth_code_result) ->
      case auth_code_result {
        Ok(res) -> #(Model(..model, inviter: res.username), effect.none())
        Error(_) -> #(model, effect.none())
      }
    AuthUserRecieved(auth_user_result) ->
      case auth_user_result {
        Ok(auth_user) -> #(Model(..model, auth_user: Some(auth_user)), case
          get_route()
        {
          CreatePost ->
            case uri.parse("/create-post") {
              Ok(uri) ->
                effect.from(fn(dispatch) {
                  on_url_change(uri)
                  |> dispatch
                })
              Error(_) -> effect.none()
            }
          _ -> effect.none()
        })
        Error(_) -> #(model, effect.none())
      }
    PostsRecieved(get_posts_result) ->
      case get_posts_result {
        Ok(get_posts) -> #(
          Model(..model, posts: get_posts.posts),
          effect.none(),
        )
        Error(_) -> #(model, effect.none())
      }
    ShowPostRecieved(get_post_result) ->
      case get_post_result {
        Ok(get_post) -> #(
          Model(..model, show_post: Some(get_post)),
          effect.none(),
        )
        Error(_) -> #(model, effect.none())
      }
    TagsRecieved(get_tags_result) ->
      case get_tags_result {
        Ok(get_tags) -> #(Model(..model, tags: get_tags.tags), effect.none())
        Error(_) -> #(model, effect.none())
      }

    SignUpUpdateUsername(value) -> #(
      Model(..model, sign_up_username: value),
      effect.none(),
    )
    SignUpUpdateEmail(value) -> #(
      Model(..model, sign_up_email: value),
      effect.none(),
    )
    SignUpUpdatePassword(value) -> #(
      Model(..model, sign_up_password: value),
      effect.none(),
    )
    SignUpUpdateError(value) -> #(
      Model(..model, sign_up_error: value),
      effect.none(),
    )
    RequestSignUp -> #(model, signup(model))
    SignUpResponded(resp_result) ->
      case resp_result {
        Ok(resp) ->
          case resp.error {
            Some(err) -> #(
              model,
              effect.from(fn(dispatch) {
                dispatch(SignUpUpdateError(Some(err)))
              }),
            )
            None -> #(
              Model(
                ..model,
                sign_up_username: "",
                sign_up_email: "",
                sign_up_password: "",
                sign_up_error: None,
              ),
              effect.batch([
                modem.push("/", None, None),
                get_auth_user(),
                get_show_post(),
                get_posts(),
              ]),
            )
          }
        Error(_) -> #(
          model,
          effect.from(fn(dispatch) {
            dispatch(SignUpUpdateError(Some("HTTP Error")))
          }),
        )
      }

    LoginUpdateEmailUsername(value) -> #(
      Model(..model, login_email_username: value),
      effect.none(),
    )
    LoginUpdatePassword(value) -> #(
      Model(..model, login_password: value),
      effect.none(),
    )
    LoginUpdateError(value) -> #(
      Model(..model, login_error: value),
      effect.none(),
    )
    RequestLogin -> #(model, login(model))
    LoginResponded(resp_result) ->
      case resp_result {
        Ok(resp) ->
          case resp.error {
            Some(err) -> #(
              model,
              effect.from(fn(dispatch) { dispatch(LoginUpdateError(Some(err))) }),
            )
            None -> #(
              Model(
                ..model,
                login_email_username: "",
                login_password: "",
                login_error: None,
              ),
              effect.batch([
                modem.push("/", None, None),
                get_auth_user(),
                get_posts(),
                get_show_post(),
              ]),
            )
          }
        Error(_) -> #(
          model,
          effect.from(fn(dispatch) {
            dispatch(LoginUpdateError(Some("HTTP Error")))
          }),
        )
      }

    RequestLogout -> #(model, logout(model))
    LogoutResponded(_) -> #(
      Model(..model, auth_user: None),
      effect.batch([
        modem.push("/", None, None),
        get_posts(),
        get_show_post(),
        get_auth_user(),
      ]),
    )

    CreatePostUpdateTitle(value) -> #(
      Model(..model, create_post_title: value),
      effect.none(),
    )
    CreatePostUpdateHref(value) -> #(
      Model(..model, create_post_href: value),
      effect.none(),
    )
    CreatePostUpdateBody(value) -> #(
      Model(..model, create_post_body: value),
      effect.none(),
    )
    CreatePostUpdateOriginalCreator(value) -> #(
      Model(..model, create_post_original_creator: value),
      effect.none(),
    )
    CreatePostUpdateTags(tag_id) -> #(
      Model(
        ..model,
        create_post_tags: case list.contains(model.create_post_tags, tag_id) {
          True -> list.filter(model.create_post_tags, fn(tag) { tag != tag_id })
          False -> [tag_id, ..model.create_post_tags]
        },
      ),
      effect.none(),
    )
    CreatePostUpdateUseBody(value) -> #(
      Model(..model, create_post_use_body: value, create_post_href: ""),
      effect.none(),
    )
    CreatePostUpdateError(value) -> #(
      Model(..model, create_post_error: value),
      effect.none(),
    )
    RequestCreatePost -> #(model, create_post(model))
    CreatePostResponded(resp_result) ->
      case resp_result {
        Ok(resp) ->
          case resp.error {
            Some(err) -> #(
              model,
              effect.from(fn(dispatch) {
                dispatch(CreatePostUpdateError(Some(err)))
              }),
            )
            None -> #(
              Model(
                ..model,
                create_post_title: "",
                create_post_href: "",
                create_post_tags: [],
                create_post_error: None,
              ),
              effect.batch([modem.push("/", None, None), get_posts()]),
            )
          }
        Error(_) -> #(
          model,
          effect.from(fn(dispatch) {
            dispatch(CreatePostUpdateError(Some("HTTP Error")))
          }),
        )
      }

    RequestLikePost(post_id) -> #(model, like_post(post_id))
    LikePostResponded(_) -> #(model, case model.show_post {
      Some(_) -> get_show_post()
      None -> get_posts()
    })

    CreateCommentUpdateBody(body) -> #(
      Model(..model, create_comment_body: body),
      effect.none(),
    )
    CreateCommentUpdateParentId(value) -> #(
      Model(..model, create_comment_parent_id: value),
      effect.none(),
    )
    CreateCommentUpdateError(value) -> #(
      Model(..model, create_comment_error: value),
      effect.none(),
    )
    RequestCreateComment -> #(model, create_comment(model))
    CreateCommentResponded(resp_result) ->
      case resp_result {
        Ok(resp) ->
          case resp.error {
            Some(err) -> #(
              model,
              effect.from(fn(dispatch) {
                dispatch(CreateCommentUpdateError(Some(err)))
              }),
            )
            None -> #(
              Model(
                ..model,
                create_comment_parent_id: None,
                create_comment_body: "",
                create_comment_error: None,
              ),
              get_show_post(),
            )
          }
        Error(_) -> #(
          model,
          effect.from(fn(dispatch) {
            dispatch(CreatePostUpdateError(Some("HTTP Error")))
          }),
        )
      }

    RequestLikeComment(post_comment_id) -> #(
      model,
      like_comment(post_comment_id),
    )
    LikeCommentResponded(_) -> #(model, get_show_post())

    RequestCreateAuthCode -> #(model, create_auth_code())
    CreateAuthCodeResponded(resp_result) ->
      case resp_result {
        Ok(resp) ->
          case resp.message {
            Some(code) -> {
              set_clipboard(env.get_api_url() <> "/auth/signup/" <> code)
              #(
                Model(
                  ..model,
                  invite_link: Some(
                    env.get_api_url() <> "/auth/signup/" <> code,
                  ),
                ),
                effect.none(),
              )
            }
            None -> #(model, effect.none())
          }
        Error(_) -> #(model, effect.none())
      }

    RequestForgotPassword -> #(model, request_forgot_password(model))
    ForgotPasswordResponded(resp_result) ->
      case resp_result {
        Ok(resp) -> #(
          Model(
            ..model,
            login_email_username: "",
            forgot_password_response: case resp.message {
              Some(message) -> Some(Ok(message))
              None ->
                case resp.error {
                  Some(error) -> Some(Error(error))
                  None -> None
                }
            },
          ),
          effect.none(),
        )
        Error(_) -> #(
          Model(..model, forgot_password_response: Some(Error("HTTP Error"))),
          effect.none(),
        )
      }
    ChangePasswordTargetRecieved(target_response) ->
      case target_response {
        Ok(res) -> #(
          Model(..model, change_password_target: res.username),
          effect.none(),
        )
        Error(_) -> #(model, effect.none())
      }

    RequestChangePassword -> #(model, send_password_change(model))
    ChangePasswordResponded(resp_result) ->
      case resp_result {
        Ok(_) -> #(
          Model(..model, login_password: ""),
          modem.push("/auth/login", None, None),
        )
        Error(_) -> #(
          Model(..model, forgot_password_response: Some(Error("HTTP Error"))),
          effect.none(),
        )
      }
  }
}

fn on_url_change(uri: Uri) -> Msg {
  set_url(uri.path)
  OnRouteChange(get_route())
}

@external(javascript, "./ffi.mjs", "set_clipboard")
fn set_clipboard(text: String) -> String

@external(javascript, "./ffi.mjs", "get_route")
fn do_get_route() -> String

@external(javascript, "./ffi.mjs", "set_url")
fn set_url(url: String) -> String

fn get_route() -> Route {
  let uri = case do_get_route() |> uri.parse {
    Ok(uri) -> uri
    _ -> panic as "Invalid uri"
  }

  case uri.path |> uri.path_segments {
    [] -> Active
    ["auth", "login"] -> Login
    ["auth", "signup", auth_code] -> Signup(auth_code: auth_code)
    ["auth", "forgot-password"] -> ForgotPassword
    ["auth", "forgot-password", token] -> ChangePassword(token)
    ["create-post"] -> CreatePost
    ["user", username] -> UserPage(username)
    ["post", post_id] ->
      case int.parse(post_id) {
        Ok(id) -> ShowPost(id)
        Error(_) -> NotFound
      }
    _ -> NotFound
  }
}

fn request_forgot_password(model: Model) {
  lustre_http.post(
    env.get_api_url() <> "/api/auth/forgot-password",
    json.object([#("email", json.string(model.login_email_username))]),
    lustre_http.expect_json(message_error_decoder(), ForgotPasswordResponded),
  )
}

fn create_auth_code() {
  lustre_http.post(
    env.get_api_url() <> "/api/auth-code",
    json.object([]),
    lustre_http.expect_json(message_error_decoder(), CreateAuthCodeResponded),
  )
}

fn get_auth_code() -> String {
  let uri = case do_get_route() |> uri.parse {
    Ok(uri) -> uri
    _ -> panic as "Invalid uri"
  }

  case uri.path |> uri.path_segments {
    ["auth", "signup", auth_code] -> auth_code
    _ -> "1"
  }
}

fn get_forgot_password_token() -> String {
  let uri = case do_get_route() |> uri.parse {
    Ok(uri) -> uri
    _ -> panic as "Invalid uri"
  }

  case uri.path |> uri.path_segments {
    ["auth", "forgot-password", token] -> token
    _ -> "1"
  }
}

fn get_post_id() -> String {
  let uri = case do_get_route() |> uri.parse {
    Ok(uri) -> uri
    _ -> panic as "Invalid uri"
  }

  case uri.path |> uri.path_segments {
    ["post", post_id] -> post_id
    _ -> ""
  }
}

pub fn get_inviter(auth_code: String) -> Effect(Msg) {
  let url = env.get_api_url() <> "/api/auth-code/" <> auth_code
  let decoder =
    dynamic.decode1(UsernameResponse, dynamic.field("username", dynamic.string))

  lustre_http.get(url, lustre_http.expect_json(decoder, InviterRecieved))
}

pub fn get_change_password_target(token: String) -> Effect(Msg) {
  let url = env.get_api_url() <> "/api/auth/forgot-password/" <> token
  let decoder =
    dynamic.decode1(UsernameResponse, dynamic.field("username", dynamic.string))

  lustre_http.get(
    url,
    lustre_http.expect_json(decoder, ChangePasswordTargetRecieved),
  )
}

pub fn get_auth_user() -> Effect(Msg) {
  let url = env.get_api_url() <> "/api/auth/validate"

  let decoder =
    dynamic.decode3(
      AuthUser,
      dynamic.field("user_id", dynamic.int),
      dynamic.field("username", dynamic.string),
      dynamic.field("is_admin", dynamic.bool),
    )

  lustre_http.get(url, lustre_http.expect_json(decoder, AuthUserRecieved))
}

pub fn get_show_post() -> Effect(Msg) {
  let url = env.get_api_url() <> "/api/posts/" <> get_post_id()

  lustre_http.get(
    url,
    lustre_http.expect_json(
      fn(data) { decode.from(post_decoder(), data) },
      ShowPostRecieved,
    ),
  )
}

pub fn post_decoder() {
  decode.into({
    use id <- decode.parameter
    use title <- decode.parameter
    use href <- decode.parameter
    use body <- decode.parameter
    use likes <- decode.parameter
    use user_like_post <- decode.parameter
    use comments_count <- decode.parameter
    use comments <- decode.parameter
    use tags <- decode.parameter
    use username <- decode.parameter
    use original_creator <- decode.parameter
    use created_at <- decode.parameter

    Post(
      id,
      title,
      href,
      body,
      likes,
      user_like_post,
      comments_count,
      comments,
      tags,
      username,
      original_creator,
      created_at,
    )
  })
  |> decode.field("id", decode.int)
  |> decode.field("title", decode.string)
  |> decode.field("href", decode.optional(decode.string))
  |> decode.field("body", decode.optional(decode.string))
  |> decode.field("likes", decode.int)
  |> decode.field("user_like_post", decode.bool)
  |> decode.field("comments_count", decode.int)
  |> decode.field("comments", decode.list(comment_decoder()))
  |> decode.field("tags", decode.list(decode.string))
  |> decode.field("username", decode.string)
  |> decode.field("original_creator", decode.bool)
  |> decode.field("created_at", decode.int)
}

fn comment_decoder() {
  decode.into({
    use id <- decode.parameter
    use body <- decode.parameter
    use username <- decode.parameter
    use likes <- decode.parameter
    use user_like_post_comment <- decode.parameter
    use parent_id <- decode.parameter
    use created_at <- decode.parameter

    PostComment(
      id,
      body,
      username,
      likes,
      user_like_post_comment,
      parent_id,
      created_at,
    )
  })
  |> decode.field("id", decode.int)
  |> decode.field("body", decode.string)
  |> decode.field("username", decode.string)
  |> decode.field("likes", decode.int)
  |> decode.field("user_like_post_comment", decode.bool)
  |> decode.field("parent_id", decode.optional(decode.int))
  |> decode.field("created_at", decode.int)
}

pub fn get_posts() -> Effect(Msg) {
  let url = env.get_api_url() <> "/api/posts"

  let response_decoder =
    decode.into({
      use posts <- decode.parameter

      GetPostsResponse(posts)
    })
    |> decode.field("posts", decode.list(post_decoder()))

  lustre_http.get(
    url,
    lustre_http.expect_json(
      fn(data) { response_decoder |> decode.from(data) },
      PostsRecieved,
    ),
  )
}

pub fn tag_decoder() {
  decode.into({
    use id <- decode.parameter
    use name <- decode.parameter
    use category <- decode.parameter
    use permission <- decode.parameter

    Tag(
      id,
      name,
      category: shared.string_to_tag_category(category),
      permission: shared.string_to_tag_permission(permission),
    )
  })
  |> decode.field("id", decode.int)
  |> decode.field("name", decode.string)
  |> decode.field("category", decode.string)
  |> decode.field("permission", decode.string)
}

pub fn get_tags() -> Effect(Msg) {
  let url = env.get_api_url() <> "/api/tags"

  let response_decoder =
    decode.into({
      use tags <- decode.parameter

      GetTagsResponse(tags)
    })
    |> decode.field("tags", decode.list(tag_decoder()))

  lustre_http.get(
    url,
    lustre_http.expect_json(
      fn(data) { response_decoder |> decode.from(data) },
      TagsRecieved,
    ),
  )
}

fn signup(model: Model) {
  lustre_http.post(
    env.get_api_url() <> "/api/users",
    json.object([
      #("username", json.string(model.sign_up_username)),
      #("email", json.string(model.sign_up_email)),
      #("password", json.string(model.sign_up_password)),
      #("auth_code", json.string(get_auth_code())),
    ]),
    lustre_http.expect_json(message_error_decoder(), SignUpResponded),
  )
}

fn logout(model _: Model) {
  lustre_http.post(
    env.get_api_url() <> "/api/auth/logout",
    json.object([]),
    lustre_http.expect_json(message_error_decoder(), LogoutResponded),
  )
}

fn create_post(model: Model) {
  lustre_http.post(
    env.get_api_url() <> "/api/posts",
    json.object([
      #("title", json.string(model.create_post_title)),
      #("original_creator", json.bool(model.create_post_original_creator)),
      case !model.create_post_use_body {
        True -> #("href", json.string(model.create_post_href))
        False -> #("body", json.string(model.create_post_body))
      },
      #("tags", json.array(model.create_post_tags, fn(tag) { json.int(tag) })),
    ]),
    lustre_http.expect_json(message_error_decoder(), CreatePostResponded),
  )
}

fn send_password_change(model: Model) {
  lustre_http.post(
    env.get_api_url()
      <> "/api/auth/change-password/"
      <> get_forgot_password_token(),
    json.object([#("password", json.string(model.login_password))]),
    lustre_http.expect_json(message_error_decoder(), ChangePasswordResponded),
  )
}

fn create_comment(model: Model) {
  let post_id = case model.show_post {
    Some(post) -> post.id |> int.to_string
    None -> panic as "Invalid state"
  }

  lustre_http.post(
    env.get_api_url() <> "/api/posts/" <> post_id <> "/comments",
    json.object([
      #("body", json.string(model.create_comment_body)),
      #("parent_id", case model.create_comment_parent_id {
        Some(parent_id) -> json.int(parent_id)
        None -> json.null()
      }),
    ]),
    lustre_http.expect_json(message_error_decoder(), CreateCommentResponded),
  )
}

pub fn view(model: Model) -> Element(Msg) {
  body(
    [
      class(
        "bg-[#fefefc] text-[#151515] w-[100vw] min-h-[100vh] h-[100vh] px-4 max-w-[800px] py-4 mx-auto flex flex-col h-screen gap-4",
      ),
      id("app"),
    ],
    [
      nav(
        [
          class(
            "text-sm font-bold text-neutral-700 h-[28px] flex justify-between items-center",
          ),
        ],
        [
          a([href("/"), class("flex group gap-2 items-center")], [
            img([
              src("https://gleam.run/images/lucy/lucy.svg"),
              attribute.alt("Lucy"),
              class("size-[18px] group-hover:animate-wiggle"),
            ]),
            p([class("group-hover:underline")], [text("Latest")]),
          ]),
          case model.auth_user {
            None ->
              a([href("/auth/login"), class("hover:underline")], [text("Login")])
            Some(auth_user) ->
              span([class("flex gap-2 items-center")], [
                a(
                  [
                    class("font-normal"),
                    button_class(),
                    class("hover:bg-[#584355]/80"),
                    href("/create-post"),
                  ],
                  [text("Post")],
                ),
                a(
                  [
                    class("hover:underline"),
                    href("/user/" <> auth_user.username),
                  ],
                  [text(auth_user.username)],
                ),
              ])
          },
        ],
      ),
      html.main([class("mb-auto")], [
        case model.route, model.auth_user {
          Active, _ -> latest_view(model)
          Login, _ -> login_view(model)
          Signup(auth_code), _ -> signup_view(model, auth_code)
          ForgotPassword, _ -> forgot_password(model)
          ChangePassword(_), _ -> change_password(model)
          CreatePost, Some(_) -> create_post_view(model)
          ShowPost(_), _ -> show_post_view(model)
          UserPage(_), Some(_) -> user_view(model)
          NotFound, _ -> text("404 Not found")
          _, _ -> text("404 Not found")
        },
      ]),
      footer([class("text-center text-neutral-500 text-xs pb-2")], [
        text("Made with <3 by the community, contribute on "),
        a(
          [
            href("https://github.com/dinkelspiel/kirakira"),
            class("hover:underline text-neutral-700 font-bold"),
          ],
          [text("GitHub")],
        ),
      ]),
    ],
  )
}
