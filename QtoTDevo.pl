#!/usr/bin/env perl
use Mojolicious::Lite;

my @pessoas	= qw/Fernando Daniel Thiago/;
my %emprestimos	= (
	map {
		my $key = $_;
		{
			$key => {
				map { ($_ => 0) } grep {$_ ne $key} @pessoas
			}
		}
	} @pessoas
);

get '/' => sub {
  my $self = shift;
  $self->render('index', emprestimos => \%emprestimos, pessoas => \@pessoas);
} => "index";

get '/:name' => sub {
  my $self = shift;
  $self->render('form', pessoas => [grep {$_ ne $self->stash->{name}} @pessoas]);
};

post '/:name' => sub {
  my $self = shift;
  my $name = $self->stash->{name};
  for my $pessoa(keys %{ $emprestimos{$name} }) {
    $emprestimos{$name}{$pessoa} += $self->param($pessoa);
  }
  $self->calc(\%emprestimos);
  $self->redirect_to("index");
};

helper "calc" => sub{
  my $self		= shift;
  my $emprestimos	= shift;

  for my $name(keys %{ $emprestimos }) {
    for my $pessoa(keys %{ $emprestimos->{$name} }) {
      if($emprestimos->{$name}{$pessoa} >= $emprestimos->{$pessoa}{$name}) {
        $emprestimos->{$name}{$pessoa} -= $emprestimos->{$pessoa}{$name};
        $emprestimos->{$pessoa}{$name} = 0
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
      <% for my $pessoa(@$pessoas) { %>
        <td><a href="/<%= $pessoa =%>"><%= $pessoa =%></a></td>
      <% } %>
    </tr>
  </thead>
  <tbody>
    <% for my $pessoa_col (@$pessoas) { %>
      <tr>
        <td><a href="/<%= $pessoa_col =%>"><%= $pessoa_col =%></a></td>
          <% for my $pessoa_row (@$pessoas) { %>
            <td><%= $emprestimos->{$pessoa_col}{$pessoa_row} =%></td>
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
