#!/bin/bash

setup() {
	mkdir ./envs
	export EM_HOME='./envs'
}

teardown() {
	rm -f ./envs/*
	rmdir ./envs
}


test_empty_home() {
	assertEquals "" "$(em list)"
}


test_invalid_home() {
	touch ${EM_HOME}/aaa.invalid
	touch ${EM_HOME}/bbb.txt
	touch ${EM_HOME}/ccc.md

	assertEquals "" "$(em list)"
}


test_valid_invalid_home() {
	touch ${EM_HOME}/aaa.bash
	touch ${EM_HOME}/bbb.sh
	touch ${EM_HOME}/ccc.env
	touch ${EM_HOME}/zzz.env

	assertEquals "aaa bbb ccc zzz" "$(echo $(em list))"
}


source ./em.bash
source ./test/bunit.shl -vc
runUnitTests
