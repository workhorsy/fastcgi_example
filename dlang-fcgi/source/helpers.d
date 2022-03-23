// Copyright (c) 2022 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// This file is licensed under the MIT License
// https://github.com/workhorsy/fastcgi_example

import fcgi;
import std.string : format;
import std.traits : isSomeString;
import std.digest.sha;

class Dictionary {
	public string value = null;
	public Dictionary[string] named_items = null;
	public Dictionary[size_t] array_items = null;

	/++
	Returns: the value associated with a string key.
	Params:
	 key = the associative array key as a string.
	+/
	public Dictionary opIndex(string key) {
		// Initialize the value if it does not exist.
		if ((key in this.named_items) == null)
			this.named_items[key] = new Dictionary();
		return this.named_items[key];
	}

	/++
	Returns: the value associated with a number key.
	Params:
	 key = the associative array key as a size_t.
	+/
	public Dictionary opIndex(size_t i) {
		if ((i in this.array_items) == null)
			this.array_items[i] = new Dictionary();
		return this.array_items[i];
	}

	/++
	Returns: true if the associative array uses the string key.
	Params:
	 key = the associative array key as a string.
	+/
	public bool has_key(string key) {
		return(this.named_items != null && (key in this.named_items) != null);
	}
}

bool pair(S)(S value, S separator, out S[] retval)
if (isSomeString!S) {
	import std.string : indexOf;
	auto i = value.indexOf(separator);
	if (i == -1) {
		return false;
	}


	S a = value[0 .. i];
	S b = value[i+separator.length .. $];
	retval = [a, b];
	return true;
}

S between(S)(S value, S before, S after)
if (isSomeString!S) {
	return split(split(value, before)[1], after)[0];
}

S before(S)(S value, S separator)
if (isSomeString!S) {
	import std.string : indexOf;
	auto i = indexOf(value, separator);

	if (i == -1)
		return value;

	return value[0 .. i];
}

S after(S)(S value, S separator)
if (isSomeString!S) {
	import std.string : indexOf;
	auto i = indexOf(value, separator);

	if (i == -1)
		return "";

	size_t start = i + separator.length;

	return value[start .. $];
}

S after_last(S)(S value, S separator)
if (isSomeString!S) {
	import std.string : indexOf;
	auto i = indexOf(value, separator);

	if (i == -1)
		return "";

	size_t start = i + separator.length;

	return value[start .. $];
}

bool contains(S)(S value, S match)
if (isSomeString!S) {
	import std.algorithm : find;
	if (value is null || value.length == 0)
		return false;
	if (match is null || match.length == 0)
		return false;

	S z = find(value, match);
	return find(value, match) != "";
}

char hex_to_char(char c) {
	int retval;
	if (c >= '0' && c <= '9')
		retval = c - '0';
	else if (c >= 'A' && c <= 'F')
		retval = c - 'A' + 10;
	else
		retval = c - 'a' + 10;

	return cast(char) retval;
}

char char_to_hex(char c) {
	int retval;
	if (c >= 0 && c <= 9)
		retval = c + '0';
	else if (c >= 10 && c <= 19)
		retval = c + 'A' - 10;
	else
		retval = c + 'a' - 10;

	return cast(char) retval;
}

char[] escape(char[] unescaped) {
	size_t len = unescaped.length;
	size_t i, j;

	// Get the length of the escaped string
	size_t newlen = 0;
	char c;
	for (i=0; i<len; ++i) {
		c = unescaped[i];
		if ((c >= '0' && c <= '9') ||
			(c >= 'A' && c <= 'Z') ||
			(c >= 'a' && c <= 'z') ||
			(c == ' ')) {
			++newlen;
		} else {
			newlen += 3;
		}
	}

	// Convert each char
	char[] escaped = new char[newlen];
	for (i=0; i<len; ++i) {
		c = unescaped[i];
		// Escape the normal value
		if ((c >= '0' && c <= '9') ||
			(c >= 'A' && c <= 'Z') ||
			(c >= 'a' && c <= 'z')) {
			escaped[j] = c;
			++j;
		// Escape the '+' value
		} else if (c == ' ') {
			escaped[j] = '+';
			++j;
		// Escape the '%FF' value
		} else {
			escaped[j] = '%';
			escaped[j+1] = char_to_hex(cast(char)((c & 0xF0) >> 4));
			escaped[j+2] = char_to_hex(c & 0x0F);
			j += 3;
		}
	}

	return escaped;
}

char[] unescape(char[] escaped) {
	import std.algorithm.searching : count;
	size_t i, j;

	// Get the length of the escaped and unescaped strings
	size_t len = escaped.length;
	size_t hexcount = count(escaped, "%");
	size_t newlen = len - (hexcount * 2);
	char[] unescaped = new char[newlen];

	// Convert each character
	for (i=0; i<newlen; ++i) {
		// Unescape the '%FF' value
		if (escaped[j] == '%') {
			unescaped[i] =
				cast(char) ((hex_to_char(escaped[j+1]) << 4) +
				hex_to_char(escaped[j+2]));
			j += 3;
		// Unescape the '+' value
		} else if (escaped[j] == '+') {
			unescaped[i] = ' ';
			++j;
		// Copy the normal value
		} else {
			unescaped[i] = escaped[j];
			++j;
		}
	}

	return unescaped;
}
