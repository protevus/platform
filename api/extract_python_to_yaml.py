"""
This script extracts information from Python files and converts it to YAML format.
It processes Python files in a given source directory, extracts various components
such as imports, classes, methods, and properties, and then writes the extracted
information to YAML files in a specified destination directory.
"""
import os
import re
import ast
import yaml
from typing import Dict, List, Any

def parse_python_file(file_path: str) -> Dict[str, Any]:
    """
    Parse a Python file and extract its components.
    Args:
        file_path (str): Path to the Python file.
    Returns:
        Dict[str, Any]: A dictionary containing extracted information:
            - name: Name of the Python file (without extension)
            - class_comment: Comment for the class (if any)
            - imports: List of import statements
            - classes: List of class information
    """
    with open(file_path, 'r') as file:
        content = file.read()
    
    tree = ast.parse(content)
    name = os.path.basename(file_path).split('.')[0]
    imports = extract_imports(tree)
    classes = extract_classes(tree)
    
    return {
        "name": name,
        "imports": imports,
        "classes": classes
    }

def extract_imports(tree: ast.AST) -> List[Dict[str, str]]:
    """
    Extract import statements from Python AST.
    Args:
        tree (ast.AST): Python abstract syntax tree.
    Returns:
        List[Dict[str, str]]: List of dictionaries containing import information:
            - name: Imported name
            - source: Module source
    """
    imports = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports.append({"name": alias.name, "source": alias.name})
        elif isinstance(node, ast.ImportFrom):
            module = node.module
            for alias in node.names:
                imports.append({"name": alias.name, "source": f"{module}.{alias.name}"})
    return imports

def extract_classes(tree: ast.AST) -> List[Dict[str, Any]]:
    """
    Extract class information from Python AST.
    Args:
        tree (ast.AST): Python abstract syntax tree.
    Returns:
        List[Dict[str, Any]]: List of dictionaries containing class information:
            - name: Class name
            - comment: Class docstring (if any)
            - bases: List of base classes
            - methods: List of method information
            - properties: List of class properties
    """
    classes = []
    for node in ast.walk(tree):
        if isinstance(node, ast.ClassDef):
            class_info = {
                "name": node.name,
                "comment": ast.get_docstring(node),
                "bases": [base.id for base in node.bases if isinstance(base, ast.Name)],
                "methods": extract_methods(node),
                "properties": extract_properties(node)
            }
            classes.append(class_info)
    return classes

def extract_methods(class_node: ast.ClassDef) -> List[Dict[str, Any]]:
    """
    Extract method information from a class node.
    Args:
        class_node (ast.ClassDef): Class definition node.
    Returns:
        List[Dict[str, Any]]: List of dictionaries containing method information:
            - name: Method name
            - comment: Method docstring (if any)
            - parameters: List of parameter names
    """
    methods = []
    for node in class_node.body:
        if isinstance(node, ast.FunctionDef):
            method_info = {
                "name": node.name,
                "comment": ast.get_docstring(node),
                "parameters": [arg.arg for arg in node.args.args if arg.arg != 'self']
            }
            methods.append(method_info)
    return methods

def extract_properties(class_node: ast.ClassDef) -> List[Dict[str, str]]:
    """
    Extract property information from a class node.
    Args:
        class_node (ast.ClassDef): Class definition node.
    Returns:
        List[Dict[str, str]]: List of dictionaries containing property information:
            - name: Property name
            - type: Property type (if annotated)
    """
    properties = []
    for node in class_node.body:
        if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
            prop_info = {
                "name": node.target.id,
                "type": ast.unparse(node.annotation) if node.annotation else None
            }
            properties.append(prop_info)
    return properties

def convert_to_yaml(python_data: Dict[str, Any]) -> str:
    """
    Convert extracted Python data to YAML format.
    Args:
        python_data (Dict[str, Any]): Dictionary containing extracted Python data.
    Returns:
        str: YAML representation of the Python data.
    """
    return yaml.dump(python_data, sort_keys=False, default_flow_style=False)

def process_directory(source_dir: str, dest_dir: str):
    """
    Process all Python files in the source directory and its subdirectories,
    extract information, and save as YAML files in the destination directory.
    Args:
        source_dir (str): Path to the source directory containing Python files.
        dest_dir (str): Path to the destination directory for YAML files.
    """
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.py'):
                source_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_path, source_dir)
                dest_path = os.path.join(dest_dir, os.path.dirname(relative_path))
                os.makedirs(dest_path, exist_ok=True)
                
                python_data = parse_python_file(source_path)
                yaml_content = convert_to_yaml(python_data)
                
                yaml_file = os.path.join(dest_path, f"{os.path.splitext(file)[0]}.yaml")
                with open(yaml_file, 'w') as f:
                    f.write(yaml_content)

if __name__ == "__main__":
    source_directory = "/path/to/python/source/directory"
    destination_directory = "/path/to/yaml/destination/directory"
    process_directory(source_directory, destination_directory)
    print("Extraction and conversion completed.")
