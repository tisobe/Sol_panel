#!/usr/bin/perl

#################################################################################################
#												#
#	solar_panel_angle_comb.perl: this script combine solar panel data and solar agnle data.	#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: May 12, 2008							#
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
#--- clean up the working directory; remove files named "solar_panel_angle*"
#
$check = `ls `;
if($check =~ /solar_panel_angle/){
	system("rm solar_panel_angle*0");
}

for($year = 2000; $year <= $this_year; $year++){
	$file1 = "$data_dir".'/Ind_data_files/angle'."$year".'.dat';
	$file2 = "$data_dir".'/Ind_data_files/solar_panel'."$year".'.dat';

	@time    = ();
	@time2   = ();
	@angle   = ();
	@tmysada = ();
	@tpysada = ();
	@tsamyt  = ();
	@tsapyt  = ();
	$cnt     = 0;
	$cnt2    = 0;

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

	open(FH, "$file2");		#----- solar panel temperature data
	OUTER:
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		if($atemp[1] !~ /\d/){
			next OUTER;
		}
		if($atemp[0] =~ /\d/){
			push(@time2,   $atemp[1]);
			push(@tmysada, $atemp[2]);
			push(@tpysada, $atemp[3]);
			push(@tsamyt,  $atemp[4]);
			push(@tsapyt,  $atemp[5]);
			$cnt2++;
		}else{
			push(@time2,   $atemp[2]);
			push(@tmysada, $atemp[3]);
			push(@tpysada, $atemp[4]);
			push(@tsamyt,  $atemp[5]);
			push(@tsapyt,  $atemp[6]);
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
	
		$out_file = './solar_panel_angle'."$angle1";
		open(OUT, ">>$out_file");
	
		$m = 0;
		OUTER2:
		for($k = 0; $k < $cnt2; $k++){
			if($tmysada[$k] !~ /\d/ || $tpysada[$k] !~ /\d/ || $tsamyt[$k] !~ /\d/ 
				|| $tsapyt[$k] !~ /\d/ || $angle[$k] !~ /\d/){
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

				print OUT "$year_time\t$tmysada[$k]\t$tpysada[$k]\t$tsamyt[$k]\t$tsapyt[$k]\t$angle[$m]\n";
			}
			$m++;
		}
		close(OUT);
	}
}

#
#--- replace old ones with the new one just complied
#

system("mv solar_panel_angle* $data_dir/Data_solar_panel/");


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
