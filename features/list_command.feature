Feature: Listing cookbooks defined by a Berksfile
  As a user with a Berksfile
  I want a way to show all my cookbooks and their versions without opening my Berksfile
  So that I can be more productive

  Scenario: Running the list command
    Given the cookbook store has the cookbooks:
      | fake1 | 1.0.0 |
      | fake2 | 1.0.1 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake1', '1.0.0'
      cookbook 'fake2', '1.0.1'
      """
    And the Lockfile has:
      | fake1 | 1.0.0 |
      | fake2 | 1.0.1 |
    When I successfully run `berks list`
    Then the output should contain:
      """
      Cookbooks installed by your Berksfile:
        * fake1 (1.0.0)
        * fake2 (1.0.1)
      """

  Scenario: Running the list command when the dependencies aren't downloaded
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the Lockfile has:
      | fake | 1.0.0 |
    When I run `berks list`
    Then the output should contain:
      """
      Could not find cookbook 'fake (1.0.0)'.
      """
    And the exit status should be "CookbookNotFound"


  Scenario: Running the list command when the lockfile isn't present
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I run `berks list`
    Then the output should contain:
      """
      Could not find cookbook 'fake (= 1.0.0)'.
      """
    And the exit status should be "CookbookNotFound"


  Scenario: Running the list command with no dependencies defined
    Given I have a Berksfile pointing at the local Berkshelf API
    When I successfully run `berks list`
    Then the output should contain:
      """
      There are no cookbooks installed by your Berksfile
      """
