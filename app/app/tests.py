"""
Simple Tests
"""

"""
Mocking

- Overrides or changes the behaviour of dependencies
  for the purpose of your tests.

- Avoids unintended side effects
- Isolates code being tested.

Why use mocking?

- Avoids relying on external services 
    You can't always guarantee that the service will be available
    Makes tests unpredictable and inconsistent

- Avoids unintended consequences
    - Such as accidentally sending emails
    - Or overloading external services

- Speeds up tests

How to mock code?

- Use unittest.mock
    - MagicMock/Mock - Replaces real objects
    - patch - Overrides code for tests

"""