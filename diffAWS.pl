#!/usr/bin/perl

use strict;
use warnings;

if($#ARGV != 1){
  print "usage : diffAWS.pl <service> <region>\n";
  print "example : diffAWS.pl AMAZON GLOBAL\n";
  exit;
}

my $service=shift(@ARGV);
my $region=shift(@ARGV);

my $folder='/home/user/operations/AWSRanges';

my $net = {};
my $old=0;
my $new=0;

#Grab AWS ranges from python script
`python $folder/getAwsIpByZone.py $region $service > $folder/.awsranges`;

open(my $file1, "$folder/.awsranges");
#Parse AWS ranges from format : Service;ip;mask
while (my $line = <$file1>){
  chomp $line;
  if ($line =~ m/(AWS_${service}_${region}_\S*);([0-9.]*);([0-9.]*)/){
    &addNetwork($1,$2,$3);
    $new ++;
  }
}
close $file1;


open(my $file2, "$folder/FWdefinitions.txt");
#parse FW definition sent from smartcenter (cronuser's crontab)
while (my $line = <$file2>){
  chomp $line;
  while ($line =~ s/(AWS_${service}_${region}_\S*)//){
    &addElement($1,'old');
    $old ++;
#print "$1\n";
  }
}

close $file2;

my @added ;
my @removed ;

#sort out which networks were added or removed
while (my ($key,$data) = each %$net){
  if(exists($data->{'old'}) && !exists($data->{'new'})){
     push @removed,$key;
  }
  if(exists($data->{'new'}) && !exists($data->{'old'})){
     push @added,$key;
  }
}

#print results


print "----------------------- Commands -------------------------\n";
print "- Run them in 'dbedit -local -globallock' on smartcenter -\n";
print "----------------------------------------------------------\n";

foreach my $rem(@removed){

  print "rmelement network_objects AWS_".$service."_".$region." '' network_objects:$rem\n";

}
foreach my $netName(@added){

  print "create network ".$netName."\n";
  print "modify network_objects ".$netName." ipaddr ".$net->{$netName}->{'ip'}."\n";
  print "modify network_objects ".$netName." netmask ".$net->{$netName}->{'mask'}."\n";
  print "modify network_objects ".$netName." color orange"."\n";
  print "modify network_objects ".$netName." comments \"IPv4 ".$region." ".$service."\""."\n";
  print "update network_objects ".$netName."\n";
  print "savedb \n";
  print "addelement network_objects AWS_".$service."_".$region." '' network_objects:".$netName."\n";

}
print "update_all\nsavedb\n";


print "------------------ Overview ---------------\n";
print "Networks in group : \nCurrent : $old\nNew :$new\n";
print "Added networks : \n";
print "\t".join("\n\t",@added)." \n\ttotal ".scalar(@added)."\n";
print "Removed networks : \n";
print "\t".join("\n\t",@removed)." \n\ttotal ".scalar(@removed)."\n";


sub addElement(){
  my ($key,$val) = @_;

  if(!exists $net->{$key}){
    $net->{$key} = {};
  }
  $net->{$key}->{$val} = 1;
}

sub addNetwork(){
  my ($name,$ip,$mask) = @_;

  if(!exists $net->{$name}){
    $net->{$name} = {};
  }
  $net->{$name}->{'new'} = 1;
  $net->{$name}->{'ip'} = $ip;
  $net->{$name}->{'mask'} = $mask;
}

#exit code 0 if no changes, otherwise, sum of nb of removed networks + added networks
my $exitcode=scalar(@removed)+scalar(@added);

exit $exitcode;
