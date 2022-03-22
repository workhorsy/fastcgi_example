// Copyright (c) 2022 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// This file is licensed under the MIT License
// https://github.com/workhorsy/fastcgi_example

/*
#setup fcgi on ubuntu:

sudo apt-get install lighttpd php5-cgi
sudo lighty-enable-mod fastcgi
sudo /etc/init.d/lighttpd force-reload

# change the port in /etc/lighttpd/lighttpd.conf :
server.port               = 90

# change /etc/lighttpd/conf-available/10-fastcgi.conf :
fastcgi.server = ( "/" =>
	((
		"max-procs" => 1,
		"bin-path" => "/home/matt/fastcgi/application",
		"socket" => "/tmp/application.socket",
		"check-local" => "disable",
		"max-request-size" => 100000
	))
)

*/
import std.process;


int fcgi_accept() {
	return c_fcgi_accept();
}

// FIXME: Rename to fcgi_read_request_header
bool fcgi_accept(out char[] request) {
	// Just return false on no connections
	if(c_fcgi_accept() < 0)
		return false;

	// Get the request data from the fcgi server
	// These are called Standard CGI environment variables
	char[] REQUEST_METHOD = cast(char[])environment.get("REQUEST_METHOD");
	char[] REQUEST_URI = cast(char[])environment.get("REQUEST_URI");
	char[] HTTP_USER_AGENT = cast(char[])environment.get("HTTP_USER_AGENT");
	char[] HTTP_COOKIE = cast(char[])environment.get("HTTP_COOKIE");
	char[] REMOTE_ADDR = cast(char[])environment.get("REMOTE_ADDR");
	char[] HTTP_REFERER = cast(char[])environment.get("HTTP_REFERER");
	char[] HTTP_HOST = cast(char[])environment.get("HTTP_HOST");
	char[] CONTENT_LENGTH = cast(char[])environment.get("CONTENT_LENGTH");
	char[] CONTENT_TYPE = cast(char[])environment.get("CONTENT_TYPE");

	// Reconstruct the request
	request = REQUEST_METHOD ~ " " ~ REQUEST_URI ~ " HTTP/1.1\r\n";

	if(HTTP_HOST) request ~= "Host: " ~ HTTP_HOST ~ "\r\n";
	if(HTTP_USER_AGENT) request ~= "User-Agent: " ~ HTTP_USER_AGENT ~ "\r\n";
	if(HTTP_COOKIE) request ~= "Cookie: " ~ HTTP_COOKIE ~ "\r\n";
	if(REMOTE_ADDR) request ~= "Remove-Addr: " ~ REMOTE_ADDR ~ "\r\n";
	if(HTTP_REFERER) request ~= "Referer: " ~ HTTP_REFERER ~ "\r\n";
	if(CONTENT_TYPE) request ~= "Content-Type: " ~ CONTENT_TYPE ~ "\r\n";
	if(CONTENT_LENGTH) request ~= "Content-Length: " ~ CONTENT_LENGTH ~ "\r\n";

	request ~= "\r\n";

	return true;
}

// FIXME: Rename to fcgi_write_response
void fcgi_printf(char[] message) {
	c_fcgi_printf(message.ptr);
}

// FIXME: Rename to fcgi_read_request_body
void fcgi_get_stdin(char[] buffer) {
	c_fcgi_get_stdin(buffer.ptr, buffer.length);
}

void fcgi_write_stderr(char[] message) {
	c_fcgi_write_stderr(message.ptr, message.length);
}

void fcgi_puts(char[] message) {
	c_fcgi_puts(message.ptr);
}

private:

extern (C):

void c_fcgi_write_stderr(char* message, size_t length);
int c_fcgi_accept();
void c_fcgi_printf(char* message);
void c_fcgi_puts(char* message);
void c_fcgi_get_stdin(char* buffer, size_t len);
