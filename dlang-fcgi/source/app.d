import dcgi;

mixin DCGI!my_cgi_function; // Custom function

@DisplayExceptions // Show exceptions directly on output
@MaxRequestBodyLength(1024) // Limit request body to 1kb
void my_cgi_function(Request request, Output output)
{
  output.status = 201; // Default is 200
  output.addHeader("content-type", "text/plain"); // Default is text/html
  output("Hello, world");

  if ("REQUEST_URI" in request.header)
    output("Uri:", request.header["REQUEST_URI"]);
}
