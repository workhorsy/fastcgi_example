// Copyright (c) 2022 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// This file is licensed under the MIT License
// https://github.com/workhorsy/fastcgi_example

import fcgi;
import std.string : format;

bool _is_production = false;

int main() {
	char[] request;
	char[] response;
	while (fcgi_accept(request)) {
		try {
			// Read the request header into the buffer
			response = cast(char[])"Content-Type: text/plain\r\n\r\nit worked!";
		} catch (Exception err) {
			response = cast(char[])"Content-Type: text/plain\r\n\r\n";
			if (!_is_production)
				response ~= cast(char[])"Error %s %s %s".format(err.msg, err.line, err.file);
			else
				response ~= cast(char[])"There was an error";
		}

		// Send the response
		fcgi_puts(response);
	}

	return 0;
}
