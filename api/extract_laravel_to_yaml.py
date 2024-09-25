"""
This script extracts information from PHP files and converts it to YAML format.
It processes PHP files in a given source directory, extracts various components
such as dependencies, properties, methods, traits, and interfaces, and then
writes the extracted information to YAML files in a specified destination directory.
"""

import os
import re
import yaml
from typing import Dict, List, Any

def parse_php_file(file_path: str) -> Dict[str, Any]:
    """
    Parse a PHP file and extract its components.

    Args:
        file_path (str): Path to the PHP file.

    Returns:
        Dict[str, Any]: A dictionary containing extracted information:
            - name: Name of the PHP file (without extension)
            - class_comment: Comment for the class (if any)
            - dependencies: List of dependencies (use statements)
            - properties: List of class properties
            - methods: List of class methods
            - traits: List of traits used
            - interfaces: List of interfaces implemented
    """
    with open(file_path, 'r') as file:
        content = file.read()

    name = os.path.basename(file_path).split('.')[0]
    class_comment = extract_class_comment(content)
    dependencies = extract_dependencies(content)
    properties = extract_properties(content)
    methods = extract_methods(content)
    traits = extract_traits(content)
    interfaces = extract_interfaces(content)

    return {
        "name": name,
        "class_comment": class_comment,
        "dependencies": dependencies,
        "properties": properties,
        "methods": methods,
        "traits": traits,
        "interfaces": interfaces
    }

def extract_class_comment(content: str) -> str:
    """
    Extract the class-level comment from PHP content.

    Args:
        content (str): PHP file content.

    Returns:
        str: Extracted class comment or empty string if not found.
    """
    class_comment_pattern = r'/\*\*(.*?)\*/\s*class'
    match = re.search(class_comment_pattern, content, re.DOTALL)
    if match:
        return match.group(1).strip()
    return ""

def extract_dependencies(content: str) -> List[Dict[str, str]]:
    """
    Extract dependencies (use statements) from PHP content.

    Args:
        content (str): PHP file content.

    Returns:
        List[Dict[str, str]]: List of dictionaries containing dependency information:
            - name: Alias or class name
            - type: Always "class" for now (might need refinement)
            - source: Full namespace of the dependency
    """
    # Regex pattern to match use statements, capturing the full namespace and optional alias
    use_statements = re.findall(r'use\s+([\w\\]+)(?:\s+as\s+(\w+))?;', content)
    dependencies = []
    for use in use_statements:
        dep = {
            "name": use[1] if use[1] else use[0].split('\\')[-1],
            "type": "class",  # Assuming class for now, might need refinement
            "source": use[0]
        }
        dependencies.append(dep)
    return dependencies

def extract_properties(content: str) -> List[Dict[str, Any]]:
    """
    Extract class properties and their comments from PHP content.

    Args:
        content (str): PHP file content.

    Returns:
        List[Dict[str, Any]]: List of dictionaries containing property information:
            - name: Property name (without $)
            - visibility: public, protected, or private
            - comment: Property comment (if any)
    """
    # Regex pattern to match property declarations with optional comments
    property_pattern = r'(?:/\*\*(.*?)\*/\s*)?(public|protected|private)\s+(?:static\s+)?(\$\w+)(?:\s*=\s*[^;]+)?;'
    properties = re.findall(property_pattern, content, re.DOTALL)
    return [
        {
            "name": prop[2][1:],
            "visibility": prop[1],
            "comment": prop[0].strip() if prop[0] else None
        } for prop in properties
    ]

def extract_methods(content: str) -> List[Dict[str, Any]]:
    """
    Extract class methods and their comments from PHP content.

    Args:
        content (str): PHP file content.

    Returns:
        List[Dict[str, Any]]: List of dictionaries containing method information:
            - name: Method name
            - visibility: public, protected, or private
            - parameters: List of parameter dictionaries
            - comment: Method comment (if any)
    """
    # Regex pattern to match method declarations with optional comments
    method_pattern = r'(?:/\*\*(.*?)\*/\s*)?(public|protected|private)\s+(?:static\s+)?function\s+(\w+)\s*\((.*?)\)'
    methods = re.findall(method_pattern, content, re.DOTALL)
    parsed_methods = []
    for method in methods:
        parsed_methods.append({
            "name": method[2],
            "visibility": method[1],
            "parameters": parse_parameters(method[3]),
            "comment": method[0].strip() if method[0] else None
        })
    return parsed_methods

def parse_parameters(params_str: str) -> List[Dict[str, str]]:
    """
    Parse method parameters from a parameter string.

    Args:
        params_str (str): String containing method parameters.

    Returns:
        List[Dict[str, str]]: List of dictionaries containing parameter information:
            - name: Parameter name
            - default: Default value (if specified)
    """
    params = params_str.split(',')
    parsed_params = []
    for param in params:
        param = param.strip()
        if param:
            parts = param.split('=')
            param_dict = {"name": parts[0].split()[-1].strip('$')}
            if len(parts) > 1:
                param_dict["default"] = parts[1].strip()
            parsed_params.append(param_dict)
    return parsed_params

def extract_traits(content: str) -> List[str]:
    """
    Extract traits used in the PHP content.

    Args:
        content (str): PHP file content.

    Returns:
        List[str]: List of trait names used in the class.
    """
    return re.findall(r'use\s+([\w\\]+)(?:,\s*[\w\\]+)*;', content)

def extract_interfaces(content: str) -> List[str]:
    """
    Extract interfaces implemented by the class in the PHP content.

    Args:
        content (str): PHP file content.

    Returns:
        List[str]: List of interface names implemented by the class.
    """
    return re.findall(r'implements\s+([\w\\]+)(?:,\s*[\w\\]+)*', content)

def convert_to_yaml(php_data: Dict[str, Any]) -> str:
    """
    Convert extracted PHP data to YAML format.

    Args:
        php_data (Dict[str, Any]): Dictionary containing extracted PHP data.

    Returns:
        str: YAML representation of the PHP data.
    """
    def format_comment(comment: str) -> str:
        return '\n'.join('# ' + line.strip() for line in comment.split('\n'))

    formatted_data = {}
    for key, value in php_data.items():
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
    Process all PHP files in the source directory and its subdirectories,
    extract information, and save as YAML files in the destination directory.

    Args:
        source_dir (str): Path to the source directory containing PHP files.
        dest_dir (str): Path to the destination directory for YAML files.
    """
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.php'):
                source_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_path, source_dir)
                dest_path = os.path.join(dest_dir, os.path.dirname(relative_path))

                os.makedirs(dest_path, exist_ok=True)

                php_data = parse_php_file(source_path)
                yaml_content = convert_to_yaml(php_data)

                yaml_file = os.path.join(dest_path, f"{os.path.splitext(file)[0]}.yaml")
                with open(yaml_file, 'w') as f:
                    f.write(yaml_content)

if __name__ == "__main__":
    source_directory = "/home/platform/Devboxes/resources/laravel_framework/src/Illuminate/"
    destination_directory = "/home/platform/Devboxes/platform/api/"

    process_directory(source_directory, destination_directory)
    print("Extraction and conversion completed.")
