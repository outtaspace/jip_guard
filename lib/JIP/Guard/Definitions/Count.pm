package JIP::Guard::Definitions::Count;

use parent 'JIP::Guard::Definitions';

use strict;
use warnings;

use constant TYPE => 'count';

use constant CONSTRAINTS => [qw(
    defined
    count
)];

our $VERSION = '0.01';

1;

