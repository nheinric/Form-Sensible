use Test::More;
use Cache::FastMmap;

use Form::Sensible::Form;
use Form::Sensible::Field::Select;

## Build a form with two select fields
my $form = Form::Sensible::Form->new( name => 'form' );

my $select1 = Form::Sensible::Field::Select->new(
    name                => 'select1'
    , accepts_multiple  => 0
    , validation        => { required => 1 }
    );
$select1->add_option( 'select1-option1', 'Something' );
$select1->add_option( 'select1-option2', 'Something completely different' );
$select1->set_selection( 'option1' );

my $select2 = Form::Sensible::Field::Select->new(
    name                => 'select2'
    , accepts_multiple  => 0
    , validation        => { required => 1 }
    );
$select2->add_option( 'select2-option1', 'Spam' );
$select2->add_option( 'select2-option2', 'Spam eggs sausage and spam' );
$select2->set_selection( 'option1' );

$form->add_field( $select1 );
$form->add_field( $select2 );

## Cache the form
my $cache = Cache::FastMmap->new( unlink_on_exit => 1 );
# Silence "used only once" warning
$Storable::Deparse = $Storable::Eval = 1;
$Storable::Deparse = $Storable::Eval = 1;
$cache->set( "the-form", $form );

note "Test form, pre-serialization";
test_validation( $form );

note "Test form, post-serialization";
my $form2 = $cache->get( "the-form" );
test_validation( $form2 );


done_testing;

################################################################################
sub test_validation {
    my $form = shift;

    $form->set_values({
        select1     => "select1-option1"
        , select2   => "select2-option1"
        });
    ok( $form->validate->is_valid, "Good data validated 1" )
        or diag explain [ $form->validate, $form->get_all_values ];

    $form->set_values({
        select1     => "select1-option2"
        , select2   => "select2-option2"
        });
    ok( $form->validate->is_valid, "Good data validated 2" )
        or diag explain [ $form->validate, $form->get_all_values ];

    $form->set_values({
        select1     => "he's bleedin' demised"
        , select2   => "select2-option1"
        });
    ok( ! $form->validate->is_valid, "Bad data failed 1" )
        or diag explain $form->validate;

    $form->set_values({
        select1     => "select1-option1"
        , select2   => "beautiful plumage"
        });
    ok( ! $form->validate->is_valid, "Bad data failed 2" )
        or diag explain $form->validate;
}


