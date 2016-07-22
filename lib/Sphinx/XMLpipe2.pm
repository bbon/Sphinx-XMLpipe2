package Sphinx::XMLpipe2;

use XML::Hash::XS;

our $VERSION = "0.02";

sub new {
    my ($class, %args) = @_;
    return undef unless %args;

    my $self = \%args;

    $self->{'xmlprocessor'} = XML::Hash::XS->new(
        xml_decl => 0,
        indent   => 4,
        use_attr => 1,
        content  => 'content',
        encoding => 'utf-8',
        utf8     => 0,
    );

    bless $self, $class;
    return $self
}

sub fetch {
    my ($self, ) = @_;

    my $content1 = $self->_fetch_header();
    my $content2 = $self->_fetch_data();
    return qq~<?xml version="1.0" encoding="utf-8"?>\n<sphinx:docset>$content1$content2</sphinx:docset>~;
}

sub add_data {
    my ($self, $data) = @_;
    return undef unless exists $data->{'id'};

    $self->{'data'} = {'sphinx:document' => []}
        unless exists $self->{'data'}->{'sphinx:document'};

    my %params = ();
    my @keys = (@{$self->{'fields'}}, keys %{$self->{'attrs'}});

    map { $params{$_} = [$data->{$_}] } @keys;

    push @{$self->{'data'}->{'sphinx:document'}}, {
        id => $data->{'id'},
        %params
    };
    return $self;
}

sub remove_data {
    my ($self, $data) = @_;
    return undef unless exists $data->{'id'};

    $self->{'data'} = {'sphinx:killlist' => {'id' => []}}
        unless exists $self->{'data'}->{'sphinx:killlist'}->{'id'};

    push @{$self->{'data'}->{'sphinx:killlist'}->{'id'}}, [$data->{'id'}];
    return $self;
}


sub _fetch_header {
    my ($self, ) = @_;
    my $header = {
        'sphinx:schema' => {
            'sphinx:field' => [],
            'sphinx:attr' => [],
        }
    };

    for my $field (@{$self->{'fields'}}) {
        push @{$header->{'sphinx:schema'}->{'sphinx:field'}}, {'name' => $field};
    }

    for my $attr (keys %{$self->{'attrs'}}) {
        push @{$header->{'sphinx:schema'}->{'sphinx:attr'}}, {'name' => $attr, 'type' => $self->{'attrs'}->{$attr}};
    }

    return _pruning_xml($self->{'xmlprocessor'}->hash2xml($header));
}

sub _fetch_data {
    my ($self, ) = @_;
    return _pruning_xml($self->{'xmlprocessor'}->hash2xml($self->{'data'}));
}

sub _pruning_xml {
    my ($xml) = @_;
    $xml =~ s/^\s*<root>//is;
    $xml =~ s/<\/root>\s*$//is;
    return $xml;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sphinx::XMLpipe2 - Kit for SphinxSearch xmlpipe2 interface

=head1 SYNOPSIS

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

=head1 METHODS

=over

=item new %options

Constructor. Takes a hash with options as an argument.

=back

=over

=item add_data $hashref

Adds a single document to xml

=back

=over

=item remove_data $hashref

Request for a single document remove from index (adds killist record to xml)

=back

=over

=item fetch

Gets xml for output

=back

=head1 LICENSE

Copyright (C) bbon.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

bbon <bbon@mail.ru>

=cut
