#!/bin/bash

# Prints the name of the current environment
# If given an argument, it will printf the current environment with the argument as the format string
# If no environment is currently set, prints nothing
getenv() {
	if [ -n "${__CURRENT_ENV}" -a -n "${1}" ]; then
		printf "$1" "${__CURRENT_ENV}"
	elif [ -n "${__CURRENT_ENV}" ]; then
		echo "${__CURRENT_ENV}"
	fi
}



# Prints all available environments, 1 per line
listenv() {
	for f in ${HOME}/.env/envs/*.bash; do
		echo "$(basename ${f} .bash)"
	done
}



# Validates an envirnoment file
validateenv() {
	
	if [ -z "${1}" ]; then
		echo "Please provide an environment file to validate"
		return 1
	fi
	
	local env_file="${1}"
	
	if [ ! -f "${env_file}" ]; then
		echo "The environment file \"${env_file}\" does not exist"
		return 1
	fi

	local validation_pattern='^export [A-Za-z_][A-Za-z0-9_]*=.*'

	grep "^export " "${env_file}" | grep -v "${validation_pattern}" > /dev/null
	
	if [ "${?}" -eq "0" ]; then
		echo "The following lines are invalid in ${env_file}: "
		grep "^export " "${env_file}" | grep -v "${validation_pattern}"
		return 1
	fi
	
	return 0
}



# Sets the environment to the name provided. If no argument is provided, it will just 
# unset the current environment
setenv() {

	if [ -n "${__CURRENT_ENV}" ]; then
		echo "Unsetting environment: ${__CURRENT_ENV}"
		
		for key in ${__CURRENT_ENV_VARS}; do
			echo "    - unsetting ${key}"
			unset "${key}"	
		done
		
		unset __CURRENT_ENV
		unset __CURRENT_ENV_VARS
	fi

	if [ -n "${1}" ]; then
	
		local env_name=${1}
		local env_file="${HOME}/.env/envs/${env_name}.bash"

		echo "Setting environment: ${env_name}"

		validateenv "${env_file}"
		
		if [ "${?}" -eq "1" ]; then
			echo "Aborting"
			return 1
		fi
		
		__CURRENT_ENV_VARS=""
		
		for key in $(cat "${env_file}" | grep "^export " | sed -e 's/export //' | cut -d '=' -f 1); do
			echo "    - setting ${key}"	
			__CURRENT_ENV_VARS="${__CURRENT_ENV_VARS} ${key}"		
		done
		
		source "${env_file}"
		export __CURRENT_ENV="${env_name}"
		export __CURRENT_ENV_VARS
		
	fi
}


# Autocompletion for environments
__setenv_autocomplete() {
    if [ "$COMP_CWORD" -ne "1" ]; then
    	return 0
    fi

	local cur opts
	cur="${COMP_WORDS[COMP_CWORD]}"
    opts=$(listenv)
    
	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
	return 0
}


complete -F __setenv_autocomplete setenv
