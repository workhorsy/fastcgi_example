// Copyright (c) 2022 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// This file is licensed under the MIT License
// https://github.com/workhorsy/fastcgi_example

import helpers : Dictionary;

class Request {
	private bool _has_rendered = false;
	private bool _was_format_specified;
	private string _method = null;
	private string _uri = null;
	private string _format = null;
	private string _http_version = null;
	public Dictionary _params;
	public string[string] _fields;
	public string[string] _cookies;
	public string[string] _sessions;
	public uint _content_length = 0;

	public this(string method, string uri, string format, string http_version, Dictionary params, string[string] fields, string[string] cookies) {
		_method = method;
		_uri = uri;
		_format = format;
		_http_version = http_version;
		_params = params;
		_fields = fields;
		_cookies = cookies;
	}

	public this() {
		_params = new Dictionary();
	}

	public bool has_rendered() { return _has_rendered; }
	public bool was_format_specified() { return _was_format_specified; }
	public string method() { return _method; }
	public string uri() { return _uri; }
	public string format() { return _format; }
	public string http_version() { return _http_version; }
	public uint content_length() { return _content_length; }

	public void has_rendered(bool value) { _has_rendered = value; }
	public void was_format_specified(bool value) { _was_format_specified = value; }
	public void method(string value) { _method = value; }
	public void uri(string value) { _uri = value; }
	public void format(string value) { _format = value; }
	public void http_version(string value) { _http_version = value; }
	public void content_length(uint value) { _content_length = value; }
}
