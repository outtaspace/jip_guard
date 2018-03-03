package JIP::Guard::Definitions::Float;

use parent 'JIP::Guard::Definitions';

use strict;
use warnings;

use constant TYPE => 'float';

use constant CONSTRAINTS => [qw(
    defined
    float
)];

our $VERSION = '0.01';

1;

