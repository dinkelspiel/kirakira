export function get_route() {
  return window.location.pathname;
}

export function set_url(url) {
  window.history.replaceState({}, null, url);
}

export function set_clipboard(text) {
  navigator.clipboard.writeText(text);
}
