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

The following fields are available. Optional fields are denoted by `[]`.

```
language: c++                      # Currently only c++ is supported
test_framework: blackbox           # Currently only blackbox is supported
[style_check: false]               # Whether to enable style checking; false by default
code:
- main: foo.cpp                    # Replace this with the file containing the main function
  [implems:                        # Additional files to compile with main; none by default
    - bar.cpp]
  [compile_points: 5]              # Points given for successful compilation; 0 by default
  [linter_points:  5]              # Points for error-free linting; 0 by default
[linter:]                          # Enable clang-tidy checks. False if not present. See below for documentation.
```

### Style check

For C++, this runs `clang-format` on student code and diffs the result against the original.

It uses a default `.clang-format` configuration located [here](https://github.com/ackao/csuf-autograder-base/blob/master/cpp_tester/.clang-format)

To use a custom configuration, include your own `.clang-format` in the base directory of this repo.

### Linter config

The `linter` block has the following syntax:

```
linter:
  enable: true                     # Actually enable the linter
  [checks: ""]                     # Checks to pass as --checks= flag to clang-tidy
                                   #   Ex: "-*,google-readability-todo"
                                   # Default: "*,-google-build-using-namespace,-fuchsia-default-arguments,-llvm-header-guard"
  [test_name: "{}"]                # Python format string for test name. Needs one {}.
                                   #   The executable name will be put in the {}
                                   #   default: "Linter Test: {}"
  [success_message: ""]            # Custom message to print on linter success
                                   #   default: "No linter errors found"
  [failure_message: ""]            # Custom message to print on linter failure
                                   #   default: "Linter returned errors"
```

### Blackbox testing config
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
