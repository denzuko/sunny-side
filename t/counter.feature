Feature: Counter (smoke test)

  Background:
    Given a fresh counter

  Scenario: Incrementing once
    When I increment it
    Then the count should be 1

  Scenario: Incrementing twice
    When I increment it
    And I increment it
    Then the count should be 2
