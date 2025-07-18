import gleam/dynamic
import gleam/dynamic/decode
import gleam/option.{type Option}

pub type Post {
  Post(
    id: Int,
    title: String,
    href: Option(String),
    body: Option(String),
    likes: Int,
    user_like_post: Bool,
    comments_count: Int,
    comments: List(PostComment),
    tags: List(String),
    username: String,
    original_creator: Bool,
    created_at: Int,
  )
}

pub type PostComment {
  PostComment(
    id: Int,
    body: String,
    username: String,
    likes: Int,
    user_like_post_comment: Bool,
    parent_id: Option(Int),
    created_at: Int,
  )
}

pub fn string_to_tag_category(category: String) {
  case category {
    "format" -> Format
    "genre" -> Genre
    "kirakira" -> Kirakira
    "platforms" -> Platforms
    "practices" -> Practices
    "tools" -> Tools
    _ -> {
      panic as "Invalid tag category"
    }
  }
}

pub fn tag_category_to_string(category: TagCategory) {
  case category {
    Format -> "format"
    Genre -> "genre"
    Kirakira -> "kirakira"
    Platforms -> "platforms"
    Practices -> "practices"
    Tools -> "tools"
  }
}

pub fn tag_category_decoder() {
  use decoded_string <- decode.then(decode.string)
  case decoded_string {
    "format" -> decode.success(Format)
    "genre" -> decode.success(Genre)
    "kirakira" -> decode.success(Kirakira)
    "platforms" -> decode.success(Platforms)
    "practices" -> decode.success(Practices)
    "tools" -> decode.success(Tools)
    _ -> decode.failure(Format, "Invalid tag category: " <> decoded_string)
  }
}

pub fn decode_tag_category(data: dynamic.Dynamic) {
  let data = decode.run(data, tag_category_decoder())
  // This comes from the database so we can confidentally assert here since the success is encoded in the schema
  let assert Ok(data) = data
  data
}

pub fn tag_permission_decoder() {
  use decoded_string <- decode.then(decode.string)
  case decoded_string {
    "member" -> decode.success(Member)
    "admin" -> decode.success(Admin)
    _ -> decode.failure(Member, "Invalid tag permission: " <> decoded_string)
  }
}

pub fn decode_tag_permission(data: dynamic.Dynamic) {
  let data = decode.run(data, tag_permission_decoder())
  // This comes from the database so we can confidentally assert here since the success is encoded in the schema
  let assert Ok(data) = data
  data
}

pub fn string_to_tag_permission(permission: String) {
  case permission {
    "member" -> Member
    "admin" -> Admin
    _ -> panic as "Invalid tag permission"
  }
}

pub fn tag_permission_to_string(permission: TagPermission) {
  case permission {
    Member -> "member"
    Admin -> "admin"
  }
}

pub const tag_categories = [
  Format,
  Genre,
  Kirakira,
  Platforms,
  Practices,
  Tools,
]

pub type TagCategory {
  Format
  Genre
  Kirakira
  Platforms
  Practices
  Tools
}

pub type TagPermission {
  Member
  Admin
}

pub type Tag {
  Tag(id: Int, name: String, category: TagCategory, permission: TagPermission)
}
