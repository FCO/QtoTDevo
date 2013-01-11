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
    if(not $obj->in_storage) {
      $obj->value(0);
      $obj->insert
    }
    $emprestimos{$creditor->name}{$debtor->name} = $obj;
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
    my $val = $self->param($debtor);
    next unless defined $val;
    my $obj = $emprestimos{$creditor}{$debtor};
    $obj->update({value => $val + $obj->value});
    $db->resultset("Change")->create({creditor => $obj->creditor->id, debtor => $obj->debtor->id, new_value => $obj->value});
  }
  $self->calc(\%emprestimos);
  $self->redirect_to("index");
};

websocket '/ws/event' => sub {
  my $self = shift;
  my $last_id = $db->resultset("Change")->get_column("id")->max;
  my $id = Mojo::IOLoop->recurring(3 => sub {
    my @chg = $db->resultset("Change")->search({id => {">" => $last_id}}, {order_by => 'id'})->all;
    if(@chg) {
      $self->send(Mojo::JSON->encode([
        map {{
          creditor  => $_->creditor->name,
          debtor    => $_->debtor->name,
          new_value => $_->new_value,
        }} @chg])
      );
      $last_id = $chg[-1]->id;
      app->log->debug($last_id);
    }
  });
  #$self->on(finish => sub { Mojo::IOLoop->remove($id) });
} => "ws";

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
        $cred_deb_obj->value($cred_deb - $deb_cred);
        $cred_deb_obj->update;
        $deb_cred_obj->value(0);
        $deb_cred_obj->update
      }
    }
  }
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Tabela de ';
<script>
  var ws = new WebSocket("<%= url_for("ws")->to_abs =%>");
  ws.onmessage = function(event) {
    var data = JSON.parse(event.data);
    for(var i = 0; i < data.length; i++) {
      var change = data[i];
      var creditor = change['creditor'];
      var debtor   = change['debtor'];
      var value    = change['new_value'];

      document.querySelector("table td.creditor_" + creditor + ".debtor_" + debtor).innerHTML = value;
    }
  };
</script>
<table border=1>
  <thead>
    <tr>
      <td></td>
      <% for my $pessoa(map {$_->name} @$pessoas) { %>
        <th id="creditor_<%= $pessoa =%>"><a href="/<%= $pessoa =%>"><%= $pessoa =%></a></th>
      <% } %>
    </tr>
  </thead>
  <tbody>
    <% for my $pessoa_col (@$pessoas) { %>
      <tr>
        <th id="debtor_<%= $pessoa_col =%>"><a href="/<%= $pessoa_col->name =%>"><%= $pessoa_col->name =%></a></th>
          <% for my $pessoa_row (@$pessoas) { %>
            <td class="creditor_<%= $pessoa_col->name %> debtor_<%= $pessoa_row->name %>">
              <%= $emprestimos->{$pessoa_col->name}{$pessoa_row->name}->value =%>
            </td>
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
