#!/usr/bin/perl

#########################################################################################
#											#
#	sep_col_scelec.perl: separate spacecraft power data into each element		#
#											#
#		author: t. isobe (tisobe@cfa.harvard.edu)				#
#											#
#		last update: Aug 27, 2012						#
#											#
#########################################################################################	

#
#---set directory
#

$dir_list = '/data/mta/Script/Sol_panel/house_keeping/dir_list';
open(FH, $dir_list);
while(<FH>){
    chomp $_;
    @atemp = split(/\s+/, $_);
    ${$atemp[0]} = $atemp[1];
}
close(FH);

if($data_dir eq ''){
        $data_dir = './';
}

@col_name = ('elbi', 'elbv', 'hrma', 'oba');
foreach $angle (40, 60, 80, 100, 120, 140, 160){
	$data = "$data_dir".'/Data_scelec/scelec_angle'."$angle";
	for($i = 1; $i < 5; $i++){
		$name = "$data_dir".'/Data_scelec/scelec_angle'."$angle".'_'."$col_name[$i -1]".'.dat';
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
