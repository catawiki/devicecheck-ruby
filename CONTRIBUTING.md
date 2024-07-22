# Contributing

We love pull requests from everyone. By participating in this project,
you agree to abide by the our [code of conduct][code_of_conduct].

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by closing [issues]
* by reviewing patches

## Submitting an Issue

* We use the [GitHub issue tracker][issues] to track bugs and features.
* Before submitting a bug report or feature request, check to make sure it hasn't
  already been submitted.
  
* When submitting a bug report, please include a gist that includes a
  stack trace and any details that may be necessary to reproduce the
  bug, including your gem version, Ruby version, and operating system.
  Ideally, a bug report should include a pull request with failing
  specs.

## Cleaning up issues

* Issues that have no response from the submitter will be closed after
  30 days.
* Issues will be closed once they're assumed to be fixed or
  answered. If the maintainer is wrong, it can be opened again.
* If your issue is closed by mistake, please understand and explain the issue.
  We will happily reopen the issue.

## Submitting a Pull Request

1. [Fork][fork] the [official repository][repo].
1. [Create a topic branch.][branch]
1. Implement your feature or bug fix.
1. Add, commit, and push your changes.
1. [Submit a pull request.][pr]

### Notes

* Please add tests if you changed code. Contributions without tests
  won't be accepted.
* If you don't know how to add tests, please put in a PR and leave a
  comment asking for help. We love helping!
* Please don't update the Gem version.

## Setting Up

After checking out the repo, run `bundle install` to install
dependencies. Then, run `rake spec` to run the tests.  You can also
run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`.

## Running the test suite

The default rake task will run the full test suite and lint:

```sh
bundle exec rake
```

To run an individual rspec test, you can provide a path and line number:

```sh
bundle exec rspec spec/path/to/spec.rb:123
```

## Formatting and Style

Our style guide is defined in `.rubocop.yml`.

To run the linter:

```sh
bundle exec rubocop
```

To run the linter with auto correct:

```sh
bundle exec rubocop -A
```

Inspired by [factory_bot] and [activeinteractor].

[code_of_conduct]: CODE-OF-CONDUCT.md
[repo]: https://github.com/catawiki/devicecheck-ruby/tree/main
[issues]: https://github.com/catawiki/devicecheck-ruby/issues
[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/
[pr]: https://help.github.com/articles/using-pull-requests/
[gist]: https://gist.github.com/
[factory_bot]: https://github.com/thoughtbot/factory_bot/blob/master/CONTRIBUTING.md
[activeinteractor]: https://github.com/aaronmallen/activeinteractor/tree/main/CONTRIBUTING.md
