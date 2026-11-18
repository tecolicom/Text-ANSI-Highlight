
# NAME

Text::ANSI::Highlight - syntax highlight for the terminal, by a highlighter of your choice

# SYNOPSIS

    use Text::ANSI::Highlight;

    my $hl = Text::ANSI::Highlight->new('pandoc');

    # texts with their languages, all at once
    my($c, $perl) = $hl->highlight([ c => $text1 ], [ perl => $text2 ]);

    # a file, by its name
    print $hl->file('lib/Foo.pm') // $content;

    # a Markdown text: the code in the fences, each by its language
    print $hl->markdown($text) // $text;

    # as a filter of the tee module of greple
    greple -Mtee '&Text::ANSI::Highlight::filter' -- ...

# VERSION

Version 0.01

# DESCRIPTION

This module colors source code for the terminal, with ANSI sequences.
It does not color by itself: it gives the text to a highlighter, a
command which is installed, and takes the colors from it.  The
highlighter can be changed for another, and all of them are used in
the same way.

What comes back is the text which was given, with colors, and nothing
else: when the text a highlighter gives is not that of the input, the
input is left as it is.  A method returns `undef` for a text which
is not colored, so that the caller shows the text it has:

    print $hl->file($file) // $content;

A text is not colored when the highlighter does not know its language,
when it is empty, when it has an escape character already, and when
the command of the highlighter is not installed or fails.

# HIGHLIGHTERS

- **pandoc**

    [pandoc](https://pandoc.org/), by its `ansi` writer.  It is the
    default.  All the texts of a call are given to `pandoc` in one run,
    each in a code block of its own in a Markdown text.  `pandoc` has
    the library of `skylighting` in it, and the `skylighting` command
    is not used.  The `ansi` writer is not in an old `pandoc`.

- **sourcehighlight**, **gnu**

    [GNU Source-highlight](https://www.gnu.org/software/src-highlite/),
    with its `esc.style`: the colors that `less` shows by its
    `lesspipe`.  The command runs once for each text.  It knows fewer
    languages, and not Markdown: the text around the code of a Markdown
    text is left as it is.

- **skylighting**, **sky**

    The `skylighting` command, the highlighter of `pandoc` as a program
    of its own.  The command runs once for each text.

The colors of `pandoc` and `skylighting` are the 16 colors of the
terminal, without background.

A highlighter is a module `Text::ANSI::Highlight::_name_` which has
three functions: `language(_name_)` returns the name of a language
as the highlighter calls it, or `undef` when it does not know it;
`highlight([ _language_, _text_ ], ...)` returns the texts in
colors, as many as given; and `markdown()` tells whether the
highlighter knows Markdown.  The rest is done here.

# METHODS

- **new**(_name_)
- **new**(**with** => _name_)

    Make an object which colors with the highlighter of the name, or of
    the short name (`gnu`, `sky`).  The
    parameter is `with`, and it can be left out for the first argument:
    with an odd number of arguments, the first is the highlighter.
    Without it, the highlighter is `pandoc`
    (`$Text::ANSI::Highlight::HIGHLIGHTER`).  It dies for a name which is
    not that of a highlighter.

- **highlight**(\[ _language_, _text_ \], ...)

    Color texts, and return as many: each is the text in colors, or
    `undef` when it is not colored.

    The language is a name which the highlighter knows, the extension of
    a file (`pm`, `yml`), or another name that people use (`shell`,
    `c++`).  A text of the language `markdown` is colored as by the
    `markdown` method.

    Texts of characters give texts of characters, and texts of bytes
    (UTF-8) give bytes.  A text with CR LF keeps them.

- **markdown**(_text_)

    Color a Markdown text.  The code in a fence (```` ``` ```` or `~~~`) is
    colored by the language which is written after the fence, each block
    by itself: what is not closed in a block, as a string or a comment,
    does not go on to the next.  The text around the code is colored as
    Markdown, when the highlighter knows it.  The lines of the fences are
    left as they are.  Returns `undef` when nothing is colored.

- **file**(_file_, **language** => _name_)

    Color the content of a file.  The language is told from the extension
    of the file, from its name (`Makefile`), or from the interpreter on
    its first line (`#!/usr/bin/env perl`), unless it is given.  A
    Markdown file (`.md`, `.markdown`) is colored by the `markdown`
    method.  A file larger than `$Text::ANSI::Highlight::MAX_SIZE` bytes
    (256 KB by default, 0 for no limit) is not colored.

- **text**(_text_, **name** => _file_, **language** => _name_)

    The same for a text.  The language is given, or told from the name of
    a file and the first line of the text.

- **language**(_name_)

    The name of a language as the highlighter calls it, or `undef` when
    it does not know the language.

# FUNCTIONS

- **filter**(_options_)

    Read the standard input and print it in colors, or as it is when it
    is not colored.  The options are `-w _name_` (`--with`), the
    highlighter, and `-l _language_` (`--language`), which is
    `markdown` by default.

    It is a function for the `tee` module of **greple**, which gives parts
    of a file to a function and puts back what it prints.  Next command
    colors the code blocks of a Markdown file:

        greple -Mtee '&Text::ANSI::Highlight::filter' -- --all --cm N -E \
          '^ {0,3}(?<f>(?<c>[`~])\g{c}{2,}).*\n(?s:.*?)^ {0,3}\g{f}\g{c}*\h*$' \
          file.md

    The pattern is a fenced code block: a fence of three or more `` ` `` or
    `~`, and the closing one of the same character, at least as long.
    The blocks are given together, with their fences, and each is colored
    by itself.  The lines are those of the input, so `tee` puts them back
    by their number.

# MARKDOWN AND SKYLIGHTING

The `skylighting` command colors a Markdown file by a definition of
Markdown which finds the fences by itself, and it can take the rest
of the file for the code of a fence: after a function of a shell
script, or `__DATA__` of Perl, in a code block (skylighting 0.15).
This module finds the fences by itself, and gives the highlighter
the code of each block, and the text around them in pieces which have
no fence.

# SEE ALSO

[ansihighlight](https://metacpan.org/pod/ansihighlight), the command.

[App::Greple::tee](https://metacpan.org/pod/App%3A%3AGreple%3A%3Atee)

[https://pandoc.org/](https://pandoc.org/), [https://www.gnu.org/software/src-highlite/](https://www.gnu.org/software/src-highlite/),
[https://github.com/jgm/skylighting](https://github.com/jgm/skylighting)

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright © 2026 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
