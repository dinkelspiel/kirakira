import birl

// HACK: birl.legible_difference gives assignment error sometimes under 1 minute
pub fn legible_difference(a: birl.Time, b: birl.Time) -> String {
  case birl.to_unix(a) - birl.to_unix(b) < 60 {
    True -> "<1 minute ago"
    False -> birl.legible_difference(a, b)
  }
}
