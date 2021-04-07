#!/usr/bin/perl
  
# Perl script to generate David-Harris prefix adder
# Last update: 11/11/2007
   
use Getopt::Std;
use POSIX qw(ceil floor);
    
# options are
#       -x <bits> the number of n bits 
#       -m <string> module name
     
getopts('x:y:z:k:m:');

$XBITS=$opt_x;
$MODULE=$opt_m;

if($XBITS<=0){
    print("Input parameters:\n");
    print("    -x <bits> the number of x bits\n");
    print("    -m <string> module name (optional)\n");
    exit(1);
}

#if($ZBITS+$K>$XBITS+$YBITS) {    
#    print("Error: z+k must be smaller than or equal to x+y\n\n");
#    exit(1);
#}


# Write the header of the verilog file (variables definition)
# -----------------------------------------------------------
# print top modudel
printf("// David-Harris Prefix Adder\n\n");
if(length($MODULE)==0){
    printf("module add (cout, sum, a, b, cin);\n");
}
else{
    printf("module $MODULE (cout, sum, a, b, cin);\n");
}

printf("\t input [%s:0] a, b;\n",$XBITS-1);
printf("\t input cin;\n");
printf("\t output [%s:0] sum;\n",$XBITS-1);
printf("\t output cout;\n\n");

printf("\t wire [%s:0] p,g;\n",$XBITS);
printf("\t wire [%s:0] c;\n\n",$XBITS-1);

# pre-computation
printf("// pre-computation\n");
printf("\t assign p={a^b,1'b0};\n");
printf("\t assign g={a&b, cin};\n");

# prefix tree
printf("\n// prefix tree\n");
printf("\t david_harris prefix_tree(c, p[%s:0], g[%s:0]);\n\n",$XBITS-1,$XBITS-1);

# post-computation
printf("// post-computation\n");
printf("\t assign sum=p[%s:1]^c;\n",$XBITS);

printf("\t assign cout=g[%s]|(p[%s]&c[%s]);\n\n",$XBITS,$XBITS,$XBITS-1);

printf("endmodule\n\n");


printf("module david_harris (c, p, g);\n");
printf("\t\n");
printf("\tinput [%s:0] p;\n",$XBITS-1);
printf("\tinput [%s:0] g;\n",$XBITS-1);
printf("\toutput [%s:1] c;\n",$XBITS);
printf("\n\n");

# Generate the David-Harris parallel-prefix tree
# -----------------------------
$llevel=ceil(log($XBITS)/log(2));
print "\t// parallel-prefix, David-Harris\n";
for($x=0; $x<$llevel; $x++){
	$d=2**($x+1);
	$dh=2**$x;		# half d
	#$dd=2**($x+2);	# double d
	printf("\n\t// Stage %s: Generates G/P pairs that span %s bits\n",$x+1,2**($x));
	if($x==0){
		$i=1; # line counter
		for($y=0; $y<$XBITS ; $y+=2) {
			if ($y==0) {
				printf ("\tgrey g_%s_%s (G_%s_%s, {g[%s],g[%s]}, p[%s]);\n",$y+$d-1,$y,$y+$d-1,$y,
				$y+$d-1,$y,$y+$d-1);
			}
			else {
				printf ("\tblack b_%s_%s (G_%s_%s, P_%s_%s, {g[%s],g[%s]}, {p[%s],p[%s]});\n",$y+$d-1,$y,$y+$d-1,$y,
				$y+$d-1,$y,$y+$d-1,$y,$y+$d-1,$y);
			}
			if($i%8==0){
				print "\n";
			}
			$i++;
		}
	}
	elsif ($x==$llevel-1) { # last level
		$i=1; # line counter
		for($y=$dh+3; $y<$XBITS ; $y+=4) {
			printf ("\tgrey g_%s_0 (G_%s_0, {G_%s_%s,G_%s_0}, P_%s_%s);\n",
					$y-2,$y-2,
					$y-2,$y-$dh-1,$y-$dh,$y-2,$y-$dh-1);
			printf ("\tgrey g_%s_0 (G_%s_0, {G_%s_%s,G_%s_0}, P_%s_%s);\n",
					$y,$y,
					$y,$y-$dh+1,$y-$dh,$y,$y-$dh+1);
			if($i%8==0){
				print "\n";
			}
			$i++;
		}
	}
	else{
		$i=1; # line counter
		for($y=$dh+1; $y<$XBITS ; $y+=2) {
			if ($y<$d) { # bit < 4,8,.... generate grey cells. otherwise, create black cells
				printf ("\tgrey g_%s_0 (G_%s_0, {G_%s_%s,G_%s_0}, P_%s_%s);\n",
					$y,$y,
					$y,$y-$dh+1,$y-$dh,$y,$y-$dh+1);
			}
			else {
				printf ("\tblack b_%s_%s (G_%s_%s, P_%s_%s, {G_%s_%s,G_%s_%s}, {P_%s_%s,P_%s_%s});\n",
				$y,$y-$d+1,$y,$y-$d+1,$y,$y-$d+1,
				$y,$y-$dh+1,$y-$dh,$y-$d+1,$y,$y-$dh+1,$y-$dh,$y-$d+1);
			}
			if($i%8==0){
				print "\n";
			}
			$i++;
		}
	}
}

printf("\n\t// Extra grey cell stage \n");
for($y=2; $y<$XBITS ; $y+=2) {	# grey cell @ every 2-bit 
	$i=1; # line counter
	printf ("\tgrey g_%s_0 (G_%s_0, {g[%s],G_%s_0}, p[%s]);\n",
			$y,$y,$y,$y-1,$y);
	if($i%8==0){
				print "\n";
			}
	$i++;
}

printf("\n\t// Final Stage: Apply c_k+1=G_k_0\n");
printf ("\tassign c[1]=g[0];\n");
for($y=1; $y < $XBITS ; $y++) {
	
	printf ("\tassign c[%s]=G_%s_0;\n",$y+1,$y);
	
	if($y%8==0){
		print "\n";
	}
}

print "\nendmodule";
print "\n";

# print constant Black/Grey cells
printf("\n\n// Black cell");
printf("\nmodule black(gout, pout, gin, pin);");

printf("\n\n input [1:0] gin, pin;");
printf("\n output gout, pout;");

printf("\n\n assign pout=pin[1]&pin[0];");
printf("\n assign gout=gin[1]|(pin[1]&gin[0]);");

printf("\n\nendmodule");
printf("\n\n// Grey cell");
printf("\nmodule grey(gout, gin, pin);");

printf("\n\n input[1:0] gin;");
printf("\n input pin;");
printf("\n output gout;");

printf("\n\n assign gout=gin[1]|(pin&gin[0]);");

printf("\n\nendmodule\n");
