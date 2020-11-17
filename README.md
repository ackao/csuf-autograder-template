# csuf-autograder-template

Template Gradescope Autograder configuration

Base autograder is located at https://github.com/ackao/csuf-autograder-base

## Setup

1. Use this repository as a template and create your own autograder for the specific assignment
1. This template uses Git submodules to manage which version of the base autograder is used.
You should not need to change it but if you do, use `git submodule` to pick a different commit to pin to.
1. Edit autograder_config.yml to select the appropriate autograder settings
1. Add testing, choose one option:
    * blackbox testing (configured in autograder_config.yml)
    * googletest unit testing (unit test case files located in tests/ directory)
1. Zip this directory and upload it to Gradescope

Do not edit `run_autograder` and `setup.sh` -- they are necessary to meet Gradescope's spec

## autograder_config.yml

This file is in YAML format. Nodes starting with `-` can be repeated.

The following fields are available. Optional fields are denoted by `[]`.

```
language: c++                      # Currently only c++ is supported
test_framework: blackbox|googletest
[style_check:]                     # Whether to enable style checking; false by default. See below.
code:
- main: foo.cpp                    # Replace this with the file containing the main function
  [implems:                        # Additional files to compile with main; none by default
    - bar.cpp]
  [compile_points: 5]              # Points given for successful compilation; 0 by default
  [googletest:]                    # Necessary if using Googletest (see below)
[linter:]                          # Enable clang-tidy checks. False if not present. See below for documentation.
```

### Style check

For C++, this runs `clang-format` on student code and diffs the result against the original.

It uses a default `.clang-format` configuration located [here](https://github.com/ackao/csuf-autograder-base/blob/master/cpp_tester/.clang-format)

To use a custom configuration, include your own `.clang-format` in the base directory of this repo.

The `style_check` block has the following syntax:
```
style_check:
  enable: true
  [strip_ws: false]               # strip trailing whitespace from each line, default: false
  files:                          # files to run it on, with how many points to give
  - file: foo.cpp
    points: 1
```

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
  files:                           # files to run it on, with how many points to give
  - file: foo.cpp
    points: 1
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
                                   #   options: hidden, after_due_date, after_published, visible, hide_message
                                   #   hide_message means: visible score but hide diff output
```

### Googletest testing config
Unit test files must be located in a tests/ subdirectory of this directory.
Supports multiple test case files per main/implem combination.

```
googletest:
  - test_file: unittest.cpp        # filename relative to tests/
    max_score: 15                  # max points in file
  - test_file: moretests.cpp
    max_score: 15
```

#### Unit test file contents

Must include header file of student code as relative path from `../src/`

Must also `#include <gtest/gtest.h>`

Tests can use `RecordProperty` to set flags.
Allowable fields are:
* points: how many points each assertion is worth, default 1
* max_score: how many points the entire test case is worth (equal to points if not set)
* all_or_nothing: if a single assertion fails, the score is 0. false by default.
* visibility: test case visibility to students, visibile by default (see blackbox testing for options)

Example test case:
```c++
#include <gtest/gtest.h>
#include "../src/exponents.h"

// This macro checks whether a function executes within a given time
//
// A thread is created to run the statement and update the status of a promise
// object. A future object is created from the promise object to check whether
// the promise  object's value was updated within the specified duration. If the
// promise's value is not changed in time, the function is considered to have
// timed out.
//
// Code based on: https://github.com/ILXL/cppaudit/blob/master/gtest_ext.h
//
// @param secs  seconds to wait before statement is considered to have
//              timed out
// @param stmt  statement to be tested
#define ASSERT_DURATION_LE(secs, stmt) { \
  std::promise<bool> completed; \
  auto stmt_future = completed.get_future(); \
  std::thread([&](std::promise<bool>& completed) { \
    stmt; \
    completed.set_value(1); \
  }, std::ref(completed)).detach(); \
  if(stmt_future.wait_for(std::chrono::seconds(secs)) == std::future_status::timeout) \
    if (!::testing::Test::HasFatalFailure()) { \
      GTEST_FATAL_FAILURE_("       Your program took more than " #secs \
      " seconds to exit. Check for infinite loops or unnecessary inputs."); \
    } \
    if (::testing::Test::HasFatalFailure()) FAIL(); \
}

TEST(PowerTest, BasicTests)
{
  RecordProperty("points", 1);
  RecordProperty("visibility", "visible");
  RecordProperty("max_score", 5);

  // Can't use test case struct for visible tests because it won't show values to students when failed :/
  ASSERT_DURATION_LE(3, ASSERT_EQ(power(2, 3), 8));
  ASSERT_DURATION_LE(3, ASSERT_EQ(power(1, 1), 1));
  ASSERT_DURATION_LE(3, ASSERT_EQ(power(1, -1), 0));
  ASSERT_DURATION_LE(3, ASSERT_EQ(power(2, 5), 32));
  ASSERT_DURATION_LE(3, ASSERT_EQ(power(5, 0), 1));
}

TEST(PowerTest, ZeroN)
{
  std::vector<testcase> cases{{0, 0, 1},
                              {1, 0, 1},
                              {-1, 0, 1},
                              {-10, 0, 1},
                              {5, 0, 1}};

  RecordProperty("visibility", "hidden");
  RecordProperty("max_score", 1);
  RecordProperty("all_or_nothing", 1);

  // test is hidden, can freely use struct here without worrying about unhelpful output
  for (testcase c : cases) {
    ASSERT_DURATION_LE(1, ASSERT_EQ(power(c.x, c.n), c.expected));
  }
}
```
