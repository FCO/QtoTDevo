use utf8;
package QtoTDevo::Schema::Result::Change;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

QtoTDevo::Schema::Result::Change

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<change>

=cut

__PACKAGE__->table("change");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 creditor

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 debtor

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 new_value

  data_type: 'real'
  is_nullable: 0

=head2 sent

  data_type: 'bool'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "creditor",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "debtor",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "new_value",
  { data_type => "real", is_nullable => 0 },
  "sent",
  { data_type => "bool", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 creditor

Type: belongs_to

Related object: L<QtoTDevo::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "creditor",
  "QtoTDevo::Schema::Result::Person",
  { id => "creditor" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 debtor

Type: belongs_to

Related object: L<QtoTDevo::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "debtor",
  "QtoTDevo::Schema::Result::Person",
  { id => "debtor" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-01-11 09:21:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qpTXoNQ97iai/CQH7R0oYQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
