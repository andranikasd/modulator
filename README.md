# BMD (Bash Module Manager) - Workflow Definition

## 1. What is a Module?
A module is a reusable **Bash project** stored in a **public Git repository**. Modules are designed to provide common functions, scripts, or configurations that can be easily integrated into other Bash scripts. A module must:
- Be stored in a Git repository (public).
- Be callable from Bash scripts after installation.
- Optionally support multiple versions.

---

## 2. Installing a Module
Modules can be installed using the `bmd` command. Installation supports the following formats:

### 2.1 Install from a Git Repository
```bash
bmd install https://github.com/username/module-repo.git as module-name
```

### 2.2 Install Locally
Install a module from a local directory:
```bash
bmd install --local /path/to/module as module-name
```

### 2.3 Global Installation
Install a module globally so it’s available system-wide:
```bash
bmd install https://github.com/username/module-repo.git as module-name --global
```

---

## 3. Tracking Installed Modules
Installed modules are tracked in a `modules.json` file located in the `.modules` directory of the user’s project or in the global `.modules` directory for global installations.

### Example `modules.json`
```json
[
  {
    "name": "logger",
    "version": "v1.0.0",
    "path": "/path/to/.modules/logger",
    "source": "https://github.com/username/logger.git"
  },
  {
    "name": "local-module",
    "version": "v0.1.0",
    "path": "/path/to/.modules/local-module",
    "source": "./local/path/to/module"
  }
]
```

---

## 4. Organizing Installed Modules
### Directory Structure
Modules are stored in a `.modules` directory in the root of the user’s project for local installations or in the user’s home directory for global installations.

Example structure:
```
.modules/
├── logger/
│   ├── v1.0.0/
│   │   └── logger.sh
│   └── current -> v1.0.0
├── local-module/
│   ├── v0.1.0/
│   │   └── module.sh
│   └── current -> v0.1.0
```

---

## 5. Updating Modules
Modules can be updated using the `bmd update` command. The update process includes:
1. Checking for changes in the remote repository.
2. Fetching new versions or tags (if available).
3. Updating the local copy of the module and the `modules.json` metadata.

Update command example:
```bash
bmd update logger
```

If no versioning system (tags/releases) exists in the repository, the tool will:
- Fetch the latest changes from the main branch.
- Increment the local version.

---

## 6. Global Installation
When using the `--global` flag:
- Modules are stored in `~/.modules/`.
- Scripts within the module are symlinked to a directory like `/usr/local/bin`, making them executable globally.

Global installation example:
```bash
bmd install https://github.com/username/logger.git as logger --global
```

---

## 7. Commands Overview
### Basic Commands
- `bmd install <repo-url> as <module-name> [--local|--global]`: Installs a module.
- `bmd update <module-name>`: Updates a module to the latest version.
- `bmd remove <module-name>`: Removes a module.
- `bmd list`: Lists all installed modules.
- `bmd info <module-name>`: Displays details about a module.

---

## 8. Error Handling
The tool includes robust error handling to:
- Validate repository URLs before installation.
- Check for conflicts between module names or versions.
- Handle network errors gracefully.
- Provide clear error messages and exit codes for failed installations or updates.

---

## 9. Additional Features
1. **Dependency Management:** Modules can specify dependencies in a `dependencies` field in their metadata.
2. **Auto-Update:** The tool can periodically check for updates to installed modules.
3. **Logging:** Logs can be enabled to debug module installations and updates.
4. **Compatibility Check:** Ensure modules are compatible with the user’s Bash environment.

---

## 10. Future Enhancements
- **Module Templates:** Provide templates for creating new modules.
- **Private Repositories:** Support private Git repositories using SSH keys or tokens.
- **Multi-Environment Support:** Allow users to sync installed modules across environments.
```
