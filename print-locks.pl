#!/usr/bin/perl -w

if (!$ARGV[0]) {
	die "Missing source file. Exiting...\n";
}
$srcfile = $ARGV[0];


## known locks in the driver
@locks = qw(
	channel_lock
	io_mutex
	fifo_lock
	start_mutex
	nq_mutex
	ch_list_lock
	unlink
	list_lock
	lock
	mt
);
print "> Is the hard-coded list of synchronization locks still up-to-date?\n";
print "(";
foreach (@locks) {
	print "$_ ";
}
print ")\n";
print "> reading source file $srcfile\n";
print "> ---\n";
open(FILE, "$srcfile") or die "Cannot open file.\n";
while (defined($line = <FILE>)) {
	my $fname;
	my $locks_hold = 0;
	my $hold_indent;
	my $release_indent;
	my $indent;
	my $print_func = 1;
	## check if function body starts
	if ($line =~ m/^\w*( \w*)*\(.*[^;]\s$/) {
		##print $line;
		##capture function name in parentheses -> $1
		if ($line =~ m/(\b\w+)(?=\()/) {
			##print $1." {\n";
			$fname = $1;
		}
		while ($line !~ m/^}\s$/) {
			## while not end of function "}"
			$line = <FILE>;
			foreach(@locks) {
				##check if lock name appears isolated
				if ($line =~ m/[^\w]$_[^\w]/) {
					if ($line =~ m/(\s*)(spin|mutex)_unlock/) {
						$release_indent = $1;
						if (($release_indent eq $hold_indent) && ($locks_hold > 0)) {
							##decrement only if indention level matches
							$locks_hold--;
						}
						print $release_indent."release: <$_>\n";
					} elsif ($line =~ m/(\s*)((spin|mutex)_lock)(?!_init)/){
						if ($print_func) {
							##only print function if locking is used
							print $fname." {\n";
							$print_func = 0;
						}
						$hold_indent = $1;
						$locks_hold++;
						print $hold_indent."take: <$_>\n";
					}
				}
			}
			if ($locks_hold > 0) {
				##look for function calls while holding a lock
				if ($line =~ m/(^\s*).*\w*[^\s]\([->,&\*\w\s]*\)/) {
					$indent = $1;
					##don't print lock function itself
					if ($line !~ m/(spin_(un)?lock|mutex)/) {
						if ($line =~ m/(\b\w+)(?=\()/) {
							##capture function name w/ positive look-ahead
							print $indent."call: ".$1."\n";
						}
					}
				}
			}
		}
		if ($print_func == 0) {
			print "}\n";
			$print_func = 1;
		}
	}
}
close(FILE);
print "> end of script.\n";
=comment
print "Config settings are\n";
$i = 0;
foreach (@config_arr) {
	#print $config_arr;
	#$cref = $config_arr;
	#%conf_hash = %{$cref};
	print "channel_id = ".$config_arr[$i]{"channel_id"}."\n";
	print "direction = ".$config_arr[$i]{"direction"}."\n";
	print "datatype = ".$config_arr[$i++]{"datatype"}."\n";
}
=cut
