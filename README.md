# csuf-autograder-template

Template Gradescope Autograder configuration

Base autograder is located at https://github.com/ackao/csuf-autograder-base

## Setup

1. Use this repository as a template and create your own autograder for the specific assignment
1. Edit autograder_config.yml to select the appropriate autograder settings
1. Add testing. Currently only supports blackbox testing (configured in autograder_config.yml) -- future releases will support Googletest
1. Zip this directory and upload it to Gradescope

Do not edit `run_autograder` and `setup.sh` -- they are necessary to meet Gradescope's spec

## autograder_config.yml

This file is in YAML format. Nodes starting with `-` can be repeated.

The following fields are available. Optional fields are denoted by [].

```
language: c++                      # Currently only c++ is supported
[linter: true]                     # Enable clang-tidy checks; false by default
test_framework: blackbox           # Currently only blackbox is supported
code:
- main: foo.cpp                    # Replace this with the file containing the main function
  [implems:                        # Additional files to compile with main; none by default
    - bar.cpp]
  [compile_points: 5]              # Points given for successful compilation; 0 by default
  [linter_points:  5]              # Points for error-free linting; 0 by default
```

The following must also be present if blackbox testing is used:
```
blackbox_tests:
- test_name: "Name of the test"
  test_types:                      # At least one of these must be selected
    [- output]
    [- exitcode]
  obj: foo                         # Object file to test (name of main file)
  [stdin: ""]                      # Input to pass on stdin; none by default
  [stdout: ""]                     # Expected stdout; required for output tests
  [exitcode: 1]                    # Expected exit code; 0 by default
  points: 1                        # Number of points this test case is worth
  [visibility: visible]            # Test case visibility to students; visible by default
                                   #   options: hidden, after_due_date, after_published, visible
```
