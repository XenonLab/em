#!/bin/bash

em() {

	if [ -z "${EM_HOME}" ]; then
		__em_usage 'EM_HOME is not set'
		return 1
	fi

	if [ ! -d "${EM_HOME}" ]; then
		__em_usage "${EM_HOME} is not a directory"
		return 1
	fi

	if [ "$#" -eq "0" ]; then
		__em_usage
		return 0
	fi

	local command="$1"
	shift


	case "${command}" in
		get|set)
			if [ $# -gt 1 ]; then
				__em_usage "Too many arguments to [em ${command}]"
				return 1
			fi
			;;

		unset|refresh|list|help)
			if [ $# -ne 0 ]; then
				__em_usage "Too many arguments to [em ${command}]"
				return 1
			fi
			;;

		*)
			__em_usage "Unknown option: ${command}"
			return 1
			;;
	esac


	case "${command}" in
		get)
			__em_get "$1"
			;;

		set)
			__em_set "$1"
			;;

		unset)
			__em_set
			;;

		refresh)
			__em_set "${__EM_CURRENT_ENV}"
			;;

		list)
			__em_list
			;;

		help)
			__em_usage
			;;

		*)
			__em_usage "Unknown option: ${command}"
			return 1
			;;
	esac
}


# Print usage
__em_usage() {

	if [ -n "$1" ]; then
		echo "$1"
		echo ""
	fi

	cat <<-'EOF'
		em - Environment Manager v1.0.0

		Usage

		em list           : List available environments
		em get [FORMAT]   : Show the current environment. If a format string
		                        containing %s is provided, then printf the environment
		                        using it
		em set [ENVNAME]  : Unset the current environment if one is set. Then, if
		                        ENVNAME is provided, set the current environment to
		                        ENVNAME
		em unset          : Calls em set with no environment.
		em refresh        : Unsets and then sets the current environment.
		em help           : Show this usage message
	EOF
}


# Prints the name of the current environment
# If given an argument, it will printf the current environment with the argument as the format string
# If no environment is currently set, prints nothing
__em_get() {
	if [ -n "${__EM_CURRENT_ENV}" -a -n "$1" ]; then
		printf "$1" "${__EM_CURRENT_ENV}"
	elif [ -n "${__EM_CURRENT_ENV}" ]; then
		echo "${__EM_CURRENT_ENV}"
	fi
}


# Prints all available environments, 1 per line, sorted
__em_list() {
	__em_list_unsorted | sort
}


# Prints all available environments, 1 per line
__em_list_unsorted() {
	for f in $(find ${EM_HOME} -name '*.env' -o -name '*.sh' -o -name '*.bash'); do
		f=$(basename $f)
		printf "${f%.*}\n"
	done
}


# Sets the environment to the name provided. If no argument is provided, it will just
# unset the current environment
__em_set() {

	if [ -n "${__EM_CURRENT_ENV}" ]; then
		echo "Unsetting environment: ${__EM_CURRENT_ENV}"

		for key in ${__EM_CURRENT_ENV_VARS}; do
			echo "    - unsetting ${key}"
			unset "${key}"
		done

		unset __EM_CURRENT_ENV
		unset __EM_CURRENT_ENV_VARS
	fi

	if [ -n "${1}" ]; then

		local env_name=${1}
		local env_file

		echo "Setting environment: ${env_name}"

		env_file=$(__em_locate_env "${env_name}")

		if [ "${?}" -eq "1" ]; then
			echo "Could not find environment file for ${env_name} in ${EM_HOME}"
			return 1
		fi

		__em_validate_env "${env_file}"

		if [ "${?}" -eq "1" ]; then
			return 1
		fi

		__EM_CURRENT_ENV_VARS=""

		for key in $(cat "${env_file}" | grep "^export " | sed -e 's/export //' | cut -d '=' -f 1); do
			echo "    - setting ${key}"
			__EM_CURRENT_ENV_VARS="${__EM_CURRENT_ENV_VARS} ${key}"
		done

		source "${env_file}"
		export __EM_CURRENT_ENV="${env_name}"
		export __EM_CURRENT_ENV_VARS

	fi
}


# Locates an environment file from an environment name
__em_locate_env() {

	if [ -z "${1}" ]; then
		return 1
	fi

	local env_name="${1}"

	for exten in .env .sh .bash; do
		if [ -f "${EM_HOME}/${env_name}${exten}" ]; then
			echo "${EM_HOME}/${env_name}${exten}"
			return 0
		fi
	done

	return 1
}


# Validates an envirnoment file
__em_validate_env() {

	if [ -z "${1}" ]; then
		echo "Please provide an environment file to validate"
		return 1
	fi

	local env_file="${1}"

	if [ ! -f "${env_file}" ]; then
		echo "The environment file \"${env_file}\" does not exist"
		return 1
	fi

	badlines=$(grep -v '^#' "${env_file}" |
	  grep -v '^[[:space:]]*$' |
	  grep -v '^export [A-Za-z_][A-Za-z0-9_]*=.*$')

	if [ "${?}" -eq "0" ]; then
		echo "The following lines are invalid in ${env_file}: "
		echo "${badlines}"
		return 1
	fi

	return 0
}


# Autocompletion for em
__em_autocomplete() {

	local opts=""

	if [ "$COMP_CWORD" -eq "1" ]; then

		opts="get set list help"

		if [ -n "${__EM_CURRENT_ENV}" ]; then
			opts="${opts} unset refresh"
		fi

	elif [ "$COMP_CWORD" -eq "2" -a "${COMP_WORDS[1]}" == "set" -a -n "${EM_HOME}" ]; then
		opts=$(__em_list_unsorted)
	fi

	COMPREPLY=( $(compgen -W "${opts}" -- ${COMP_WORDS[COMP_CWORD]}) )
	return 0
}


complete -F __em_autocomplete em
