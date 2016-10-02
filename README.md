[![Build Status](https://travis-ci.org/key-amb/grifork.svg?branch=master)](https://travis-ci.org/key-amb/grifork)

# grifork

Fast propagative task runner for systems which consist of a lot of servers.

# Concept

**Grifork** runs defined tasks on the system in a way like tree's branching.  
Give **grifork** a list of hosts, then it creates a tree graph internally, and runs
tasks in a top-down way.

**Grifork** has two modes to work:

1. **Standalone** mode. This requires **grifork** program only on the root server
in the tree graph: i.e. the server which invokes tasks.
1. **Grifork** mode. On the other hand, this requires **grifork** program to work
on every node in the graph.

Take a look at each mechanism.

## Standalone Mode

The image below illustrates a 3-depth tree of 13 nodes including root node.

![standalone mode](https://raw.githubusercontent.com/key-amb/grifork/resource/images/standalone_mode2.png)

We are running a task to copy a file tree to every host.  
1st stage is completed: to copy them to nodes in 1st generation.

Now at 2nd stage, root node logins each of its children by _ssh_ and kicks _rsync_
program there, in order to copy the file tree from 1st to 2nd generation.

NOTE:

- Max concurrency of running task in **standalone** mode is the number of nodes
at the generation which holds max.
This is the last genaration or the genartion before the last.

## Grifork Mode

The image below is similar to previous situation except that this is in **grifork** mode.

![grifork mode](https://raw.githubusercontent.com/key-amb/grifork/resource/images/grifork_mode2.png)

In this mode, parent nodes in the graph invokes _grifork_ command on every child
node via _ssh_, giving the graph tree which descends from each child node.

# System Requirements

- Ruby v2
- ssh, rsync

# Installation

```sh
git clone https://github.com/key-amb/grifork.git
cd grifork
bundle
```

# Usage

```sh
edit Griforkfile
./bin/grifork [--[f]ile path/to/Griforkfile]
```

See [example](example) directory for sample of Griforkfiles.

# Authors

IKEDA Kiyoshi <yasutake.kiyoshi@gmail.com>

# License

The MIT License (MIT)

Copyright (c) 2016 IKEDA Kiyoshi
