import gleam/dynamic
import gleam/dynamic/decode

pub type LikeStatus {
  Like
  Neutral
}

pub fn like_status_decoder() {
  use decoded_string <- decode.then(decode.string)
  case decoded_string {
    "like" -> decode.success(Like)
    "neutral" -> decode.success(Neutral)
    _ -> decode.failure(Like, "LikeStatus")
  }
}

pub fn decode_like_status(data: dynamic.Dynamic) {
  let data = decode.run(data, like_status_decoder())
  // This comes from the database so we can confidentally assert here since the success is encoded in the schema
  let assert Ok(data) = data
  data
}

pub fn like_status_to_dynamic(data: LikeStatus) {
  case data {
    Like -> "like"
    Neutral -> "neutral"
  }
  |> dynamic.string
}
