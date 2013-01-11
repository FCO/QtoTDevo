use utf8;
package QtoTDevo::Schema::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

QtoTDevo::Schema::Result::Person

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<person>

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_unique>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_unique", ["name"]);

=head1 RELATIONS

=head2 loan_creditors

Type: has_many

Related object: L<QtoTDevo::Schema::Result::Loan>

=cut

__PACKAGE__->has_many(
  "loan_creditors",
  "QtoTDevo::Schema::Result::Loan",
  { "foreign.creditor" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 loan_debtors

Type: has_many

Related object: L<QtoTDevo::Schema::Result::Loan>

=cut

__PACKAGE__->has_many(
  "loan_debtors",
  "QtoTDevo::Schema::Result::Loan",
  { "foreign.debtor" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-01-11 08:29:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BMm7j5d3FRDNjRJnYSdOhw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
