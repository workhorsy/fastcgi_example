#!/bin/bash
set -e
set +x


# Get the architecture
ARCH=`uname -m`
ARCH=${ARCH,,}
if [[ "$ARCH" == "x86_64" ]] || [[ "$ARCH" == "amd64" ]]; then
	ARCH='x86_64'
else
	echo "Unsupported architecture: $ARCH"
	exit
fi

# Get the OS
if [[ "$OSTYPE" == "linux"* ]]; then
	OS="linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
	OS="windows"
else
	echo "Unknown OS: $OSTYPE"
	exit
fi

source ~/dlang/ldc-1.28.1/activate

# Get settings for this OS
if [[ "$OS" == "linux" ]]; then
	EXE_EXT=""
	OBJ_EXT=".o"
	LIB_EXT=".a"
	LIB_PREFIX="lib"
	DC="ldc2"
elif [[ "$OS" == "windows" ]]; then
	EXE_EXT=".exe"
	OBJ_EXT=".obj"
	LIB_EXT=".lib"
	LIB_PREFIX=""
	DC="ldc2"
fi

clean() {
	set -x
	rm -rf -f build
	rm -f main
	rm -f main.exe
	set +x
}

run() {
	set -x
	gcc -g -c -Wall -Werror source/fcgi.c -o fcgi.o -lfcgi
	ar rcs clibs.a fcgi.o
	$DC -unittest -g -w -of app source/app.d source/fcgi.d -L clibs.a -L-lfcgi
	set +x
}

if [[ "$1" == "release" ]]; then
	release
elif [[ "$1" == "run" ]]; then
	run
elif [[ "$1" == "clean" ]]; then
	clean
else
	echo "./make.sh release"
	echo "./make.sh run"
	echo "./make.sh clean"
fi
