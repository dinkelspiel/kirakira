import lustre/attribute.{class}
import lustre/element/html.{div, text}

pub fn tag_view(name: String) {
  div(
    [
      class(
        "text-xs rounded-md text-neutral-700 bg-[#ffaff3]/50 border border-[#ffaff3] px-1 w-fit",
      ),
    ],
    [text(name)],
  )
}
