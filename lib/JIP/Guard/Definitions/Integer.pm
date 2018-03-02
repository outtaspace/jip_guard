package JIP::Guard::Definitions::Integer;

use parent 'JIP::Guard::Definitions';

use strict;
use warnings;

use constant TYPE => 'integer';

use constant CONSTRAINTS => [qw(
    defined
    integer
)];

our $VERSION = '0.01';

1;

