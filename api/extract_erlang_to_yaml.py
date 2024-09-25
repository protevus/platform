"""
This script extracts information from Erlang files and converts it to YAML format.
It processes Erlang files in a given source directory, extracts various components
such as module name, exports, imports, records, and functions, and then writes the
extracted information to YAML files in a specified destination directory.
"""
import os
import re
import yaml
from typing import Dict, List, Any

def parse_erlang_file(file_path: str) -> Dict[str, Any]:
    """
    Parse an Erlang file and extract its components.
    Args:
        file_path (str): Path to the Erlang file.
    Returns:
        Dict[str, Any]: A dictionary containing extracted information:
            - name: Name of the Erlang file (without extension)
            - module: Module name
            - exports: List of exported functions
            - imports: List of imported functions
            - records: List of record definitions
            - functions: List of function definitions
    """
    with open(file_path, 'r') as file:
        content = file.read()
    
    name = os.path.basename(file_path).split('.')[0]
    module = extract_module(content)
    exports = extract_exports(content)
    imports = extract_imports(content)
    records = extract_records(content)
    functions = extract_functions(content)
    
    return {
        "name": name,
        "module": module,
        "exports": exports,
        "imports": imports,
        "records": records,
        "functions": functions
    }

def extract_module(content: str) -> str:
    """Extract the module name from Erlang content."""
    module_pattern = r'-module\(([^)]+)\)'
    match = re.search(module_pattern, content)
    return match.group(1) if match else ""

def extract_exports(content: str) -> List[Dict[str, Any]]:
    """Extract exported functions from Erlang content."""
    export_pattern = r'-export\(\[(.*?)\]\)'
    exports = []
    for match in re.finditer(export_pattern, content):
        exports.extend(parse_function_exports(match.group(1)))
    return exports

def parse_function_exports(export_str: str) -> List[Dict[str, Any]]:
    """Parse exported function definitions."""
    function_pattern = r'(\w+)/(\d+)'
    return [{"name": match[0], "arity": int(match[1])} for match in re.findall(function_pattern, export_str)]

def extract_imports(content: str) -> List[Dict[str, Any]]:
    """Extract imported functions from Erlang content."""
    import_pattern = r'-import\(([^,]+),\s*\[(.*?)\]\)'
    imports = []
    for match in re.finditer(import_pattern, content):
        module = match.group(1)
        functions = parse_function_exports(match.group(2))
        imports.append({"module": module, "functions": functions})
    return imports

def extract_records(content: str) -> List[Dict[str, Any]]:
    """Extract record definitions from Erlang content."""
    record_pattern = r'-record\((\w+),\s*\{(.*?)\}\)'
    records = []
    for match in re.finditer(record_pattern, content):
        name = match.group(1)
        fields = [field.strip() for field in match.group(2).split(',')]
        records.append({"name": name, "fields": fields})
    return records

def extract_functions(content: str) -> List[Dict[str, Any]]:
    """Extract function definitions from Erlang content."""
    function_pattern = r'(\w+)\((.*?)\)\s*->(.*?)(?=\w+\(|\Z)'
    functions = []
    for match in re.finditer(function_pattern, content, re.DOTALL):
        name = match.group(1)
        params = [param.strip() for param in match.group(2).split(',')]
        body = match.group(3).strip()
        functions.append({
            "name": name,
            "parameters": params,
            "body": body
        })
    return functions

def convert_to_yaml(erlang_data: Dict[str, Any]) -> str:
    """Convert extracted Erlang data to YAML format."""
    return yaml.dump(erlang_data, sort_keys=False, default_flow_style=False)

def process_directory(source_dir: str, dest_dir: str):
    """
    Process all Erlang files in the source directory and its subdirectories,
    extract information, and save as YAML files in the destination directory.
    """
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.erl'):
                source_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_path, source_dir)
                dest_path = os.path.join(dest_dir, os.path.dirname(relative_path))
                os.makedirs(dest_path, exist_ok=True)
                
                erlang_data = parse_erlang_file(source_path)
                yaml_content = convert_to_yaml(erlang_data)
                
                yaml_file = os.path.join(dest_path, f"{os.path.splitext(file)[0]}.yaml")
                with open(yaml_file, 'w') as f:
                    f.write(yaml_content)

if __name__ == "__main__":
    source_directory = "/path/to/erlang/source/directory"
    destination_directory = "/path/to/yaml/destination/directory"
    process_directory(source_directory, destination_directory)
    print("Extraction and conversion completed.")
