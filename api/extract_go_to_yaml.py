"""
This script extracts information from Go files and converts it to YAML format.
It processes Go files in a given source directory, extracts various components
such as imports, structs, interfaces, and functions, and then writes the
extracted information to YAML files in a specified destination directory.
"""
import os
import re
import yaml
from typing import Dict, List, Any

def parse_go_file(file_path: str) -> Dict[str, Any]:
    """
    Parse a Go file and extract its components.
    Args:
        file_path (str): Path to the Go file.
    Returns:
        Dict[str, Any]: A dictionary containing extracted information:
            - name: Name of the Go file (without extension)
            - package: Package name
            - imports: List of import statements
            - structs: List of struct definitions
            - interfaces: List of interface definitions
            - functions: List of function definitions
    """
    with open(file_path, 'r') as file:
        content = file.read()
    
    name = os.path.basename(file_path).split('.')[0]
    package = extract_package(content)
    imports = extract_imports(content)
    structs = extract_structs(content)
    interfaces = extract_interfaces(content)
    functions = extract_functions(content)
    
    return {
        "name": name,
        "package": package,
        "imports": imports,
        "structs": structs,
        "interfaces": interfaces,
        "functions": functions
    }

def extract_package(content: str) -> str:
    """
    Extract the package name from Go content.
    """
    package_pattern = r'package\s+(\w+)'
    match = re.search(package_pattern, content)
    return match.group(1) if match else ""

def extract_imports(content: str) -> List[str]:
    """
    Extract import statements from Go content.
    """
    import_pattern = r'import\s*\((.*?)\)'
    match = re.search(import_pattern, content, re.DOTALL)
    if match:
        imports = re.findall(r'"(.+?)"', match.group(1))
        return imports
    return []

def extract_structs(content: str) -> List[Dict[str, Any]]:
    """
    Extract struct definitions from Go content.
    """
    struct_pattern = r'//\s*(.+?)?\n\s*type\s+(\w+)\s+struct\s*{([^}]+)}'
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
    field_pattern = r'(\w+)\s+(.+?)(?:`[^`]*`)?$'
    return [
        {"name": field[0], "type": field[1].strip()}
        for field in re.findall(field_pattern, fields_str, re.MULTILINE)
    ]

def extract_interfaces(content: str) -> List[Dict[str, Any]]:
    """
    Extract interface definitions from Go content.
    """
    interface_pattern = r'//\s*(.+?)?\n\s*type\s+(\w+)\s+interface\s*{([^}]+)}'
    interfaces = re.findall(interface_pattern, content, re.DOTALL)
    return [
        {
            "name": interface[1],
            "comment": interface[0].strip() if interface[0] else None,
            "methods": extract_interface_methods(interface[2])
        } for interface in interfaces
    ]

def extract_interface_methods(interface_content: str) -> List[Dict[str, Any]]:
    """
    Extract method signatures from an interface definition.
    """
    method_pattern = r'(\w+)\((.*?)\)\s*(.*?)(?:\s*//.*)?$'
    methods = re.findall(method_pattern, interface_content, re.MULTILINE)
    return [
        {
            "name": method[0],
            "parameters": parse_parameters(method[1]),
            "return_type": method[2].strip() if method[2] else None
        } for method in methods
    ]

def extract_functions(content: str) -> List[Dict[str, Any]]:
    """
    Extract function definitions from Go content.
    """
    function_pattern = r'//\s*(.+?)?\n\s*func\s+(\w+)\s*\((.*?)\)\s*(.*?)\s*{'
    functions = re.findall(function_pattern, content, re.DOTALL)
    return [
        {
            "name": function[1],
            "comment": function[0].strip() if function[0] else None,
            "receiver": extract_receiver(function[2]),
            "parameters": parse_parameters(function[2]),
            "return_type": function[3].strip() if function[3] else None
        } for function in functions
    ]

def extract_receiver(params_str: str) -> Dict[str, str]:
    """
    Extract the receiver from a method signature.
    """
    receiver_pattern = r'(\w+)\s+\*?(\w+)'
    match = re.match(receiver_pattern, params_str)
    if match:
        return {"name": match.group(1), "type": match.group(2)}
    return {}

def parse_parameters(params_str: str) -> List[Dict[str, str]]:
    """
    Parse function parameters from a parameter string.
    """
    params = params_str.split(',')
    parsed_params = []
    for param in params:
        param = param.strip()
        if param and not re.match(r'^\w+\s+\*?\w+$', param):  # Skip receiver
            parts = param.split()
            parsed_params.append({"name": parts[0], "type": ' '.join(parts[1:])})
    return parsed_params

def convert_to_yaml(go_data: Dict[str, Any]) -> str:
    """
    Convert extracted Go data to YAML format.
    """
    def format_comment(comment: str) -> str:
        return '\n'.join('# ' + line.strip() for line in comment.split('\n'))

    formatted_data = {}
    for key, value in go_data.items():
        if key in ['structs', 'interfaces', 'functions']:
            formatted_data[key] = [
                {**item, 'comment': format_comment(item['comment']) if item.get('comment') else None}
                for item in value
            ]
        else:
            formatted_data[key] = value

    return yaml.dump(formatted_data, sort_keys=False, default_flow_style=False)

def process_directory(source_dir: str, dest_dir: str):
    """
    Process all Go files in the source directory and its subdirectories,
    extract information, and save as YAML files in the destination directory.
    """
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.go'):
                source_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_path, source_dir)
                dest_path = os.path.join(dest_dir, os.path.dirname(relative_path))
                os.makedirs(dest_path, exist_ok=True)
                
                go_data = parse_go_file(source_path)
                yaml_content = convert_to_yaml(go_data)
                
                yaml_file = os.path.join(dest_path, f"{os.path.splitext(file)[0]}.yaml")
                with open(yaml_file, 'w') as f:
                    f.write(yaml_content)

if __name__ == "__main__":
    source_directory = "/path/to/go/source/directory"
    destination_directory = "/path/to/yaml/destination/directory"
    process_directory(source_directory, destination_directory)
    print("Extraction and conversion completed.")
