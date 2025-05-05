#!/bin/bash

# Run build_runner to generate freezed and json serializable files
flutter pub run build_runner build --delete-conflicting-outputs

echo "Code generation completed!"
