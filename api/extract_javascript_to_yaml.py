"""
This script extracts information from JavaScript files and converts it to YAML format.
It processes JavaScript files in a given source directory, extracts various components
such as imports, classes, properties, and methods, and then writes the extracted
information to YAML files in a specified destination directory.
"""
import os
import re
import yaml
from typing import Dict, List, Any

def parse_javascript_file(file_path: str) -> Dict[str, Any]:
    """
    Parse a JavaScript file and extract its components.
    Args:
        file_path (str): Path to the JavaScript file.
    Returns:
        Dict[str, Any]: A dictionary containing extracted information:
            - name: Name of the JavaScript file (without extension)
            - imports: List of import statements
            - class_comment: Comment for the class (if any)
            - class_name: Name of the class
            - properties: List of class properties
            - methods: List of class methods
    """
    with open(file_path, 'r') as file:
        content = file.read()
    
    name = os.path.basename(file_path).split('.')[0]
    imports = extract_imports(content)
    class_comment, class_name = extract_class_info(content)
    properties = extract_properties(content)
    methods = extract_methods(content)
    
    return {
        "name": name,
        "imports": imports,
        "class_comment": class_comment,
        "class_name": class_name,
        "properties": properties,
        "methods": methods
    }

def extract_imports(content: str) -> List[str]:
    """
    Extract import statements from JavaScript content.
    """
    import_pattern = r'import\s+.*?from\s+[\'"].*?[\'"];'
    return re.findall(import_pattern, content)

def extract_class_info(content: str) -> tuple:
    """
    Extract class comment and name from JavaScript content.
    """
    class_pattern = r'(/\*\*(.*?)\*/\s*)?class\s+(\w+)'
    match = re.search(class_pattern, content, re.DOTALL)
    if match:
        comment = match.group(2).strip() if match.group(2) else ""
        name = match.group(3)
        return comment, name
    return "", ""

def extract_properties(content: str) -> List[Dict[str, Any]]:
    """
    Extract class properties from JavaScript content.
    """
    property_pattern = r'(/\*\*(.*?)\*/\s*)?(static\s+)?(\w+)\s*=\s*'
    properties = re.findall(property_pattern, content, re.DOTALL)
    return [
        {
            "name": prop[3],
            "static": bool(prop[2]),
            "comment": prop[1].strip() if prop[1] else None
        } for prop in properties
    ]

def extract_methods(content: str) -> List[Dict[str, Any]]:
    """
    Extract class methods from JavaScript content.
    """
    method_pattern = r'(/\*\*(.*?)\*/\s*)?(static\s+)?(\w+)\s*\((.*?)\)\s*{'
    methods = re.findall(method_pattern, content, re.DOTALL)
    parsed_methods = []
    for method in methods:
        parsed_methods.append({
            "name": method[3],
            "static": bool(method[2]),
            "parameters": parse_parameters(method[4]),
            "comment": method[1].strip() if method[1] else None
        })
    return parsed_methods

def parse_parameters(params_str: str) -> List[str]:
    """
    Parse method parameters from a parameter string.
    """
    return [param.strip() for param in params_str.split(',') if param.strip()]

def convert_to_yaml(js_data: Dict[str, Any]) -> str:
    """
    Convert extracted JavaScript data to YAML format.
    """
    def format_comment(comment: str) -> str:
        return '\n'.join('# ' + line.strip() for line in comment.split('\n'))

    formatted_data = {}
    for key, value in js_data.items():
        if key == 'class_comment':
            formatted_data['class_comment'] = format_comment(value) if value else None
        elif key == 'properties':
            formatted_data['properties'] = [
                {**prop, 'comment': format_comment(prop['comment']) if prop['comment'] else None}
                for prop in value
            ]
        elif key == 'methods':
            formatted_data['methods'] = [
                {**method, 'comment': format_comment(method['comment']) if method.get('comment') else None}
                for method in value
            ]
        else:
            formatted_data[key] = value

    return yaml.dump(formatted_data, sort_keys=False, default_flow_style=False)

def process_directory(source_dir: str, dest_dir: str):
    """
    Process all JavaScript files in the source directory and its subdirectories,
    extract information, and save as YAML files in the destination directory.
    """
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.js'):
                source_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_path, source_dir)
                dest_path = os.path.join(dest_dir, os.path.dirname(relative_path))
                os.makedirs(dest_path, exist_ok=True)
                
                js_data = parse_javascript_file(source_path)
                yaml_content = convert_to_yaml(js_data)
                
                yaml_file = os.path.join(dest_path, f"{os.path.splitext(file)[0]}.yaml")
                with open(yaml_file, 'w') as f:
                    f.write(yaml_content)

if __name__ == "__main__":
    source_directory = "/path/to/javascript/source/directory"
    destination_directory = "/path/to/yaml/destination/directory"
    process_directory(source_directory, destination_directory)
    print("Extraction and conversion completed.")
