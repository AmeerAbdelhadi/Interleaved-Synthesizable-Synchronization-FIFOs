#!/usr/bin/perl -w

####################################################################################
## Copyright (c) 2016, University of British Columbia (UBC)  All rights reserved. ##
##                                                                                ##
## Redistribution  and  use  in  source   and  binary  forms,   with  or  without ##
## modification,  are permitted  provided that  the following conditions are met: ##
##   * Redistributions   of  source   code  must  retain   the   above  copyright ##
##     notice,  this   list   of   conditions   and   the  following  disclaimer. ##
##   * Redistributions  in  binary  form  must  reproduce  the  above   copyright ##
##     notice, this  list  of  conditions  and the  following  disclaimer in  the ##
##     documentation and/or  other  materials  provided  with  the  distribution. ##
##   * Neither the name of the University of British Columbia (UBC) nor the names ##
##     of   its   contributors  may  be  used  to  endorse  or   promote products ##
##     derived from  this  software without  specific  prior  written permission. ##
##                                                                                ##
## THIS  SOFTWARE IS  PROVIDED  BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" ##
## AND  ANY EXPRESS  OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT LIMITED TO,  THE ##
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE ##
## DISCLAIMED.  IN NO  EVENT SHALL University of British Columbia (UBC) BE LIABLE ##
## FOR ANY DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL ##
## DAMAGES  (INCLUDING,  BUT NOT LIMITED TO,  PROCUREMENT OF  SUBSTITUTE GOODS OR ##
## SERVICES;  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER ##
## CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT LIABILITY, ##
## OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE ##
## OF  THIS SOFTWARE,  EVEN  IF  ADVISED  OF  THE  POSSIBILITY  OF  SUCH  DAMAGE. ##
####################################################################################

####################################################################################
##                      generates netlist statistic data                          ##
##             Author: Ameer Abdelhadi (ameer.abdelhadi@gmail.com)                ##
## Cell-based interleaved FIFO :: The University of British Columbia :: Nov. 2016 ##
####################################################################################

use Storable;
use strict;   # Install all strictures
use warnings; # Show warnings
$|++;         # Force auto flush of output buffer

my %cllLib;
my $cllLibRef;

