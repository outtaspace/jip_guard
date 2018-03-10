package JIP::Guard::Definitions::HashElement;

use parent 'JIP::Guard::Definitions';

use strict;
use warnings;

use constant TYPE => 'hash_element';

use constant CONSTRAINTS => [qw(
    hash_element
    required
    schema
)];

our $VERSION = '0.01';

1;

