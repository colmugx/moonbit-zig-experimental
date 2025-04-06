///|
pub extern "C" fn curl_get(url : String) -> String = "zig_http_get"

///|
pub extern "C" fn curl_post(url : String, body : String) -> String = "zig_http_post"

///|
pub extern "C" fn curl_put(url : String, body : String) -> String = "zig_http_put"

///|
pub extern "C" fn curl_delete(url : String) -> String = "zig_http_delete"
