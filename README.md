# Installation

First, place the [executable](https://github.com/kokic/lazy.md/releases) in a directory on your `PATH` and make sure `lazy.md --help` works.

## 2/3 Write your own lazy.md file

[An example file](./default.lazy.md)

Use only level-three headings (`###`) to divide the content into sections. Don't worry about longer `*.lazy.md` files increasing baseline context usage: the content under each heading is read only when needed.

## 3/3 Append to the system prompt

If you use PI, edit `~/.pi/agent/APPEND_SYSTEM.md` and add the following:

```
Upon reading this message, immediately run `lazy.md ~/lazy.md` to display the available titles; then, depending on your task, execute `lazy.md ~/lazy.md [title1] [title2] ...` to access the specific instructions you need to follow.
```

For other tools, check how to append to their system prompts.

# Contributing

Contributions to `default.lazy.md` are welcome.

# Philosophy

- You don't need to use the filesystem and a large collection of Markdown files to simulate a structured prompt system. A flat index is all you need.
