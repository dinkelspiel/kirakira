import cake/select.{type Select}
import cake/select as s
import cake/where as w
import decode
import gleam/json.{type Json}
import gleam/list
import gleam/result
import gmysql
import server/db.{list_to_tuple}
import shared.{
  type Tag, Tag, string_to_tag_category, string_to_tag_permission,
  tag_category_to_string, tag_permission_to_string,
}

pub type TagDbRow {
  TagDbRow(tag_id: Int, tag_name: String, tag_category: String)
}

pub fn get_tags_query() {
  s.new()
  |> s.selects([
    s.alias(s.col("tag.id"), "tag_id"),
    s.alias(s.col("tag.name"), "tag_name"),
    s.alias(s.col("tag.category"), "tag_category"),
    s.alias(s.col("tag.permission"), "tag_permission"),
  ])
  |> s.from_table("tag")
}

pub fn run_tags_query(select: Select, params: List(gmysql.Param)) {
  s.to_query(select)
  |> db.execute_read(params, fn(data) {
    decode.into({
      use tag_id <- decode.parameter
      use tag_name <- decode.parameter
      use tag_category <- decode.parameter
      use tag_permission <- decode.parameter

      Tag(
        id: tag_id,
        name: tag_name,
        category: string_to_tag_category(tag_category),
        permission: string_to_tag_permission(tag_permission),
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.string)
    |> decode.field(3, decode.string)
    |> decode.from(data |> list_to_tuple)
  })
}

pub fn get_tags() {
  get_tags_query()
  |> run_tags_query([])
}

pub fn tag_to_json(tag: Tag) -> Json {
  json.object([
    #("id", json.int(tag.id)),
    #("name", json.string(tag.name)),
    #("category", json.string(tag_category_to_string(tag.category))),
    #("permission", json.string(tag_permission_to_string(tag.permission))),
  ])
}

pub fn get_tag_by_id(tag_id: Int) -> Result(Tag, String) {
  use tags <- result.try(
    get_tags_query()
    |> s.where(w.eq(w.col("tag.id"), w.int(tag_id)))
    |> run_tags_query([gmysql.to_param(tag_id)])
    |> result.replace_error("Problem getting tag by id from database"),
  )

  tags
  |> list.first
  |> result.replace_error("No tag found when getting tag by id")
}
