# Role Name: pyenv-poetry

This role installs and configures pyenv and Poetry on Ubuntu and Debian systems.

## Requirements

- Ubuntu or Debian operating system
- Ansible 2.9 or later

## Role Variables

The following variables are defined in `defaults/main.yml`:

- `pyenv_version` (default: "v2.4.0"): The version of pyenv to install.
- `python_version` (default: "3.10.14"): The version of Python to install using pyenv.

The following variables are required and should be set in your playbook or inventory:

- `user_home_dir`: The home directory of the user for whom pyenv and Poetry will be installed.
- `primary_user_account`: The username of the primary user account on the target system.

You can override these variables in your playbook or inventory to customize the versions of pyenv and Python.

## Dependencies

None.

## Example Playbook

Here's an example playbook that uses the `pyenv-poetry` role:

```yaml
- hosts: servers
  roles:
    - role: llbbl.pyenv-poetry
      vars:
        pyenv_version: "v2.4.0"
        python_version: "3.10.14"
```
