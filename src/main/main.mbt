///|
fn main {
  let args = @sys.get_cli_args()
  let url = match args.get(1) {
    Some(url) => url
    None => ""
  }

  if url == "" {
    let tips =
      #| No request url.
      #|
      #| Usage:
      #|  moonbit_zig <url>
    println(tips)
    return
  }

  println("It Works! You've requested: \{url}")
  println(@http.curl_get(url))
}

///|
test "main/no_args" {
  let args_ = @sys.get_cli_args()
  inspect!(args_.length(), content="0")
}

///|
test "main/empty_url" {
  let args = ["moonbit_zig"]
  let url = match args.get(1) {
    Some(url) => url
    None => ""
  }
  inspect!(url, content="")
}

///|
test "main/with_url" {
  let args = ["moonbit_zig", "https://example.com"]
  let url = match args.get(1) {
    Some(url) => url
    None => ""
  }
  inspect!(url, content="https://example.com")
}
