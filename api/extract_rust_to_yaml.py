"""
This script extracts information from Rust files and converts it to YAML format.
It processes Rust files in a given source directory, extracts various components
such as dependencies, structs, impl blocks, traits, and functions, and then
writes the extracted information to YAML files in a specified destination directory.
"""
import os
import re
import yaml
from typing import Dict, List, Any

def parse_rust_file(file_path: str) -> Dict[str, Any]:
    """
    Parse a Rust file and extract its components.
    Args:
        file_path (str): Path to the Rust file.
    Returns:
        Dict[str, Any]: A dictionary containing extracted information:
            - name: Name of the Rust file (without extension)
            - module_comment: Comment for the module (if any)
            - dependencies: List of dependencies (use statements)
            - structs: List of struct definitions
            - impls: List of impl blocks
            - traits: List of trait definitions
            - functions: List of standalone functions
    """
    with open(file_path, 'r') as file:
        content = file.read()
    
    name = os.path.basename(file_path).split('.')[0]
    module_comment = extract_module_comment(content)
    dependencies = extract_dependencies(content)
    structs = extract_structs(content)
    impls = extract_impls(content)
    traits = extract_traits(content)
    functions = extract_functions(content)
    
    return {
        "name": name,
        "module_comment": module_comment,
        "dependencies": dependencies,
        "structs": structs,
        "impls": impls,
        "traits": traits,
        "functions": functions
    }

def extract_module_comment(content: str) -> str:
    """
    Extract the module-level comment from Rust content.
    """
    module_comment_pattern = r'^//!(.+?)(?=\n\S)'
    match = re.search(module_comment_pattern, content, re.DOTALL | re.MULTILINE)
    return match.group(1).strip() if match else ""

def extract_dependencies(content: str) -> List[str]:
    """
    Extract dependencies (use statements) from Rust content.
    """
    return re.findall(r'use\s+([\w:]+)(?:::\{.*?\})?;', content)

def extract_structs(content: str) -> List[Dict[str, Any]]:
    """
    Extract struct definitions from Rust content.
    """
    struct_pattern = r'///(.+?)?\n\s*pub struct (\w+)(?:<.*?>)?\s*\{([^}]+)\}'
    structs = re.findall(struct_pattern, content, re.DOTALL)
    return [
        {
            "name": struct[1],
            "comment": struct[0].strip() if struct[0] else None,
            "fields": extract_struct_fields(struct[2])
        } for struct in structs
    ]

def extract_struct_fields(fields_str: str) -> List[Dict[str, str]]:
    """
    Extract fields from a struct definition.
    """
    field_pattern = r'pub (\w+):\s*(.+)'
    return [
        {"name": field[0], "type": field[1].strip()}
        for field in re.findall(field_pattern, fields_str)
    ]

def extract_impls(content: str) -> List[Dict[str, Any]]:
    """
    Extract impl blocks from Rust content.
    """
    impl_pattern = r'impl(?:<.*?>)?\s+(\w+)\s*(?:for\s+(\w+))?\s*\{([^}]+)\}'
    impls = re.findall(impl_pattern, content, re.DOTALL)
    return [
        {
            "struct": impl[0],
            "trait": impl[1] if impl[1] else None,
            "methods": extract_methods(impl[2])
        } for impl in impls
    ]

def extract_methods(impl_content: str) -> List[Dict[str, Any]]:
    """
    Extract methods from an impl block.
    """
    method_pattern = r'///(.+?)?\n\s*pub fn (\w+)\s*\(([^)]*)\)(?:\s*->\s*([^{]+))?\s*\{'
    methods = re.findall(method_pattern, impl_content, re.DOTALL)
    return [
        {
            "name": method[1],
            "comment": method[0].strip() if method[0] else None,
            "parameters": parse_parameters(method[2]),
            "return_type": method[3].strip() if method[3] else None
        } for method in methods
    ]

def parse_parameters(params_str: str) -> List[Dict[str, str]]:
    """
    Parse method parameters from a parameter string.
    """
    params = params_str.split(',')
    parsed_params = []
    for param in params:
        param = param.strip()
        if param:
            parts = param.split(':')
            parsed_params.append({"name": parts[0].strip(), "type": parts[1].strip()})
    return parsed_params

def extract_traits(content: str) -> List[Dict[str, Any]]:
    """
    Extract trait definitions from Rust content.
    """
    trait_pattern = r'pub trait (\w+)(?:<.*?>)?\s*\{([^}]+)\}'
    traits = re.findall(trait_pattern, content, re.DOTALL)
    return [
        {
            "name": trait[0],
            "methods": extract_trait_methods(trait[1])
        } for trait in traits
    ]

def extract_trait_methods(trait_content: str) -> List[Dict[str, str]]:
    """
    Extract method signatures from a trait definition.
    """
    method_pattern = r'fn (\w+)\s*\(([^)]*)\)(?:\s*->\s*([^;]+))?;'
    methods = re.findall(method_pattern, trait_content)
    return [
        {
            "name": method[0],
            "parameters": parse_parameters(method[1]),
            "return_type": method[2].strip() if method[2] else None
        } for method in methods
    ]

def extract_functions(content: str) -> List[Dict[str, Any]]:
    """
    Extract standalone functions from Rust content.
    """
    function_pattern = r'///(.+?)?\n\s*pub fn (\w+)\s*\(([^)]*)\)(?:\s*->\s*([^{]+))?\s*\{'
    functions = re.findall(function_pattern, content, re.DOTALL)
    return [
        {
            "name": function[1],
            "comment": function[0].strip() if function[0] else None,
            "parameters": parse_parameters(function[2]),
            "return_type": function[3].strip() if function[3] else None
        } for function in functions
    ]

def convert_to_yaml(rust_data: Dict[str, Any]) -> str:
    """
    Convert extracted Rust data to YAML format.
    """
    def format_comment(comment: str) -> str:
        return '\n'.join('# ' + line.strip() for line in comment.split('\n'))

    formatted_data = {}
    for key, value in rust_data.items():
        if key == 'module_comment':
            formatted_data['module_comment'] = format_comment(value) if value else None
        elif key in ['structs', 'impls', 'traits', 'functions']:
            formatted_data[key] = [
                {**item, 'comment': format_comment(item['comment']) if item.get('comment') else None}
                for item in value
            ]
        else:
            formatted_data[key] = value

    return yaml.dump(formatted_data, sort_keys=False, default_flow_style=False)

def process_directory(source_dir: str, dest_dir: str):
    """
    Process all Rust files in the source directory and its subdirectories,
    extract information, and save as YAML files in the destination directory.
    """
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.rs'):
                source_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_path, source_dir)
                dest_path = os.path.join(dest_dir, os.path.dirname(relative_path))
                os.makedirs(dest_path, exist_ok=True)
                
                rust_data = parse_rust_file(source_path)
                yaml_content = convert_to_yaml(rust_data)
                
                yaml_file = os.path.join(dest_path, f"{os.path.splitext(file)[0]}.yaml")
                with open(yaml_file, 'w') as f:
                    f.write(yaml_content)

if __name__ == "__main__":
    source_directory = "/path/to/rust/source/directory"
    destination_directory = "/path/to/yaml/destination/directory"
    process_directory(source_directory, destination_directory)
    print("Extraction and conversion completed.")
