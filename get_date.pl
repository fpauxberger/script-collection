#!/usr/bin/perl -w


#
#
# Change Apache httpd time to UNIX timestamp 
#
#


use strict;
use Time::Local;

my $file	= "access_log";
my $line;
my $date;
my $ts;
my $year;
my $month;
my $day;
my $hour;
my $minute;
my $sec;


open (FILE ,"< $file");

while(<FILE>) {
	$line = $_;
	$line =~ /\[(.*) \+0200\]/;
	$date = $1;

	$year 	= substr($date, 7, 4);
	$month 	= substr($date, 3, 3);
	$month	= get_month($month);
	$day	= substr($date, 0, 2);
	$hour	= substr($date, 12, 2);	
	$minute	= substr($date, 15, 2);	
	$sec	= substr($date, 18, 2);	
	$date   =  $year.$month.$day.$hour.$minute.$sec;

	$ts   = &date2timestamp("yyyymmddHHMMSS", $date);
	
	print $date." -> ".$ts."\n";
}

sub get_month {
	my $str = shift;

	if ( $str eq "Jan") {
		$month = "01";
	}
	elsif ( $str eq "Feb") {
		$month = "02";
	}
	elsif ( $str eq "Mar") {
		$month = "03";
	}
	elsif ( $str eq "Apr") {
		$month = "04";
	}
	elsif ( $str eq "May") {
		$month = "05";
	}
	elsif ( $str eq "Jun") {
		$month = "06";
	}
	elsif ( $str eq "Jul") {
		$month = "07";
	}
	elsif ( $str eq "Aug") {
		$month = "08";
	}
	elsif ( $str eq "Sep") {
		$month = "09";
	}
	elsif ( $str eq "Oct") {
		$month = "10";
	}
	elsif ( $str eq "Nov") {
		$month = "11";
	}
	elsif ( $str eq "Dec") {
		$month = "12";
	}
	else {
		print "Fehler bei Monat konvertierung ($str)!!\n";
		exit;
	}
	return $month;
}


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
