@javascript
Feature: Add, view, and configure plugins
  In order to add functionality to Locomotive CMS through plugins
  As a CMS user
  I should be able to add, view, and/or configure plugins based on my role

  Background:
    Given I have a site set up
    And I have a designer and an author

  Scenario: Adding a plugin to a site
    Given I am an authenticated "admin"
    When I go to site settings
    And I unfold all folded inputs
    And I check "site_plugins_cucumber_plugin_enabled"
    And I press "Save"
    Then after the AJAX finishes, the plugin "cucumber_plugin" should be enabled

  Scenario: Configuring plugins
    Given I am an authenticated "designer"
    And the plugin "cucumber_plugin" is enabled
    When I go to site settings
    And I unfold all folded inputs
    And I follow "toggle" within "#plugin_list"
    And I fill in "cucumber_plugin_config" with "A Value"
    And I check "my_boolean_field"
    And I press "Save"
    Then after the AJAX finishes, the plugin config for "cucumber_plugin" should be:
        | cucumber_plugin_config  | A Value   |
        | my_boolean_field  | true      |
    When I go to site settings
    And I unfold all folded inputs
    And I follow "toggle" within "#plugin_list"
    Then I should see "A Value"
    And the "my_boolean_field" checkbox should be checked

  Scenario: Configuring disabled plugins
    Given I am an authenticated "admin"
    When I go to site settings
    And I unfold all folded inputs
    And I follow "toggle" within "#plugin_list"
    And I fill in "cucumber_plugin_config" with "A Value"
    And I press "Save"
    Then after the AJAX finishes, the plugin config for "cucumber_plugin" should be:
        | cucumber_plugin_config  | A Value   |

  Scenario: Access content types from plugin config UI
    Given I am an authenticated "designer"
    And I have a custom model named "Projects" with
        | label     | type      | required  |
        | Name      | string    | true      |
    And I have a custom model named "Clients" with
        | label     | type      | required  |
        | Name      | string    | true      |
    And the plugin "cucumber_plugin" is enabled
    When I go to site settings
    And I unfold all folded inputs
    And I follow "toggle" within "#plugin_list"
    Then the "content_type" dropdown should contain "Projects"
    Then the "content_type" dropdown should contain "Clients"