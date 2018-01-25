# em - Environment Manager

`em` is a lightweight, pure bash application that helps you manage environment variable collections. Create environment files for different projects, and then switch between them with a single command.

Tested on both Debian and Mac.


## Installation

To install, run the following commands:

```
curl -sSfL https://github.com/XenonLab/releases/tag/v1.0.0/em.bash > ~/.em.bash
mkdir ~/.em
echo "source ~/.em.bash" >> ~/.bashrc
echo 'export EM_HOME="${HOME}/.em"' >> ~/.bashrc
```

This will:
- Download the em script to `~/.em.bash`
- Create a directory for storing all of your environment files called `~/.em/`.
- Source the em script every time you start a new shell.
- Set the `$EM_HOME` environment variable so that em knows where you are storing your environment variable collections.

The reason we need to source the script is because it sets environment variables. If you were to run em from a bin, it would run in a subshell and any envvars set wouldn't affect your current environment.

If you are using a mac, you probably also need to add the following lines to your `~/.bash_profile`:

```
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi
```


## Usage

First, you need to set up some environment variable collections for em to use. These are called environment files.

### Environment file setup

Place environment files in your `${EM_HOME}` directory (default is `~/.em`). Environment files should end in `.env`, `.sh` or `.bash`. A valid environment file is a shell script that contains only export statements and comments.

A sample valid environment file:

```
# A line containing comments

export FOO="bar"
export AWS_SECRET='abcdefg123'

# Quotes aren't necessary if the variable doesn't contain any weird characters.
export DB_NAME=tomcat

# Use shell quoting and expansion rules
export BAZ="${FOO} \"bar!\""

# ${FOO} won't be expanded here (single quotes)
export BZR='${FOO} "bar!"'

# You can even generate dynamic variables by running shell commands
export EC2_HOST="$(aws ec2 describe-instances --filters "Name=tag:id,Values=my-ec2" | jq -r '.Reservations[0].Instances[0].PublicDnsName')"
```


### em commands

em is used with several sub-commands. Note that all em commands support tab autocompletion.


### `em list`

List all of the environment collections that are in `${EM_HOME}`

```
$ ls ${EM_HOME}
jupiter.bash      mars.sh     mercury.bash     pluto.env     saturn.env
$ em list
jupiter
mars
mercury
pluto
saturn
```


### `em set [ENVNAME]`

Sets the current environment to `ENVNAME`. If there is already another environment set, it will unset all of its envvars first. It does this by storing a list of all environment variables that were set in another environment variable `${__EM_CURRENT_ENV_VARS}`. This means that even if the environment file is edited or deleted after being set, em can still unset the correct envvars.

```
$ echo "${AWS_KEY}"

$ em set jupiter
Setting environment: jupiter
    - setting AWS_KEY
    - setting AWS_SECRET
    - setting AWS_REGION
$ echo "${AWS_KEY}"
SLDH342HSDFKLJs
$ em set mars
Unsetting environment: jupiter
    - unsetting AWS_KEY
    - unsetting AWS_SECRET
    - unsetting AWS_REGION
Setting environment: mars
    - setting SPRING_DATASOURCE_URL
    - setting SPRING_DATASOURCE_USERNAME
    - setting SPRING_DATASOURCE_PASSWORD
$ echo "${AWS_KEY}"

$ echo "${SPRING_DATASOURCE_URL}"
jdbc:mysql:localhost/mars
```

`em set` with no arguments will unset the current environment, if one is set.

```
$ em set
Unsetting environment: mars
    - unsetting SPRING_DATASOURCE_URL
    - unsetting SPRING_DATASOURCE_USERNAME
    - unsetting SPRING_DATASOURCE_PASSWORD
```


### `em get [FORMAT]`

Prints the name of the current environment.

```
$ em get

$ em set mars
Setting environment: mars
    - setting AWS_KEY
    - setting AWS_SECRET
    - setting AWS_REGION
$ em get
mars
```

If a format string is provided, it will use it to printf the environment name.

```
$ em get
mars
$ em get '(%s)'
(mars)
```

A handy usage of `em get` is that you can integrate it into your command prompt. You can do this by calling `__em_get` (`em get` that fails silently) into your `PS1` environment variable. This is the motivation for the format string argument.

```
$ export PS1="$(__em_get '(%s) ')$ "
$ echo "Hello world"
Hello world
$ em set pluto
Setting environment: pluto
    - setting SPRING_DATASOURCE_URL
    - setting SPRING_DATASOURCE_USERNAME
    - setting SPRING_DATASOURCE_PASSWORD
(pluto) $ echo "Hello world"
Hello world
(pluto) $ em unset
Unsetting environment: pluto
    - unsetting SPRING_DATASOURCE_URL
    - unsetting SPRING_DATASOURCE_USERNAME
    - unsetting SPRING_DATASOURCE_PASSWORD
$ echo "Hello world"
Hello world
```


### `em unset`

`em unset` will unset the current environment, if one is set. Actually, this is just an alias for `em set` with no argument, which does the same thing.

```
$ em unset
Unsetting environment: mars
    - unsetting SPRING_DATASOURCE_URL
    - unsetting SPRING_DATASOURCE_USERNAME
    - unsetting SPRING_DATASOURCE_PASSWORD
```


### `em refresh`

An alias for `em set` with the currently set environment. So, unsets the current environment and then sets it again. Useful if you are tinkering with the environment file.


### `em help`

Print usage. `em` with no arguments will also do this.


## Contributing

`em` is an open-source project. Submit a pull request to contribute!


## Testing

To run tests, run `./test.bash`


## About Us

[XE.com Inc.][1] is The World's Trusted Currency Authority. Development of this project is led by the XE.com Inc. Development Team and supported by the open-source community.

[1]: http://www.xe.com
