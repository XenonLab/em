#!/bin/bash

setup() {
	mkdir ./envs
	export EM_HOME='./envs'
}

teardown() {
	rmdir ./envs
}



test_returns_0() {
	em help > /dev/null; assertEquals "$?" "0"
}


test_prints_text() {
	local msg="$(em help)"
	[ -n "${msg}" ]; assertEquals "$?" "0"
}


test_fails_with_multiple_args() {
	em help foobar > /dev/null; assertNotEquals "$?" "0"
}


source ./em.bash
source ./test/bunit.shl -vc
runUnitTests
