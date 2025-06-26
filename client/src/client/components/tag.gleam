import lustre/attribute.{class}
import lustre/element/html.{label, text}

pub fn tag_view(name: String) {
  label(
    [
      class(
        "text-xs rounded-md text-neutral-700 bg-[#ffaff3]/50 border border-[#ffaff3] px-1 w-fit",
      ),
    ],
    [text(name)],
  )
}
