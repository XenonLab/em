#!/bin/bash

setup() {
	mkdir ./envs
	export EM_HOME='./envs'
}

teardown() {
	rmdir ./envs
}



test_fails_with_no_home() {
	unset EM_HOME
	em > /dev/null; assertNotEquals "$?" "0"
}


test_fails_with_home_not_dir() {
	export EM_HOME='./envs/aaa.bash'
	em > /dev/null; assertNotEquals "$?" "0"
}


test_success_with_home() {
	em > /dev/null; assertEquals "$?" "0"
}


test_fails_with_weird_arg() {
	em foobar > /dev/null; assertNotEquals "$?" "0"
}



source ./em.bash
source ./test/bunit.shl -vc
runUnitTests
