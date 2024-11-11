#!/bin/bash

# Exit on error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_DIR="$PACKAGE_DIR/temp"
CONTRACTS_FILE="$TEMP_DIR/contracts.yaml"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print step information
print_step() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Ensure required commands are available
check_requirements() {
    print_step "Checking requirements"
    
    commands=("git" "dart" "pub")
    for cmd in "${commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is required but not installed."
            exit 1
        fi
    done
}

# Create necessary directories
setup_directories() {
    print_step "Setting up directories"
    
    mkdir -p "$TEMP_DIR"
    mkdir -p "$PACKAGE_DIR/lib/src/interfaces"
    mkdir -p "$PACKAGE_DIR/lib/src/implementations"
}

# Clone Python LangChain repository
clone_langchain() {
    print_step "Cloning Python LangChain repository"
    
    if [ -d "$TEMP_DIR/langchain" ]; then
        echo "Updating existing LangChain repository..."
        cd "$TEMP_DIR/langchain"
        git pull
    else
        echo "Cloning LangChain repository..."
        git clone https://github.com/langchain-ai/langchain.git "$TEMP_DIR/langchain"
    fi
}

# Extract contracts from Python code
extract_contracts() {
    print_step "Extracting contracts from Python code"
    
    cd "$PACKAGE_DIR"
    dart run "$SCRIPT_DIR/extract_contracts.dart" \
        --source "$TEMP_DIR/langchain/langchain" \
        --output "$CONTRACTS_FILE"
}

# Generate Dart code from contracts
generate_dart_code() {
    print_step "Generating Dart code from contracts"
    
    cd "$PACKAGE_DIR"
    dart run "$SCRIPT_DIR/generate_dart_code.dart" \
        --contracts "$CONTRACTS_FILE" \
        --output "$PACKAGE_DIR"
}

# Update package dependencies
update_dependencies() {
    print_step "Updating package dependencies"
    
    cd "$PACKAGE_DIR"
    
    # Ensure required dependencies are in pubspec.yaml
    if ! grep -q "yaml:" pubspec.yaml; then
        echo "
dependencies:
  yaml: ^3.1.0
  path: ^1.8.0
  args: ^2.3.0" >> pubspec.yaml
    fi
    
    dart pub get
}

# Create package exports file
create_exports() {
    print_step "Creating package exports"
    
    cat > "$PACKAGE_DIR/lib/langchain.dart" << EOL
/// LangChain for Dart
///
/// This is a Dart implementation of LangChain, providing tools and utilities
/// for building applications powered by large language models (LLMs).
library langchain;

// Export interfaces
export 'src/interfaces/llm.dart';
export 'src/interfaces/chain.dart';
export 'src/interfaces/prompt.dart';
export 'src/interfaces/memory.dart';
export 'src/interfaces/embeddings.dart';
export 'src/interfaces/document.dart';
export 'src/interfaces/vectorstore.dart';
export 'src/interfaces/tool.dart';
export 'src/interfaces/agent.dart';

// Export implementations
export 'src/implementations/llm.dart';
export 'src/implementations/chain.dart';
export 'src/implementations/prompt.dart';
export 'src/implementations/memory.dart';
export 'src/implementations/embeddings.dart';
export 'src/implementations/document.dart';
export 'src/implementations/vectorstore.dart';
export 'src/implementations/tool.dart';
export 'src/implementations/agent.dart';
EOL
}

# Main execution
main() {
    print_step "Starting LangChain setup"
    
    check_requirements
    setup_directories
    clone_langchain
    extract_contracts
    generate_dart_code
    update_dependencies
    create_exports
    
    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo "Next steps:"
    echo "1. Review generated code in lib/src/"
    echo "2. Implement TODOs in the generated classes"
    echo "3. Add tests for the implementations"
    echo "4. Update the documentation"
}

# Run main function
main
