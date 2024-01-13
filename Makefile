# PHONY Targets declaration
.PHONY: help all install build test clean 

# Help target - Displays available commands with descriptions
help:
	@echo "\033[0;32mAvailable targets:\033[0m"
	@echo "install                - Install dependencies using the forge tool."
	@echo "build                  - Build using the forge tool." 
	@echo "test                   - Run tests using the forge tool."
	@echo "clean                  - Clean using the forge tool."
	@echo "help                   - Display this help message."


all: clean build

# Install Dependencies
install:
	forge install axelarnetwork/axelar-gmp-sdk-solidity@v5.5.2 --no-commit && forge install openzeppelin/openzeppelin-contracts@v5.0.0 --no-commit && forge install foundry-rs/forge-std@v1.7.1 --no-commit

# Build target   
build:
	@forge build

test:
	@forge test -vvvv
  
# Clean target
clean:
	@:; forge clean