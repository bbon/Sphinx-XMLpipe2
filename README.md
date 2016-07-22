# NAME

Sphinx::XMLpipe2 - Kit for SphinxSearch xmlpipe2 interface

# SYNOPSIS

    use Sphinx::XMLpipe2;

    my $sxml = new Sphinx::XMLpipe2(
        fields => [qw(author title content)],
        attrs  => {published => 'timestamp',}
    );

    $sxml->add_data({
        id         => 314159265,
        author     => 'Oscar Wilde',
        title      => 'Illusion is the first of all pleasures',
        content    => 'Man is least himself when he talks in his own person. Give him a mask, and he will tell you the truth.',
        published  => time(),
    });

    $sxml->remove_data({id => 27182818});

    print $sxml->fetch(), "\n";

# METHODS

- new %options

    Constructor. Takes a hash with options as an argument.

- add\_data $hashref

    Adds a single document to xml

- remove\_data $hashref

    Request for a single document remove from index (adds killist record to xml)

- fetch

    Gets xml for output

# LICENSE

Copyright (C) bbon.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

bbon <bbon@mail.ru>
