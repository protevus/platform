"""
This script extracts information from C# files and converts it to YAML format.
It processes C# files in a given source directory, extracts various components
such as namespaces, classes, properties, methods, and interfaces, and then
writes the extracted information to YAML files in a specified destination directory.
"""
import os
import re
import yaml
from typing import Dict, List, Any

def parse_csharp_file(file_path: str) -> Dict[str, Any]:
    """
    Parse a C# file and extract its components.
    Args:
        file_path (str): Path to the C# file.
    Returns:
        Dict[str, Any]: A dictionary containing extracted information:
            - name: Name of the C# file (without extension)
            - namespace: Namespace of the class
            - class_comment: Comment for the class (if any)
            - using_statements: List of using statements
            - properties: List of class properties
            - methods: List of class methods
            - interfaces: List of interfaces implemented
    """
    with open(file_path, 'r') as file:
        content = file.read()
    
    name = os.path.basename(file_path).split('.')[0]
    namespace = extract_namespace(content)
    class_comment = extract_class_comment(content)
    using_statements = extract_using_statements(content)
    properties = extract_properties(content)
    methods = extract_methods(content)
    interfaces = extract_interfaces(content)
    
    return {
        "name": name,
        "namespace": namespace,
        "class_comment": class_comment,
        "using_statements": using_statements,
        "properties": properties,
        "methods": methods,
        "interfaces": interfaces
    }

def extract_namespace(content: str) -> str:
    """
    Extract the namespace from C# content.
    """
    namespace_pattern = r'namespace\s+([\w.]+)'
    match = re.search(namespace_pattern, content)
    return match.group(1) if match else ""

def extract_class_comment(content: str) -> str:
    """
    Extract the class-level comment from C# content.
    """
    class_comment_pattern = r'/\*\*(.*?)\*/\s*(?:public|internal)?\s*class'
    match = re.search(class_comment_pattern, content, re.DOTALL)
    return match.group(1).strip() if match else ""

def extract_using_statements(content: str) -> List[str]:
    """
    Extract using statements from C# content.
    """
    return re.findall(r'using\s+([\w.]+);', content)

def extract_properties(content: str) -> List[Dict[str, Any]]:
    """
    Extract class properties and their comments from C# content.
    """
    property_pattern = r'(?:/\*\*(.*?)\*/\s*)?(public|private|protected|internal)\s+(?:virtual\s+)?(\w+)\s+(\w+)\s*{\s*get;\s*set;\s*}'
    properties = re.findall(property_pattern, content, re.DOTALL)
    return [
        {
            "name": prop[3],
            "type": prop[2],
            "visibility": prop[1],
            "comment": prop[0].strip() if prop[0] else None
        } for prop in properties
    ]

def extract_methods(content: str) -> List[Dict[str, Any]]:
    """
    Extract class methods and their comments from C# content.
    """
    method_pattern = r'(?:/\*\*(.*?)\*/\s*)?(public|private|protected|internal)\s+(?:virtual\s+)?(\w+)\s+(\w+)\s*\((.*?)\)'
    methods = re.findall(method_pattern, content, re.DOTALL)
    parsed_methods = []
    for method in methods:
        parsed_methods.append({
            "name": method[3],
            "return_type": method[2],
            "visibility": method[1],
            "parameters": parse_parameters(method[4]),
            "comment": method[0].strip() if method[0] else None
        })
    return parsed_methods

def parse_parameters(params_str: str) -> List[Dict[str, str]]:
    """
    Parse method parameters from a parameter string.
    """
    params = params_str.split(',')
    parsed_params = []
    for param in params:
        param = param.strip()
        if param:
            parts = param.split()
            parsed_params.append({"type": parts[0], "name": parts[1]})
    return parsed_params

def extract_interfaces(content: str) -> List[str]:
    """
    Extract interfaces implemented by the class in the C# content.
    """
    interface_pattern = r'class\s+\w+\s*:\s*([\w,\s]+)'
    match = re.search(interface_pattern, content)
    if match:
        return [interface.strip() for interface in match.group(1).split(',')]
    return []

def convert_to_yaml(csharp_data: Dict[str, Any]) -> str:
    """
    Convert extracted C# data to YAML format.
    """
    def format_comment(comment: str) -> str:
        return '\n'.join('# ' + line.strip() for line in comment.split('\n'))

    formatted_data = {}
    for key, value in csharp_data.items():
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
    Process all C# files in the source directory and its subdirectories,
    extract information, and save as YAML files in the destination directory.
    """
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.cs'):
                source_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_path, source_dir)
                dest_path = os.path.join(dest_dir, os.path.dirname(relative_path))
                os.makedirs(dest_path, exist_ok=True)
                
                csharp_data = parse_csharp_file(source_path)
                yaml_content = convert_to_yaml(csharp_data)
                
                yaml_file = os.path.join(dest_path, f"{os.path.splitext(file)[0]}.yaml")
                with open(yaml_file, 'w') as f:
                    f.write(yaml_content)

if __name__ == "__main__":
    source_directory = "/path/to/csharp/source/directory"
    destination_directory = "/path/to/yaml/destination/directory"
    process_directory(source_directory, destination_directory)
    print("Extraction and conversion completed.")
