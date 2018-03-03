package JIP::Guard::Definitions::Ref;

use parent 'JIP::Guard::Definitions';

use strict;
use warnings;

use constant TYPE => 'ref';

use constant CONSTRAINTS => [qw(
    defined
    ref
)];

our $VERSION = '0.01';

1;

