#!/usr/bin/env perl
use Mojolicious::Lite;
use lib "lib";
use QtoTDevo::Schema;

my $db = QtoTDevo::Schema->connect("dbi:SQLite:dbname=./qtotdevo.db");

my @pessoas = $db->resultset("Person")->all;

my %emprestimos;
for my $creditor(@pessoas) {
  for my $debtor(@pessoas) {
    my $obj = $db->resultset("Loan")->find_or_new({creditor => $creditor, debtor => $debtor});
    if($obj->in_storage) {
      $obj->value(0);
      $obj->insert
    }
    $emprestimos{$creditor}{$debtor} = $obj;
  }
}

get '/' => sub {
  my $self = shift;
  $self->render('index', emprestimos => \%emprestimos, pessoas => [@pessoas]);
} => "index";

get '/:name' => sub {
  my $self = shift;
  $self->render('form', pessoas => [grep {$_ ne $self->stash->{name}} map {$_->name} @pessoas]);
};

post '/:name' => sub {
  my $self = shift;
  my $creditor = $self->stash->{name};
  for my $debtor(keys %{ $emprestimos{$creditor} }) {
    $emprestimos{$creditor}{$debtor}->value($self->param($debtor) + $emprestimos{$creditor}{$debtor}->value);
    $emprestimos{$creditor}{$debtor}->update
  }
  $self->calc(\%emprestimos);
  $self->redirect_to("index");
};

helper "calc" => sub{
  my $self		= shift;
  my $emprestimos	= shift;

  for my $creditor(keys %{ $emprestimos }) {
    for my $debtor(keys %{ $emprestimos->{$creditor} }) {
      my $cred_deb_obj	= $emprestimos->{$creditor}{$debtor};
      my $deb_cred_obj	= $emprestimos->{$debtor}{$creditor};
      my $cred_deb	= $cred_deb_obj->value;
      my $deb_cred	= $deb_cred_obj->value;
      if($cred_deb >= $deb_cred) {
        $cred_deb->value($cred_deb - $deb_cred);
        $cred_deb->update;
        $deb_cred->value(0);
        $deb_cred->update
      }
    }
  }
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<table border=1>
  <thead>
    <tr>
      <td></td>
      <% for my $pessoa(map {$_->name} @$pessoas) { %>
        <td><a href="/<%= $pessoa =%>"><%= $pessoa =%></a></td>
      <% } %>
    </tr>
  </thead>
  <tbody>
    <% for my $pessoa_col (@$pessoas) { %>
      <tr>
        <td><a href="/<%= $pessoa_col->name =%>"><%= $pessoa_col->name =%></a></td>
          <% for my $pessoa_row (@$pessoas) { %>
            <td>**<%= $emprestimos->{$pessoa_col}{$pessoa_row}->value =%>**</td>
          <% } %>
      <tr>
    <% } %>
  </tbody>
</table>

@@ form.html.ep
% layout 'default';
% title 'Welcome';
<form method=POST>
  <table>
    <% for my $pessoa(@$pessoas) { %>
      <tr>
        <td><%= $pessoa =%></td>
        <td><input name=<%= $pessoa =%>></td>
      </tr>
    <% } %>
      <tr>
        <td>
          <input type=submit value=ok>
        </td>
      </tr>
  </table>
</form>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
