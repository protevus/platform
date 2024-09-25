/**
 * This script extracts information from TypeScript files and converts it to YAML format.
 * It processes TypeScript files in a given source directory, extracts various components
 * such as imports, classes, methods, and properties, and then writes the extracted
 * information to YAML files in a specified destination directory.
 */

import * as fs from 'fs';
import * as path from 'path';
import * as ts from 'typescript';
import * as yaml from 'js-yaml';

interface FileData {
    name: string;
    imports: Import[];
    classes: ClassInfo[];
}

interface Import {
    name: string;
    source: string;
}

interface ClassInfo {
    name: string;
    comment?: string;
    extends?: string[];
    implements?: string[];
    methods: MethodInfo[];
    properties: PropertyInfo[];
}

interface MethodInfo {
    name: string;
    comment?: string;
    parameters: ParameterInfo[];
    returnType?: string;
}

interface ParameterInfo {
    name: string;
    type?: string;
}

interface PropertyInfo {
    name: string;
    type?: string;
    visibility: string;
}

function parseTypeScriptFile(filePath: string): FileData {
    const content = fs.readFileSync(filePath, 'utf-8');
    const sourceFile = ts.createSourceFile(filePath, content, ts.ScriptTarget.Latest, true);
    
    const name = path.basename(filePath).split('.')[0];
    const imports = extractImports(sourceFile);
    const classes = extractClasses(sourceFile);
    
    return { name, imports, classes };
}

function extractImports(sourceFile: ts.SourceFile): Import[] {
    const imports: Import[] = [];
    
    ts.forEachChild(sourceFile, node => {
        if (ts.isImportDeclaration(node)) {
            const importClause = node.importClause;
            const moduleSpecifier = node.moduleSpecifier;
            
            if (importClause && ts.isStringLiteral(moduleSpecifier)) {
                const name = importClause.name?.text ?? '*';
                const source = moduleSpecifier.text;
                imports.push({ name, source });
            }
        }
    });
    
    return imports;
}

function extractClasses(sourceFile: ts.SourceFile): ClassInfo[] {
    const classes: ClassInfo[] = [];
    
    ts.forEachChild(sourceFile, node => {
        if (ts.isClassDeclaration(node) && node.name) {
            const classInfo: ClassInfo = {
                name: node.name.text,
                comment: getLeadingCommentText(node),
                extends: node.heritageClauses?.filter(clause => clause.token === ts.SyntaxKind.ExtendsKeyword)
                    .flatMap(clause => clause.types.map(t => t.getText())),
                implements: node.heritageClauses?.filter(clause => clause.token === ts.SyntaxKind.ImplementsKeyword)
                    .flatMap(clause => clause.types.map(t => t.getText())),
                methods: extractMethods(node),
                properties: extractProperties(node)
            };
            classes.push(classInfo);
        }
    });
    
    return classes;
}

function extractMethods(classNode: ts.ClassDeclaration): MethodInfo[] {
    const methods: MethodInfo[] = [];
    
    classNode.members.forEach(member => {
        if (ts.isMethodDeclaration(member) && member.name) {
            const methodInfo: MethodInfo = {
                name: member.name.getText(),
                comment: getLeadingCommentText(member),
                parameters: extractParameters(member),
                returnType: member.type ? member.type.getText() : undefined
            };
            methods.push(methodInfo);
        }
    });
    
    return methods;
}

function extractParameters(method: ts.MethodDeclaration): ParameterInfo[] {
    return method.parameters.map(param => ({
        name: param.name.getText(),
        type: param.type ? param.type.getText() : undefined
    }));
}

function extractProperties(classNode: ts.ClassDeclaration): PropertyInfo[] {
    const properties: PropertyInfo[] = [];
    
    classNode.members.forEach(member => {
        if (ts.isPropertyDeclaration(member) && member.name) {
            const propertyInfo: PropertyInfo = {
                name: member.name.getText(),
                type: member.type ? member.type.getText() : undefined,
                visibility: getVisibility(member)
            };
            properties.push(propertyInfo);
        }
    });
    
    return properties;
}

function getVisibility(node: ts.Node): string {
    if (node.modifiers) {
        if (node.modifiers.some(m => m.kind === ts.SyntaxKind.PrivateKeyword)) return 'private';
        if (node.modifiers.some(m => m.kind === ts.SyntaxKind.ProtectedKeyword)) return 'protected';
        if (node.modifiers.some(m => m.kind === ts.SyntaxKind.PublicKeyword)) return 'public';
    }
    return 'public'; // Default visibility in TypeScript
}

function getLeadingCommentText(node: ts.Node): string | undefined {
    const fullText = node.getFullText();
    const trivia = fullText.substring(0, node.getLeadingTriviaWidth());
    const commentRanges = ts.getLeadingCommentRanges(trivia, 0);
    
    if (commentRanges && commentRanges.length > 0) {
        return trivia.substring(commentRanges[0].pos, commentRanges[0].end).trim();
    }
    
    return undefined;
}

function convertToYaml(data: FileData): string {
    return yaml.dump(data, { sortKeys: false });
}

function processDirectory(sourceDir: string, destDir: string): void {
    fs.readdirSync(sourceDir, { withFileTypes: true }).forEach(entry => {
        const sourcePath = path.join(sourceDir, entry.name);
        const destPath = path.join(destDir, entry.name);
        
        if (entry.isDirectory()) {
            fs.mkdirSync(destPath, { recursive: true });
            processDirectory(sourcePath, destPath);
        } else if (entry.isFile() && entry.name.endsWith('.ts')) {
            const tsData = parseTypeScriptFile(sourcePath);
            const yamlContent = convertToYaml(tsData);
            const yamlPath = path.join(destDir, `${path.parse(entry.name).name}.yaml`);
            fs.writeFileSync(yamlPath, yamlContent);
        }
    });
}

const sourceDirectory = '/path/to/typescript/source/directory';
const destinationDirectory = '/path/to/yaml/destination/directory';

processDirectory(sourceDirectory, destinationDirectory);
console.log('Extraction and conversion completed.');