if (-e 'stdCllLib.hash') {
  $cllLibRef = retrieve('stdCllLib.hash');
  %cllLib = %$cllLibRef;
} else {
  # parse lib file
  my $libFNM = "$ENV{'LIBDBB'}/$ENV{'LIBNAM'}$ENV{'LIBCOR'}.lib";
  open(LIBHND,$libFNM) || die "Can't open lib file: $libFNM";
  my @libLines = <LIBHND>;
  chomp(@libLines);
  close(LIBHND);
  for (my $i=0; $i<$#libLines; $i++) {
    if ($libLines[$i] =~ /^\s*cell\s*\((\S+)\)\s*\{/) {
      my $curCllNam = $1;
      my $curCllAre = 0;
      my $curIsCllSeq = 0;
      do {
        $i++;
        if ($libLines[$i] =~ /^\s*area\s*:\s*(\d+\.*\d*)\s*\;/) { $curCllAre = $1;}
        if ($libLines[$i] =~ /^\s*clock\s*:\s*true\s*\;/) { $curIsCllSeq = 1;}
      } while (($libLines[$i] !~ /^\s*cell\s*\((\S+)\)\s*\{/) & ($i<$#libLines));  
      $cllLib{$curCllNam}{'area'} = $curCllAre;
      $cllLib{$curCllNam}{'isSeq'} = $curIsCllSeq;
      $cllLib{$curCllNam}{'count'} = 0;
      $i--;
    }
  }
  # parse spi file
  my $spiFNM = "$ENV{'LIBSPI'}";
  open(SPIHND,$spiFNM) || die "Can't open spi file: $spiFNM";
  my @spiLines = <SPIHND>;
  chomp(@spiLines);
  close(SPIHND);
  for (my $i=0; $i<=$#spiLines; $i++) {
    # ignore comment lines
    if ($spiLines[$i] =~ /^\s*\*/) {next}
    # ignore empty lines
    if ($spiLines[$i] =~ /^\s*$/ ) {next}
    # if .subckt keyword, define new cell
    if ($spiLines[$i] =~ /^\s*\.subckt\s+(\S+)/ ) {
      $i++;
      my $curCll = $1;
      $cllLib{$curCll}{'nchDevCnt'} = 0;
      $cllLib{$curCll}{'pchDevCnt'} = 0;
      $cllLib{$curCll}{'devCnt'} = 0;
      $cllLib{$curCll}{'count'} = 0;
      while ($spiLines[$i] !~ /^\s*\.ends\s*$/) {
        my @device = split(/\s+/,$spiLines[$i]);
        if ($device[5] eq "nch") {$cllLib{$curCll}{'nchDevCnt'}++;$cllLib{$curCll}{'devCnt'}++;}
        if ($device[5] eq "pch") {$cllLib{$curCll}{'pchDevCnt'}++;$cllLib{$curCll}{'devCnt'}++;}     
        $i++;
      }
    }
  }

  store(\%cllLib,'stdCllLib.hash');

}

my $netFN = $ARGV[0];
open(NETHND,$netFN) || die "Can't open netlist file";
my @netLines = <NETHND>;
chomp(@netLines);
close(NETHND);

my @chunks = split(/\s*\;\s*/,"@netLines");

foreach my $chunk (@chunks) {
  if ($chunk =~ /^\s*$|^\s*module\s+|^\s*endmodule\s+|^\s*input\s+|^\s*output\s+|^\s*wire\s+|^\s*reg\s+/) {next}
  if (($chunk =~ /^\s*(\S+)\s+(\S+)\s+\(.*\)\s*$/) && (exists $cllLib{$1})) {
    $cllLib{$1}{'count'}++;
  }
}

my $format = "%-15s%-15s%-15u%-13.2f%-15u%-15u%-15u\n";
my $title_format = "%-15s%-15s%-15s%-15s%-15s%-15s%-15s\n";
my $spacer = "=" x 103 . "\n";
print $spacer;
printf($title_format,"Cell","Cell","Cells","Cells"      ,"P-ch devices","N-ch devices","Total devices");
printf($title_format,"name","type","count","area (um^2)","count"       ,"count"       ,"count"        );
print $spacer;

my $totCllCnt = 0;
my $totSeqCllCnt = 0;
my $totCllAre = 0;
my $totSeqCllAre = 0;
my $totPchDevCnt = 0;
my $totNchDevCnt = 0;
my $totSeqPchDevCnt = 0;
my $totSeqNchDevCnt = 0;
foreach my $curCll (keys(%cllLib)) {
  if ($cllLib{$curCll}{'count'} > 0) {
    $totCllCnt    += $cllLib{$curCll}{'count'};
    $totPchDevCnt += $cllLib{$curCll}{'count'} * $cllLib{$curCll}{'pchDevCnt'};
    $totNchDevCnt += $cllLib{$curCll}{'count'} * $cllLib{$curCll}{'nchDevCnt'};
    $totCllAre    += $cllLib{$curCll}{'count'} * $cllLib{$curCll}{'area'};
    if ($cllLib{$curCll}{'isSeq'}) {
      $totSeqCllCnt    += $cllLib{$curCll}{'count'};
      $totSeqPchDevCnt += $cllLib{$curCll}{'count'} * $cllLib{$curCll}{'pchDevCnt'};
      $totSeqNchDevCnt += $cllLib{$curCll}{'count'} * $cllLib{$curCll}{'nchDevCnt'};
      $totSeqCllAre    += $cllLib{$curCll}{'count'} * $cllLib{$curCll}{'area'};
    }
    printf($format,$curCll,$cllLib{$curCll}{'isSeq'}?"Sequential":"Combinatorial",$cllLib{$curCll}{'count'},$cllLib{$curCll}{'area'},$cllLib{$curCll}{'pchDevCnt'},$cllLib{$curCll}{'nchDevCnt'},$cllLib{$curCll}{'pchDevCnt'}+$cllLib{$curCll}{'nchDevCnt'});
  }
}

print $spacer;
printf($format,'COMBINATORIAL','',$totCllCnt-$totSeqCllCnt,$totCllAre-$totSeqCllAre,$totPchDevCnt-$totSeqPchDevCnt,$totNchDevCnt-$totSeqNchDevCnt,$totPchDevCnt-$totSeqPchDevCnt+$totNchDevCnt-$totSeqNchDevCnt);
printf($format,'SEQUENTIAL'   ,'',$totSeqCllCnt           ,$totSeqCllAre           ,$totSeqPchDevCnt              ,$totSeqNchDevCnt,$totSeqPchDevCnt+$totSeqNchDevCnt                                          );
printf($format,'TOTAL'        ,'',$totCllCnt              ,$totCllAre              ,$totPchDevCnt                 ,$totNchDevCnt   ,$totPchDevCnt+$totNchDevCnt                                                );

print $spacer;
