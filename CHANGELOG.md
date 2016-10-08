## 0.4.0 (2016/10/9)

Bug Fix: (#3)

- `Grifork::Executor::Task#run` was not thread-safe

Features: (#3)

- New DSL methods:
  - `#parallel` as option for [Parallel.map](https://github.com/grosser/parallel)
  - `#ssh` as options for [Net::SSH](https://github.com/net-ssh/net-ssh)
  - `#rsync` as options for `rsync` command
- New CLI option `-n|--dry-run`

Improve: (#3)

- Mode `:grifork` / Not to fork `grifork` task on node with no children

## 0.3.0 (2016/10/4)

Release as a RubyGem.

## 0.2.0 (2016/10/2)

Feature:

- Implement "grifork" mode to exec "grifork" command in parallel and recursively
  among target hosts #1

## 0.1.0 (2016/9/28)

Initial release.

Feature:

- Implement "standalone" mode to run defined tasks for target hosts
