## Undisclosed Transfer

### Requirements

- [Foundry](https://getfoundry.sh/): Confirm installation by running `forge --version` and you should see a response like 
```bash
forge 0.2.0 (a839414 2023-10-26T09:23:16.997527000Z)
```
- [Make](https://www.gnu.org/software/make/): Confirm installation by running `make --version` and you should see a response like 
```bash
GNU Make 3.81
Copyright (C) 2006  Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty, not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

This program built for i386-apple-darwin11.3.0
```

### Installation

1. Clone the repository:

```bash
git clone https://github.com/veri5/undisclosed-transfer.git
```

2. Navigate into the project directory:

```bash
cd undisclosed-transfer
```

3. Install the dependencies:

```bash
make install
```

4. Build the project:

```bash
make all
```

5. Run project tests:

```bash
make test
```

# Usage

The repository provides a set of [Makefile](https://opensource.com/article/18/8/what-how-makefile) commands to facilitate common tasks:

- `make all` : Install dependencies, build, and update the project.
- `make install` : Install the dependencies.
- `make build` : Compile the contracts.
- `make test` : Run tests with increased verbosity.
- `make clean` : Clean any generated artifacts.
- `make help` : Display the help menu.