#!/usr/bin/perl

#########################################################################################
#											#
#	fit_sin_for_sol_pan.perl: control script to fit sin wave model to data		#
#											#
#		author: t. isobe (tisobe@cfa.harvard.edu)				#
#											#
#		last update: May 14, 2008						#
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


foreach $angle(40, 60, 80, 100, 120, 140, 160){
	foreach $side ('tsapyt', 'tsamyt'){
		$data = "$data_dir".'/Data_solar_panel/solar_panel_angle'."$angle".'_'."$side".'.dat';
		$out  = "$data_dir".'/Data_solar_panel/solar_panel_angle'."$angle".'_'."$side".'_sine.dat';
		$fnam = "$data_dir".'/Plot_data/solar_panel_angle'."$angle".'_'."$side".'_sine_param';
#
#--- here is the function actually fitting the model on the data
#
		system("perl $script_dir/sin_wave_sol_panel.perl $data");
		system("mv sin_data $out");
		system("mv fit_result $fnam");
	}
}

