# .env

Script for managing environment variables for multiple projects.

### Setup

- Put these files into the `~/.env` directory.
- Add `source ~/.env/env.bash` to your `.bash_profile`.
- Add environment files to `~/.env/envs` (See `~/.env/sample_envs` for examples).

### Usage

- Use `listenv` to list all available environments.
- Use `setenv ENVNAME` to set the current environment to `ENVNAME`. `setenv` with no arguments will just unset the current environment.
- Use the `getenv` command to check which environment is currently set. You can put `getenv` into your `PS1` in your `.bash_profile` to add the environment name to your terminal prompt.

