#!/usr/bin/perl

use Time::Local;



#------------------------------------#
#  Convert date to UNIX timestamp    #
#------------------------------------#
sub date2timestamp {
        my ($inputformat)  = shift;
        my ($datestring)   = shift;
        my $timestamp;
        my @temp;

        if ($inputformat eq "dd.mm.yyyy") {
                @temp = split (/\./,$datestring);
                $timestamp = timelocal(0,0,0,$temp[0],$temp[1]-1,$temp[2]-1900);
        }
        elsif ($inputformat eq "yyyy-mm-dd HH:MM:SS") {
                @temp = split (/-|:|\x20/,$datestring);
                $timestamp = timelocal($temp[5],$temp[4],$temp[3],$temp[2],$temp[1]-1,$temp[0]-1900);
        }
        elsif ($inputformat eq "yyyymmddHHMMSS") {
                $temp[0] = substr($datestring, 0,4);
                $temp[1] = substr($datestring, 4,2);
                $temp[2] = substr($datestring, 6,2);
                $temp[3] = substr($datestring, 8,2);
                $temp[4] = substr($datestring, 10,2);
                $temp[5] = substr($datestring, 12,2);
                $timestamp = timelocal($temp[5],$temp[4],$temp[3],$temp[2],$temp[1]-1,$temp[0]-1900);
        }
        else {
                $timestamp = 0;
        }

        return($timestamp);
} 
