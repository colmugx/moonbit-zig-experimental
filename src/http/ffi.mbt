///|
pub extern "C" fn curl_get(url : String) -> String = "curl_get"

///|
pub extern "C" fn curl_post(url : String, body : String) -> String = "curl_post"

///|
pub extern "C" fn curl_put(url : String, body : String) -> String = "curl_put"

///|
pub extern "C" fn curl_delete(url : String) -> String = "curl_delete"
