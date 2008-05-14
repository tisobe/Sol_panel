#!/usr/bin/perl

#################################################################################################
#												#
#	sensor_angle_comb.perl: this script combine sc fine sensor data and solar angle data.	#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: May 7, 2008							#
#												#
#################################################################################################

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
#--- read the latest year
#

$this_year = $ARGV[0];
chomp $this_year;

#
#--- clean up the working directory; remove files named "sensor_angle*"
#
$check = `ls `;
if($check =~ /sensor_angle/){
	system("rm senosr_angle*0");
}

for($year = 2000; $year <= $this_year; $year++){
	$file1 = "$data_dir".'/Ind_data_files/angle'."$year".'.dat';
	$file2 = "$data_dir".'/Ind_data_files/sensor'."$year".'.dat';

	@time     = ();
	@time2    = ();
	@angle    = ();
	@tfssbkt1 = ();
	@tfssbkt2 = ();
	@tpc_fsse = ();
	$cnt      = 0;
	$cnt2     = 0;

	open(FH, "$file1");		#----- solar angle data
	OUTER:
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		if($atemp[1] !~ /\d/){
			next OUTER;
		}
		if($atemp[0] =~ /\d/){
			push(@time,  $atemp[1]);
			push(@angle, $atemp[2]);
		}else{
			push(@time,  $atemp[2]);
			push(@angle, $atemp[3]);
		}
		$cnt++;
	}
	close(FH);

	open(FH, "$file2");		#----- fine sensor temperature data
	OUTER:
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		if($atemp[1] !~ /\d/){
			next OUTER;
		}
		if($atemp[0] =~ /\d/){
			push(@time2,    $atemp[1]);
			push(@tfssbkt1, $atemp[2]);
			push(@tfssbkt2, $atemp[3]);
			push(@tpc_fsse, $atemp[4]);
			$cnt2++;
		}else{
			push(@time2,    $atemp[2]);
			push(@tfssbkt1, $atemp[3]);
			push(@tfssbkt2, $atemp[4]);
			push(@tpc_fsse, $atemp[5]);
			$cnt2++;
		}
	}
	close(FH);

#
#-- cycle around data for each solar angle interval 
#
	for($j = 0; $j < 7; $j++){
		$angle1 = 40 + 20 * $j;
		$angle2 = $angle1 + 20;
	
		$out_file = './sensor_angle'."$angle1";
		open(OUT, ">>$out_file");
	
		$m = 0;
		OUTER2:
		for($k = 0; $k < $cnt; $k++){
			if($tfssbkt1[$k] !~ /\d/ || $tfssbkt2[$k] !~ /\d/ || $tpc_fsse[$k] !~ /\d/){
				next OUTER2;
			}

			if($time[$m] < $time2[$k]){
				while($time[$m] < $time2[$k]){
					$m++;
				}
			}elsif($time[$m] > $time2[$k]){
				while($time[$m] > $time2[$k]){
					$m--;
				}
			}

			if($angle[$m] > $angle1 && $angle[$m] <= $angle2){

				$year_time = sec1998_to_fracyear($time2[$k]);

				print OUT "$year_time\t$tfssbkt1[$k]\t$tfssbkt2[$k]\t$tpc_fsse[$k]\t$angle[$m]\n";
			}
			$m++;
		}
		close(OUT);
	}
}

#
#--- replace old ones with the new one just complied
#

system("mv sensor_angle* $data_dir/Data_sensor/");


###############################################################################
###sec1998_to_fracyear: change sec from 1998 to time in year               ####
###############################################################################

sub sec1998_to_fracyear{

        my($t_temp, $normal_year, $leap_year, $year, $j, $k, $chk, $jl, $base, $yfrac);

        ($t_temp) = @_;

        $t_temp += 86400;

        $normal_year = 31536000;
        $leap_year   = 31622400;
        $year        = 1998;

        $j = 0;
        OUTER:
        while($t_temp > 1){
                $jl = $j + 2;
                $chk = 4.0 * int(0.25 * $jl);
                if($chk == $jl){
                        $base = $leap_year;
                }else{
                        $base = $normal_year;
                }

                if($t_temp > $base){
                        $year++;
                        $t_temp -= $base;
                        $j++;
                }else{
                        $yfrac = $t_temp/$base;
                        $yearfac = $year + $yfrac;
                        last OUTER;
                }
        }

        return $yearfac;
}

