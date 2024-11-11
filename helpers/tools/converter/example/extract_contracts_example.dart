import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  // Create a sample PHP file
  final samplePhp = '''
<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Model;
use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use App\\Interfaces\\UserInterface;

/**
 * User model class.
 * Represents a user in the system.
 */
class User extends Model implements UserInterface {
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<string>
     */
    protected array \$fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<string>
     */
    protected array \$hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the user's full name.
     *
     * @param string \$title Optional title prefix
     * @return string
     */
    public function getFullName(string \$title = ''): string {
        return trim(\$title . ' ' . \$this->name);
    }

    /**
     * Set the user's password.
     *
     * @param string \$value
     * @return void
     */
    public function setPasswordAttribute(string \$value): void {
        \$this->attributes['password'] = bcrypt(\$value);
    }
}
''';

  // Create temporary directories
  final tempDir = Directory.systemTemp.createTempSync('contract_example');
  final sourceDir = Directory(path.join(tempDir.path, 'source'))..createSync();
  final outputDir = Directory(path.join(tempDir.path, 'output'))..createSync();

  // Write sample PHP file
  final phpFile = File(path.join(sourceDir.path, 'User.php'));
  await phpFile.writeAsString(samplePhp);

  // Run the contract extractor
  print('Extracting contracts from ${sourceDir.path}');
  print('Output directory: ${outputDir.path}');

  final result = await Process.run(
    'dart',
    [
      'run',
      'bin/extract_contracts.dart',
      '--source',
      sourceDir.path,
      '--output',
      outputDir.path,
      '--verbose',
    ],
  );

  if (result.exitCode != 0) {
    print('Error: ${result.stderr}');
    exit(1);
  }

  // Read and display the generated YAML
  final yamlFile = File(path.join(outputDir.path, 'User.yaml'));
  if (await yamlFile.exists()) {
    print('\nGenerated YAML contract:');
    print('------------------------');
    print(await yamlFile.readAsString());
  } else {
    print('Error: YAML file was not generated');
  }

  // Cleanup
  tempDir.deleteSync(recursive: true);
}
