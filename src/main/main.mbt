fn main {
  println("It Works!")

  println(@http.curl_get("https://jsonplaceholder.typicode.com/todos/1"))
}
