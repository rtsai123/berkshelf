Feature: Checking my Berksfile is satisfied
  As a user with a Berksfile
  I want a way to know if I have everything installed
  So I know the next action to perform

  Scenario: Running the check command
    Given the cookbook store has the cookbooks:
      | fake1 | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake1', '1.0.0'
      """
    And the Lockfile has:
      | fake1 | 1.0.0 |
    When I successfully run `berks check`
    Then the output should contain:
      """
      The Berksfile's dependencies are satisfied and downloaded
      """


  Scenario: Running the check command with no sources defined
    Given I have a Berksfile pointing at the local Berkshelf API
    When I successfully run `berks check`
    Then the output should contain:
      """
      The Berksfile's dependencies are satisfied and downloaded
      """

  Scenario: Running the check command when there is no lockfile
    Given the cookbook store has the cookbooks:
      | fake1 | 1.0.0 |
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake1', '1.0.0'
      """
    When I run `berks check`
    Then the output should contain:
      """
      Berkshelf can't satisfy your Berksfile's dependencies
      """
    Then the exit status should be "CookbookNotFound"


  Scenario: Running the check command when the sources are not installed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake1', '1.0.0'
      """
    And the Lockfile has:
      | fake1 | 1.0.0 |
    When I run `berks check`
    Then the output should contain:
      """
      Berkshelf can't satisfy your Berksfile's dependencies
      """
    Then the exit status should be "CookbookNotFound"
