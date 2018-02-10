package JIP::Guard::Definitions::Boolean;

use parent 'JIP::Guard::Definitions';

use strict;
use warnings;

use constant TYPE => 'boolean';

use constant CONSTRAINTS => [qw(
    defined
    boolean
    true
    false
)];

our $VERSION = '0.01';

1;

