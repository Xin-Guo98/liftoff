#!/usr/bin/perl -w
use warnings;
$file=<STDIN>;
open(FILE,$file) or die "cannot open $file:$!";
$i=0;
while($line=<FILE>){
                    if ($line =~ />/) {$i++;}}
print $i,"\n";
close(FILE);
exit;
