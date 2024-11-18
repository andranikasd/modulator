# TODO: Build and Implement the "Modulator (BMD)" Project

## 1. Install Module

### 1.0 Base Utilities Setup
- [x] Create a logger utility:
  - [x] Implement `log_info` for standard logs.
  - [x] Implement `log_warning` for warnings.
  - [x] Implement `log_error` to log errors with detailed info.
- [x] Test the logger utility for various log levels.
- [x] Implement basic user input handling
- [x] Implement basic init function for bmd

### 1.1 Read Configuration File
- [x] Choose a configuration file format (e.g., `TOML`, `YAML`, or `JSON`).
- [x] Write a parser for the configuration file format:
  - [x] Read module name, version, and source URL from the file.
  - [x] Handle missing or incomplete fields (e.g., default to `main` branch).
  - [x] Validate configuration syntax.
- [x] Write a test configuration file and verify parsing.


### 1.2 Clone Repositories
- [x] Create a function to handle basic repository cloning:
  - [x] Clone a repository to a specified directory.
  - [x] Validate the success of the clone operation and handle failures.
- [x] Add repository tracking:
  - [x] Keep a list of cloned repositories in a metadata file.
  - [x] Check if a repository is already cloned before attempting to re-clone.
- [ ] Add repository update logic:
  - [ ] Pull updates for already cloned repositories.
  - [ ] Handle conflicts between local and remote changes.
- [ ] Integrate cloning logic with a version-based system:

### 1.3 Organize Cloned Files
- [x] Define a structured directory layout for storing modules:
  - Example:
    ```
    .modules/
    ├── module-name/
    │   ├── version/
    │   │   └── module files...
    │   └── current -> version
    ```
- [x] Implement logic to:
  - [x] Move cloned repositories into the appropriate directory.
  - [x] Create symlinks pointing `current` to the active version.
- [x] Test file organization with multiple modules and versions.

---

## 2. Manage Versions

### 2.1 Implement Version Control
- [ ] Write logic to:
  - [x] Store and manage specific versions of modules.
  - [ ] Update the `current` symlink to the active version.
- [ ] Add functionality to compare local and remote versions:
  - [ ] Fetch remote version details from tags or releases.
  - [ ] Determine if an update is needed based on version comparison.

### 2.2 Handle Version Conflicts
- [ ] Add logic to detect and handle multiple versions of the same module:
  - [x] Allow coexisting versions or override with user confirmation.
  - [ ] Log and resolve conflicts between module versions.

---

## 3. Load Modules

### 3.1 Dynamically Source Modules
- [ ] Write logic to load modules dynamically:
  - [ ] Source the `current` version of a module.
  - [ ] Ensure dependencies are resolved before sourcing.
- [ ] Validate the success of the sourcing operation and log errors.

### 3.2 Validate Module Imports
- [ ] Check if required modules are present and loaded.
- [ ] Display meaningful error messages for missing modules.

---

## 4. Command-Line Interface (CLI)

### 4.1 Basic CLI Features
- [ ] Create a `bmd` command-line interface:
  - [x] `install`: Install modules from repositories.
  - [ ] `update`: Update installed modules.
  - [x] `remove`: Remove a specific module or version.
  - [ ] `list`: List all installed modules and their versions.
  - [ ] `info`: Display details about a specific module.
- [ ] Implement help flags for each command.

### 4.2 CLI Enhancements
- [x] Add optional flags:
  - `--global`: Install globally in the user's home directory.
  - `--version`: Display the version of the `bmd` tool.
- [ ] Auto-completion needed ?

---

## 5. Error Handling

### 5.1 Graceful Failure Management
- [ ] Add error handling for:
  - [ ] Invalid repository URLs.
  - [ ] Missing or incomplete configuration files.
  - [ ] Failed cloning operations.
  - [ ] Incompatible module versions.
- [ ] Log detailed error messages for debugging.
- [ ] Return meaningful exit codes for CLI commands.

---

## 6. Testing

### 6.1 Test Installation Logic
- [ ] Test cloning modules:
  - [ ] Clone by branch, tag, and release.
  - [ ] Handle failed cloning gracefully.
- [ ] Test version management:
  - [ ] Install and activate specific versions.
  - [ ] Update modules to new versions.
- [ ] Test loading modules:
  - [ ] Verify that sourced modules work as expected.

### 6.2 Automate Testing
- [ ] Set up unit tests using Bash testing frameworks like [Bats](https://github.com/bats-core/bats-core).
- [ ] Create mock repositories for testing cloning logic.

---

## 7. Documentation

### 7.1 Write Documentation
- [ ] Document the configuration file format:
  - [ ] Provide examples for `JSON`, `TOML`, and `YAML`.
- [ ] Document the directory structure:
  - [ ] Explain where modules are stored and how versions are managed.
- [ ] Provide a CLI usage guide with examples.

### 7.2 Create a README File
- [ ] Include:
  - [ ] Project description and goals.
  - [ ] Installation instructions.
  - [ ] Example commands and outputs.
  - [ ] Contribution guidelines.

---

## 8. Advanced Features (Future Enhancements)
- [ ] Add support for private repositories using SSH keys or tokens.
- [ ] Implement dependency management between modules.
- [ ] Add auto-update functionality for global installations.
- [ ] Provide detailed logging for all CLI operations.
- [ ] Integrate with package managers for cross-environment sync.

---
