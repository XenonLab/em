#!/bin/bash

setup() {
	mkdir ./envs
	export EM_HOME='./envs'

	cat > ./envs/aaa.bash <<-'EOF'
		export AAA='BBB'
		export BBB='CCC'
		export CCC='DDD'
	EOF

	cat > ./envs/bbb.sh <<-'EOF'
		export BBB='DDD'
		export CCC='EEE'
	EOF

	cat > ./envs/bash.sh <<-'EOF'
		export A='B'
		export C='D'
	EOF

	cat > ./envs/invalid_contents.env <<-'EOF'
		export A='B'
		foo='bar'
	EOF

	cat > ./envs/invalid_name.txt <<-'EOF'
		export A='B'
		export C='D'
	EOF
}

teardown() {
	em unset > /dev/null
	rm ./envs/*
	rmdir ./envs
}



test_em_get_no_env() {
	assertEquals "" "$(em get)"
	assertEquals "" "$(em get '%s')"
}


test_em_set_invalid_name() {
	em set foobar > /dev/null
	assertEquals "${?}" "1"

	em set invalud_name > /dev/null
	assertEquals "${?}" "1"
}


test_em_set_invalid_file() {
	em set invalid_contents > /dev/null
	assertEquals "${?}" "1"
}


test_em_get_multiple_args() {
	em get "(%s)" asdf > /dev/null
	assertEquals "${?}" "1"
}


test_em_set_multiple_args() {
	em set aaa foobar > /dev/null
	assertEquals "${?}" "1"
}


test_em_get_env() {
	em set aaa > /dev/null
	assertEquals 'aaa' "$(em get)"
}


test_em_get_env_format() {
	em set aaa > /dev/null
	assertEquals ' (zzzaaazzz) ' "$(em get ' (zzz%szzz) ')"
}


test_em_unset_get() {
	em set aaa > /dev/null
	em set > /dev/null
	assertEquals "" "$(em get)"
}


test_em_unset_get2() {
	em set aaa > /dev/null
	em unset > /dev/null
	assertEquals "" "$(em get)"
}


test_em_set_twice() {
	em set aaa > /dev/null
	em set bbb > /dev/null
	assertEquals 'bbb' "$(em get)"
}


test_em_set_values() {
	em set aaa > /dev/null
	assertEquals 'BBB' "${AAA}"
	assertEquals 'CCC' "${BBB}"
	assertEquals 'DDD' "${CCC}"
}


test_em_set_values2() {
	em set bbb > /dev/null
	[ -z ${AAA+x} ]; assertEquals "$?" "0"
	assertEquals 'DDD' "${BBB}"
	assertEquals 'EEE' "${CCC}"
}


test_em_set_values3() {
	em set aaa > /dev/null
	em set bbb > /dev/null

	[ -z ${AAA+x} ]; assertEquals "$?" "0"

	assertEquals 'DDD' "${BBB}"
	assertEquals 'EEE' "${CCC}"
}


test_em_set_values4() {
	em set aaa > /dev/null
	em set bash > /dev/null
	[ -z ${AAA+x} ]; assertEquals "$?" "0"
	[ -z ${BBB+x} ]; assertEquals "$?" "0"
	[ -z ${CCC+x} ]; assertEquals "$?" "0"
	assertEquals 'B' "${A}"
	assertEquals 'D' "${C}"
}


test_em_unset_clear() {
	local the_env="$(env)"

	em set aaa > /dev/null

	assertNotEquals "${the_env}" "$(env)"

	em set > /dev/null

	assertEquals "${the_env}" "$(env)"
}


test_em_set_change_file() {
	em set aaa > /dev/null

	cat > ./envs/aaa.bash <<-'EOF'
		export AAA='AAA'
		export DDD='DDD'
	EOF

	em set aaa > /dev/null

	assertEquals 'AAA' "${AAA}"
	assertEquals 'DDD' "${DDD}"
	[ -z ${BBB+x} ]; assertEquals "$?" "0"
	[ -z ${CCC+x} ]; assertEquals "$?" "0"
}


test_em_refresh_change_file() {
	em set aaa > /dev/null

	cat > ./envs/aaa.bash <<-'EOF'
		export AAA='AAA'
		export DDD='DDD'
	EOF

	em refresh > /dev/null

	assertEquals 'AAA' "${AAA}"
	assertEquals 'DDD' "${DDD}"
	[ -z ${BBB+x} ]; assertEquals "$?" "0"
	[ -z ${CCC+x} ]; assertEquals "$?" "0"
}


source ./em.bash
source ./test/bunit.shl -vc
runUnitTests
