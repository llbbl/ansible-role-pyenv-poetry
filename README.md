# Role Name: pyenv-poetry

This role installs and configures pyenv and Poetry on Ubuntu and Debian systems.

## Installation

To install the `pyenv-poetry` role, run the following command:

```
ansible-galaxy role install llbbl.pyenv-poetry,0.3 -p roles/ --force
```

The command `ansible-galaxy role install llbbl.pyenv-poetry,0.1 -p roles/ --force` is used to install an Ansible role from Galaxy, which is a public repository for sharing and distributing Ansible roles.

Let's break down the command:

- `ansible-galaxy`: This is the command-line tool provided by Ansible for managing roles and collections.

- `role`: Specifies that you want to install a role (as opposed to a collection).

- `install`: Indicates that you want to install the specified role.

- `llbbl.pyenv-poetry`: Represents the namespace and name of the role you want to install. In this case, the role is named `pyenv-poetry` and belongs to the `llbbl` namespace on Galaxy.

- `,0.1`: Specifies the version of the role you want to install. In this example, version `0.1` is being installed.

- `-p roles/`: Specifies the path where the role should be installed. The `-p` option stands for "path." In this case, the role will be installed in a directory named `roles/` relative to the current directory.

- `--force`: This flag indicates that if the role already exists locally, it should be forcefully overwritten with the version being installed. Without this flag, if the role already exists, Ansible will prompt for confirmation before overwriting it.

So, when you run this command, Ansible Galaxy will download and install version `0.1` of the `llbbl.pyenv-poetry` role from Galaxy and place it in the `roles/` directory. If a previous version of the role already exists in that directory, it will be overwritten due to the `--force` flag.

After running this command, you can use the installed role in your Ansible playbooks by referencing it with the name `llbbl.pyenv-poetry`.

For example:

```yaml
- hosts: servers
  roles:
    - llbbl.pyenv-poetry
```

This will apply the tasks and configurations defined in the `llbbl.pyenv-poetry` role to the specified hosts.

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
        primary_user_account: root
        user_home_dir: /root
        install_poetry: true
```
