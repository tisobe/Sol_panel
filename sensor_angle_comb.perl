#!/usr/bin/perl

#################################################################################################
#												#
#	sensor_angle_comb.perl: this script combine sc fine sensor data and solar angle data.	#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: Jan 10, 2013							#
#												#
#################################################################################################

#
#--- read the latest year
#

$this_year = $ARGV[0];
chomp $this_year;

#
#--- test case; set this "test"
#

$comp_test = $ARGV[1];
chomp $comp_test;

#
#--- set directory
#
if($comp_test =~ /test/i){
#       $dir_list = '/data/mta/Script/Sol_panel/house_keeping/dir_list_test';
        $dir_list = '/data/mta/Script/Sol_panel_linux/house_keeping/dir_list_test';
	$begin_year = 2010;
}else{
        $dir_list = '/data/mta/Script/Sol_panel/house_keeping/dir_list';
	$begin_year = 2000;
}

open(FH, $dir_list);
while(<FH>){
    chomp $_;
        @atemp = split(/\s+/, $_);
        ${$atemp[0]} = $atemp[1];
    }
close(FH);

#
#--- clean up the working directory; remove files named "sensor_angle*"
#
$check = `ls `;
if($check =~ /sensor_angle/){
	system("rm senosr_angle*0");
}

for($year = $begin_year; $year <= $this_year; $year++){
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
#-- find matched time
#
	$m = 0;
	OUTER2:
	for($k = 0; $k < $cnt; $k++){
		if($tfssbkt1[$k] !~ /\d/ || $tfssbkt2[$k] !~ /\d/ || $tpc_fsse[$k] !~ /\d/){
			next OUTER2;
		}

		if($time[$m -1] < $time2[$k] && $time[$m] >= $time2[$k]){
		}elsif($time[$m] < $time2[$k]){
			OUTER3:
			while($time[$m] < $time2[$k]){
				$m++;
				if($time[$m -1] < $time2[$k] && $time[$m] >= $time2[$k]){
					last OUTER3;
				}
				if($m > $cnt){
					last OUTER2;
				}
			}
		}elsif($time[$m] > $time2[$k]){
			OUTER3:
			while($time[$m] > $time2[$k]){
				$m--;
				if($time[$m -1] < $time2[$k] && $time[$m] >= $time2[$k]){
					last OUTER3;
				}
				if($m < 0){
					$m = 0;
					next OUTER2;
				}
			}
		}

                if($angle[$m] > 40  && $angle[$m] <= 60){
                        open(OUT, ">>./sensor_angle40");

                }elsif($angle[$m] > 60  && $angle[$m] <= 80){
                        open(OUT, ">>./sensor_angle60");

                }elsif($angle[$m] > 80  && $angle[$m] <= 100){
                        open(OUT, ">>./sensor_angle80");

                }elsif($angle[$m] > 100  && $angle[$m] <= 120){
                        open(OUT, ">>./sensor_angle100");

                }elsif($angle[$m] > 120  && $angle[$m] <= 140){
                        open(OUT, ">>./sensor_angle120");

                }elsif($angle[$m] > 140  && $angle[$m] <= 160){
                        open(OUT, ">>./sensor_angle140");

                }elsif($angle[$m] > 160  && $angle[$m] <= 180){
                        open(OUT, ">>./sensor_angle160");

                }


		$year_time = sec1998_to_fracyear($time2[$k]);

		print OUT "$year_time\t$tfssbkt1[$k]\t$tfssbkt2[$k]\t$tpc_fsse[$k]\t$angle[$m]\n";
		close(OUT);
		$m++;
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

