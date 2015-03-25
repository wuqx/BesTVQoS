#! /usr/bin/env perl

use Time::Local;

$date = shift @ARGV;
$savedir = shift @ARGV;

foreach $filename (@ARGV) {

	open FILE, "<$filename";
	
	$tw = 0;
	$records = 0;
	while(<FILE>) {
		chomp;
		@element = split /\|/;
		
		$key = $element[7];
		#print "$key\n";
		
		#if ($element[31] == 1) {
		
		if ( ($element[11] !~ /^$date/) || ($element[12] !~ /^$date/) ) {
			#print ERR "@element\n";
			next;
		}
		
		#print $element[11]."_".$element[12]."\n";
		
		$year = substr($element[11], 0, 4);
		$month = substr($element[11], 4, 2);
		$day = substr($element[11], 6, 2);
		$hour = substr($element[11], 8, 2);
		$min = substr($element[11], 10, 2);
		$sec = substr($element[11], 12, 2);
		$beginTime = timelocal($sec, $min, $hour, $day, $month, $year);
		
		$year = substr($element[12], 0, 4);
		$month = substr($element[12], 4, 2);
		$day = substr($element[12], 6, 2);
		$hour = substr($element[12], 8, 2);
		$min = substr($element[12], 10, 2);
		$sec = substr($element[12], 12, 2);
		$endTime = timelocal($sec, $min, $hour, $day, $month, $year);
		
		$watch_time = $endTime - $beginTime;
		
		$play_time{$key} += $watch_time;
		
		$records += 1;	
		#}
	}
	
	close FILE;
	
	# for write results
	foreach $k (%play_time) {
		$watch .= $play_time{$k}." ";		
	}
	
	@ptime = split / /, $watch;
	
	@time_sorted = sort { $a <=> $b } @ptime;
	$suc_total = @time_sorted;
	$idx_25 = $suc_total * 0.25;
	$idx_50 = $suc_total * 0.50;
	$idx_75 = $suc_total * 0.75;
	$idx_90 = $suc_total * 0.90;
	$idx_95 = $suc_total * 0.95;
	
	$tw += $_ for @ptime;
	$avgw = ($suc_total==0)?0:$tw/$suc_total;
	
	open OUT, ">$savedir/playtm_by_usr";
	printf OUT ("|%d|%d|%d|%d|%d|%d|%.2f|%d|%d|\n", $date, $time_sorted[$idx_25], $time_sorted[$idx_50], $time_sorted[$idx_75], $time_sorted[$idx_90], $time_sorted[$idx_95], $avgw, $suc_total, $records);
	close OUT;
}

