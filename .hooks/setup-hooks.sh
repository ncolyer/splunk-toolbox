#!/bin/bash

# Copy custom hooks to the .git/hooks directory
cp .hooks/pre-commit .git/hooks/pre-commit

# Make sure the hook is executable
chmod +x .git/hooks/pre-commit