#!/usr/bin/perl

#########################################################################################
#											#
#	fit_sin_for_scelec.perl: a control script to fit a sine wave model on the data	#
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

foreach $angle(40, 60, 80, 100, 120, 140, 160){
	$data = "$data_dir".'/Data_scelec/scelec_angle'."$angle".'_elbv.dat';
	$out  = "$data_dir".'/Data_scelec/scelec_angle'."$angle".'_elbv_sine.dat';
	$fnam = "$data_dir".'/Plot_data/scelec_angle'."$angle".'_elbv_sine_param';

#
#--- here is the actual function fitting the model on the data
#
	system("perl $script_dir/sin_wave_scelec.perl $data");
	system("mv sin_data $out");
	system("mv fit_result $fnam");
}

