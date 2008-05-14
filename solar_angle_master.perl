#!/usr/bin/perl

#################################################################################################
#												#
#	solar_angle_master.perl: this is the master script to cotrol all others			#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: May 14, 2008							#
#												#
#################################################################################################

#
#--- set directory
#

$script_dir = '/data/mta/MTA/bin/';
$data_dir   = '/data/mta/Script/Sol_panel/Data/';
$html_dir   = '/data/mta/www/mta_sol_panel/';
$main_dir   = '/data/mta/Script/Sol_panel/';

open(OUT, ">dir_list");
print OUT "$script_dir\n";
print OUT "$data_dir\n";
print OUT "$html_dir\n";
print OUT "$main_dir\n";
close(OUT);

#
#--- find today's date
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
$this_year = 1900 + $uyear;
$uyday++;

#
#--- extract data using dataseeker
#

system("perl  $script/extract_data_from_dataseek.perl");

#
#--- extract solar panel data
#

system("perl $script_dir/solar_panel_angle_comb.perl $this_year");
system("perl $script_dir/sep_col_solar_pan.perl");
system("perl $script_dir/find_env_solar_pan.perl");
system("perl $script_dir/fit_sin_for_sol_pan.perl");

foreach $angle (40, 60, 80, 100, 120, 140, 160){
	$name1 = "$data_dir".'/Data_solar_panel/solar_panel_angle'."$angle";
	$name2 = "$data_dir".'/Data_solar_panel/solar_panel_angle'."$angle".'_tmysada_env.dat';
	$name3 = "$data_dir".'/Data_solar_panel/solar_panel_angle'."$angle".'_tpysada_env.dat';
	$name4 = "$data_dir".'/Plot_data/solar_panel_angle'."$angle".'_tsamyt_sine_param';
	$name5 = "$data_dir".'/Plot_data/solar_panel_angle'."$angle".'_tsapyt_sine_param';
	$out   = "$html_dir".'/Plots/solar_panel_angle'."$angle".'.gif';

	system("perl $script_dir/plot_solar_array_env.perl $name1 $name2 $name3 $name4 $name5");
	system("mv env_plot.gif $out");
}

#
#--- extract spacecraft electric power data
#

system("perl $script_dir/scelec_angle_comb.perl $this_year");
system("perl $script_dir/sep_col_scelec.perl");
system("perl $script_dir/find_env_scelec.perl");
system("perl $script_dir/fit_sin_for_scelec.perl");

foreach $angle (40, 60, 80, 100, 120, 140, 160){
	$name1 = "$data_dir".'/Data_scelec/scelec_angle'."$angle";
	$name2 = "$data_dir".'/Data_scelec/scelec_angle'."$angle".'_elbi_env.dat';
	$name3 = "$data_dir".'/Data_scelec/scelec_angle'."$angle".'_hrma_env.dat';
	$name4 = "$data_dir".'/Data_scelec/scelec_angle'."$angle".'_oba_env.dat';
	$name5 = "$data_dir".'/Plot_data/scelec_angle'."$angle".'_elbv_sine_param';
	$out   = "$html_dir".'/Plots/scelec_angle'."$angle".'.gif';

	system("perl $script_dir/plot_scelec_env.perl $name1 $name2 $name3 $name4 $name5");
	system("mv env_plot.gif $out");
}


#
#--- extract fine sensor temperature data
#

system("perl $script_dir/sensor_angle_comb.perl $this_year");
system("perl $script_dir/sep_col_sensor.perl");
system("perl $script/find_env_sensor.perl");

foreach $angle (40, 60, 80, 100, 120, 140, 160){
	$name1 = "$data_dir".'/Data_sensor/sensor_angle'."$angle";
	$name2 = "$data_dir".'/Data_sensor/sensor_angle'."$angle".'_tfssbkt1_env.dat';
	$name3 = "$data_dir".'/Data_sensor/sensor_angle'."$angle".'_tfssbkt2_env.dat';
	$name4 = "$data_dir".'/Data_sensor/sensor_angle'."$angle".'_tpc_fsse_env.dat';
	$out   = "$html_dir".'/Plots/sensor_angle'."$angle".'.gif';

	system("perl $script_dir/plot_sensor_env.perl $name1 $name2 $name3 $name4");
	system("mv env_plot.gif $out");
}

#
#---- sdsa temp and elbi relation
#

foreach $angle (40, 60, 80, 100, 120, 140, 160){
	$name1 = "$data_dir".'/Data_solar_panel/solar_panel_angle'."$angle".'_tpysada.dat';	
	$name2 = "$data_dir".'/Data_scelec/scelec_angle'."$angle".'_elbi.dat';
	$out   = "$html_dir".'/Plots/sada_elbi_angle'."$angle".'.gif';

	system("perl $script_dir/plot_elbi_sada.perl $name1 $name2");
	system("mv solpan_elbv.gif $out");
}


system("rm pgplot.ps");

$date = `date`;
$line = "Last Update: $date";

open(FH, "$html_dir/solarpanel.html");
open(OUT, ">temp");
while(<FH>){
	chomp $_;
	if($_ =~ /Last Updated/){
		print OUT "$line\n";
	}else{
		print OUT "$_\n";
	}
}
close(OUT);
close(FH);

system("mv $html_dir/solarpanel.html $html_dir/solarpanel.html~");
system("mv temp $html_dir/solarpanel.html");

