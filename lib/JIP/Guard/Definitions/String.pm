package JIP::Guard::Definitions::String;

use parent 'JIP::Guard::Definitions';

use strict;
use warnings;

use constant TYPE => 'string';

use constant CONSTRAINTS => [qw(
    defined
    string
    in
    min_length
    max_length
    empty
    like
    verify
)];

our $VERSION = '0.01';

1;

