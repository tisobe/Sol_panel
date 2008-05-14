#!/usr/bin/perl

#########################################################################################
#											#
#	sep_col_sensor.perl: separate fine sensor data into each element		#
#											#
#		author: t. isobe (tisobe@cfa.harvard.edu)				#
#											#
#		last update: May 08, 2008						#
#											#
#########################################################################################

#
#---set directory
#

open(FH, "./dir_list");
@atemp = ();
while(<FH>){
        chomp $_;
        push(@atemp, $_);
}
close(FH);
$script_dir = $atemp[0];
$data_dir   = $atemp[1];
$html_dir   = $atemp[2];
$main_dir   = $atemp[3];

if($data_dir eq ''){
        $data_dir = './';
}

@col_name = ('tfssbkt1', 'tfssbkt2', 'tpc_fsse');
foreach $angle (40, 60, 80, 100, 120, 140, 160){
	$data = "$data_dir".'/Data_sensor/sensor_angle'."$angle";
	for($i = 1; $i < 4; $i++){
		$name = "$data_dir".'/Data_sensor/sensor_angle'."$angle".'_'."$col_name[$i -1]".'.dat';
		open(FH, "$data");
		open(OUT, ">$name");
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/, $_);
			print OUT "$atemp[0]\t$atemp[$i]\n";
		}
		close(OUT);
		close(FH);
	}
}
