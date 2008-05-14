#!/usr/bin/perl

#########################################################################################
#											#
#	find_env_solar_pan.perl: find a moving average and an envelop for the soloar 	#
#				 panel data (tmysada and tpysada only)			#
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

#
#--- set a couple of input for find_moving_avg.perl script
#

$arange = '0.20';		#--- a period
$step   = '0.10';		#--- a step size
$nterms = 4;			#--- a degree of polynomial fitting

foreach $angle (40, 60, 80, 100, 120, 140, 160){
#
#--- this script runs for tmysada and tpysada only. tsamyt and tsapyt use another script (sine wave fitting)
#

	foreach $col ('tmysada','tpysada'){
		$name = "$data_dir".'/Data_solar_panel/solar_panel_angle'."$angle".'_'."$col".'.dat';
		$out  = "$data_dir".'/Data_solar_panel/solar_panel_angle'."$angle".'_'."$col".'_env.dat';
                $chk = 0;
#
#--- remove any lines which contains "NaN" (no data)
#

                open(FH, "$name");
                open(OUT, "> temp_out");
                while(<FH>){
                        chomp $_;
                        if($_ !~ /NaN/){
                                print OUT "$_\n";
                        }else{
                                $chk++;
                        }
                }
                close(FH);
                if($chk > 0){
                        system("mv temp_out $name");
                }else{
                        system("rm temp_out");
                }
#
#--- find a moving average and an envelop for the data
#
		system("perl $script_dir/find_moving_avg.perl $name $arange $step $nterms $out ");
	}
}
			

