use Test::More;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Form::Sensible;

use Form::Sensible::Form;

my $lib_dir = $FindBin::Bin;
my @dirs = split '/', $lib_dir;
pop @dirs;
$lib_dir = join('/', @dirs);


my $form_1 = Form::Sensible->create_form( {
    name => 'form_1',
    fields => [
        {
            field_class => 'Text',
            name => 'field_1_1',
            maximum_length => 10,
        },
    ],
} );

$form_1->set_values({
    field_1_1 => 'A' x 11,
});

my $form_2 = Form::Sensible->create_form( {
    name => 'form_2',
    fields => [
        {
            field_class => 'Text',
            name => 'field_2_1',
            maximum_length => 10,
        },
        {
            field_class => 'SubForm',
            name => 'subform',
            form => $form_1,
        },
    ],
} );

$form_2->set_values({
    field_2_1 => 'A' x 11,
});

my $validation_result = $form_2->validate();

ok( !$validation_result->is_valid(), "subform with field longer than max length failed");
is( scalar(keys %{$validation_result->{error_fields}}), 2, "correct number of incorrect fields" );

note explain $form_2;
my @fields = $form_2->get_all_fields;
is( $#fields, 1, "2 fields found" );
is( $fields[0]->name, 'field_2_1', "First field is from parent form" );
is( $fields[1]->name, 'field_1_1', "Second field is from subform" );

my $values = $form_2->get_all_values;
is( scalar keys %$values, 2, "2 values found" );
is( $values->{'field_2_1'}, $form_2->field('field_2_1')->value, "Parent form value matches" );
is( $values->{'field_1_1'}, $form_1->field('field_1_1')->value, "Subform value matches" );

$form_2->set_values({ field_1_1 => 'subform-value', field_2_1 => 'parent-value' });
my $values = $form_2->get_all_values;
is( $values->{'field_2_1'}, 'parent-value', "Parent form value set" );
is( $values->{'field_1_1'}, 'subform-value', "Subform value set" );

done_testing();

