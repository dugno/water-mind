#!/bin/bash

# Run the build_runner to generate code
flutter pub run build_runner build --delete-conflicting-outputs

echo "Code generation completed!"
