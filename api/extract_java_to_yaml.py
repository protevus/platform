"""
This script extracts information from Java files and converts it to YAML format.
It processes Java files in a given source directory, extracts various components
such as package, imports, class info, fields, methods, and interfaces, and then
writes the extracted information to YAML files in a specified destination directory.
"""
import os
import re
import yaml
from typing import Dict, List, Any

def parse_java_file(file_path: str) -> Dict[str, Any]:
    """
    Parse a Java file and extract its components.
    Args:
        file_path (str): Path to the Java file.
    Returns:
        Dict[str, Any]: A dictionary containing extracted information:
            - name: Name of the Java file (without extension)
            - package: Package declaration
            - imports: List of import statements
            - class_info: Information about the class (name, modifiers, extends, implements)
            - class_comment: Comment for the class (if any)
            - fields: List of class fields
            - methods: List of class methods
            - interfaces: List of interfaces implemented
    """
    with open(file_path, 'r') as file:
        content = file.read()
    
    name = os.path.basename(file_path).split('.')[0]
    package = extract_package(content)
    imports = extract_imports(content)
    class_info = extract_class_info(content)
    class_comment = extract_class_comment(content)
    fields = extract_fields(content)
    methods = extract_methods(content)
    interfaces = extract_interfaces(content)
    
    return {
        "name": name,
        "package": package,
        "imports": imports,
        "class_info": class_info,
        "class_comment": class_comment,
        "fields": fields,
        "methods": methods,
        "interfaces": interfaces
    }

def extract_package(content: str) -> str:
    """Extract the package declaration from Java content."""
    package_pattern = r'package\s+([\w.]+);'
    match = re.search(package_pattern, content)
    return match.group(1) if match else ""

def extract_imports(content: str) -> List[str]:
    """Extract import statements from Java content."""
    import_pattern = r'import\s+([\w.]+);'
    return re.findall(import_pattern, content)

def extract_class_info(content: str) -> Dict[str, Any]:
    """Extract class information from Java content."""
    class_pattern = r'(public\s+)?(abstract\s+)?(final\s+)?class\s+(\w+)(\s+extends\s+\w+)?(\s+implements\s+[\w,\s]+)?'
    match = re.search(class_pattern, content)
    if match:
        return {
            "name": match.group(4),
            "modifiers": [mod for mod in [match.group(1), match.group(2), match.group(3)] if mod],
            "extends": match.group(5).split()[-1] if match.group(5) else None,
            "implements": match.group(6).split()[-1].split(',') if match.group(6) else []
        }
    return {}

def extract_class_comment(content: str) -> str:
    """Extract the class-level comment from Java content."""
    class_comment_pattern = r'/\*\*(.*?)\*/\s*(?:public\s+)?(?:abstract\s+)?(?:final\s+)?class'
    match = re.search(class_comment_pattern, content, re.DOTALL)
    return match.group(1).strip() if match else ""

def extract_fields(content: str) -> List[Dict[str, Any]]:
    """Extract class fields from Java content."""
    field_pattern = r'(?:/\*\*(.*?)\*/\s*)?(public|protected|private)\s+(?:static\s+)?(?:final\s+)?(\w+)\s+(\w+)(?:\s*=\s*[^;]+)?;'
    fields = re.findall(field_pattern, content, re.DOTALL)
    return [
        {
            "name": field[3],
            "type": field[2],
            "visibility": field[1],
            "comment": field[0].strip() if field[0] else None
        } for field in fields
    ]

def extract_methods(content: str) -> List[Dict[str, Any]]:
    """Extract class methods from Java content."""
    method_pattern = r'(?:/\*\*(.*?)\*/\s*)?(public|protected|private)\s+(?:static\s+)?(?:\w+\s+)?(\w+)\s+(\w+)\s*\((.*?)\)'
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
    """Parse method parameters from a parameter string."""
    params = params_str.split(',')
    parsed_params = []
    for param in params:
        param = param.strip()
        if param:
            parts = param.split()
            parsed_params.append({"type": parts[0], "name": parts[1]})
    return parsed_params

def extract_interfaces(content: str) -> List[str]:
    """Extract interfaces implemented by the class in the Java content."""
    interface_pattern = r'implements\s+([\w,\s]+)'
    match = re.search(interface_pattern, content)
    if match:
        return [interface.strip() for interface in match.group(1).split(',')]
    return []

def convert_to_yaml(java_data: Dict[str, Any]) -> str:
    """Convert extracted Java data to YAML format."""
    def format_comment(comment: str) -> str:
        return '\n'.join('# ' + line.strip() for line in comment.split('\n'))

    formatted_data = {}
    for key, value in java_data.items():
        if key == 'class_comment':
            formatted_data['class_comment'] = format_comment(value) if value else None
        elif key in ['fields', 'methods']:
            formatted_data[key] = [
                {**item, 'comment': format_comment(item['comment']) if item.get('comment') else None}
                for item in value
            ]
        else:
            formatted_data[key] = value

    return yaml.dump(formatted_data, sort_keys=False, default_flow_style=False)

def process_directory(source_dir: str, dest_dir: str):
    """
    Process all Java files in the source directory and its subdirectories,
    extract information, and save as YAML files in the destination directory.
    """
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.java'):
                source_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_path, source_dir)
                dest_path = os.path.join(dest_dir, os.path.dirname(relative_path))
                os.makedirs(dest_path, exist_ok=True)
                
                java_data = parse_java_file(source_path)
                yaml_content = convert_to_yaml(java_data)
                
                yaml_file = os.path.join(dest_path, f"{os.path.splitext(file)[0]}.yaml")
                with open(yaml_file, 'w') as f:
                    f.write(yaml_content)

if __name__ == "__main__":
    source_directory = "/path/to/java/source/directory"
    destination_directory = "/path/to/yaml/destination/directory"
    process_directory(source_directory, destination_directory)
    print("Extraction and conversion completed.")
