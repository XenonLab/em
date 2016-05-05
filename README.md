# em - Environment Manager

em is a script that helps you manage environment variables for different projects.


### Installation

Run the following commands:

```
curl -k https://gitlab.xe.com/etraikov/em/raw/master/em.bash > ~/.em.bash
mkdir ~/.em
echo "source ~/.em.bash" >> ~/.bashrc
echo 'export EM_HOME="${HOME}/.em"' >> ~/.bashrc
```

If you are using a mac, you will probably also need to add the following lines to your `.bash_profile`:

```
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi
```

### Environment file setup

Place environment files in your `${EM_HOME}` directory. Environment files should end in `.env`, `.sh` or `.bash`. A valid environment file is a shell script that contains only comments and export statement.

A valid environment file:

```
# A line containing comments

export FOO="bar"
export AWS_SECRET='abcdefg123'

# Quotes aren't necessary if the variable doesn't contain any weird characters.
export DB_NAME=tomcat

# Use shell quoting rules
export BAZ="${FOO} \"bar!\""

# ${FOO} won't be expanded here (single quotes)
export BZR='${FOO} "bar!"'
```



### Usage


#### `em list`

List all of the environments that are in `${EM_HOME}`

```
$ ls ${EM_HOME}
actioneconomics.bash      blender.sh     currinfoman.bash     marketingman.env     xeid.env
$ em list
actioneconomics
blender
currinfoman
marketingman
xeid
```

#### `em set [ENVNAME]`

Sets the current environment to `ENVNAME`.

```
$ echo "${AWS_KEY}"

$ em set blender
Setting environment: blender
    - setting AWS_KEY
    - setting AWS_SECRET
    - setting AWS_REGION
$ echo "${AWS_KEY}"
SLDH342HSDFKLJs
$ em set xeid
Unsetting environment: blender
    - unsetting AWS_KEY
    - unsetting AWS_SECRET
    - unsetting AWS_REGION
Setting environment: xeid
    - setting SPRING_DATASOURCE_URL
    - setting SPRING_DATASOURCE_USERNAME
    - setting SPRING_DATASOURCE_PASSWORD
$ echo "${AWS_KEY}"

$ echo "${SPRING_DATASOURCE_URL}"
jdbc:mysql:localhost/tomcat
```

`em set` with no arguments will unset the current environment, if one is set.

```
$ em set
Unsetting environment: xeid
    - unsetting SPRING_DATASOURCE_URL
    - unsetting SPRING_DATASOURCE_USERNAME
    - unsetting SPRING_DATASOURCE_PASSWORD
```


#### `em get [FORMAT]`

Prints the name of the current enviroment.

```
$ em get

$ em set blender
Setting environment: blender
    - setting AWS_KEY
    - setting AWS_SECRET
    - setting AWS_REGION
$ em get
blender
```

If a format string is provided, it will use it to printf the environment name.

```
$ em get
blender
$ em get '(%s)'
(blender)
```

#### `em unset`

An alias for `em set` with no arguments.


#### `em help`

Print usage.


### Environment name in your command prompt

The name of the current environment can be integrated into your command prompt by calling `__em_get` (`em get` that fails silently) into your `PS1`.

```
$ export PS1="$(__em_get '(%s) ')$ "
$ echo "Hello world"
Hello world
$ em set xeid
Setting environment: xeid
    - setting SPRING_DATASOURCE_URL
    - setting SPRING_DATASOURCE_USERNAME
    - setting SPRING_DATASOURCE_PASSWORD
(xeid) $ echo "Hello world"
Hello world
(xeid) $ em unset xeid
Unsetting environment: xeid
    - unsetting SPRING_DATASOURCE_URL
    - unsetting SPRING_DATASOURCE_USERNAME
    - unsetting SPRING_DATASOURCE_PASSWORD
$ echo "Hello world"
Hello world
```