Feature: Correctly formatted reports
  In order to get the most out of Reek
  As a developer
  I want to be able to parse Reek's output simply and consistently

  Scenario Outline: two reports run together with indented smells
    Given a directory called 'smelly' containing two smelly files
    When I run reek <args>
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      smelly/dirty_two.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      4 total warnings
      """

    Examples:
      | args                                    |
      | smelly/dirty_one.rb smelly/dirty_two.rb |
      | smelly                                  |

  Scenario Outline: No sorting (which means report each file as it is read in)
    Given a directory called 'smelly' containing two smelly files
    When I run reek <option> smelly
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      smelly/dirty_two.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      4 total warnings
      """

    Examples:
      | option         |
      |                |
      | --sort-by none |
      | --sort-by n    |

  Scenario Outline: Sort by issue count
    Given a directory called 'smelly' containing two smelly files
    When I run reek <option> smelly
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_two.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      smelly/dirty_one.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      4 total warnings
      """

    Examples:
      | option               |
      | --sort-by smelliness |
      | --sort-by s          |

  Scenario: good files show no headings by default
    Given a directory called 'clean' containing two clean files
    When I run reek clean
    Then it succeeds
    And it reports:
      """
      0 total warnings
      """

  Scenario Outline: --empty-headings turns on headings for fragrant files
    Given a directory called 'clean' containing two clean files
    When I run reek <option> clean
    Then it succeeds
    And it reports:
      """
      clean/clean_one.rb -- 0 warnings
      clean/clean_two.rb -- 0 warnings
      0 total warnings
      """

    Examples:
      | option            |
      | --empty-headings  |
      | -V                |

  Scenario Outline: --no-empty-headings turns off headings for fragrant files
    Given a directory called 'clean' containing two clean files
    When I run reek <option> clean
    Then it succeeds
    And it reports:
      """
      0 total warnings
      """

    Examples:
      | option                 |
      | --no-empty-headings    |
      | -V --no-empty-headings |

  Scenario Outline: --no-line-numbers turns off line numbers
    Given the smelly file 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        UncommunicativeMethodName: Smelly#x has the name 'x'
        UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

    Examples:
      | option               |
      | --no-line-numbers    |
      | --no-line-numbers -V |
      | -V --no-line-numbers |

  Scenario Outline: --line-numbers turns on line numbers
    Given the smelly file 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

    Examples:
      | option                           |
      | --line-numbers                   |
      | --no-line-numbers --line-numbers |
      | --no-line-numbers -n             |

  Scenario Outline: --single-line shows filename and one line number
    Given the smelly file 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        smelly.rb:4: UncommunicativeMethodName: Smelly#x has the name 'x'
        smelly.rb:5: UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

    Examples:
      | option        |
      | -s            |
      | --single-line |
      | -s -V         |
      | -V -s         |

  Scenario Outline: Extra slashes aren't added to directory names
    Given a directory called 'smelly' containing two smelly files
    When I run reek <args>
    Then the exit status indicates smells
    And it reports:
      """
      smelly/dirty_one.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      smelly/dirty_two.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      4 total warnings
      """

    Examples:
      | args    |
      | smelly/ |
      | smelly  |

  Scenario Outline: -U or --documentation adds helpful links to smell warnings
    Given the smelly file 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/v6.0.1/docs/Uncommunicative-Method-Name.md]
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/v6.0.1/docs/Uncommunicative-Variable-Name.md]
      """

    Examples:
      | option           |
      | -U               |
      | --documentation  |

  Scenario: --no-documentation drops links from smell warnings
    Given the smelly file 'smelly.rb'
    When I run reek --no-documentation smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
        [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """

  Scenario Outline: --documentation is independent of --line-numbers
    Given the smelly file 'smelly.rb'
    When I run reek <option> smelly.rb
    Then the exit status indicates smells
    And it reports:
      """
      smelly.rb -- 2 warnings:
        UncommunicativeMethodName: Smelly#x has the name 'x' [https://github.com/troessner/reek/blob/v6.0.1/docs/Uncommunicative-Method-Name.md]
        UncommunicativeVariableName: Smelly#x has the variable name 'y' [https://github.com/troessner/reek/blob/v6.0.1/docs/Uncommunicative-Variable-Name.md]
      """

    Examples:
      | option                             |
      | --no-line-numbers -U               |
      | --no-line-numbers --documentation  |
