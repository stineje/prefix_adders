#!/usr/bin/perl
  
# Perl script to generate modulo 2^n-1 adder, nikolos scheme
# Last update: 04/23/2007
   
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
printf("// Sklansky Prefix Adder\n\n");
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
printf("\t wire [%s:1] h,c;\n\n",$XBITS);

# pre-computation
printf("// pre-computation\n");
printf("\t assign p={a|b,1'b1};\n");
printf("\t assign g={a&b, cin};\n");

# prefix tree
printf("\n// prefix tree\n");
printf("\t sklansky prefix_tree(h, c, p, g, sum, cout);\n\n",$XBITS-1,$XBITS-1);


printf("endmodule\n\n");


printf("module sklansky (h, c, p, g, sum, cout);\n");
printf("\t\n");
printf("\tinput [%s:0] p;\n",$XBITS);
printf("\tinput [%s:0] g;\n",$XBITS);
printf("\toutput [%s:1] h;\n",$XBITS);
printf("\toutput [%s:1] c;\n",$XBITS);
printf("\toutput [%s:0] sum;\n",$XBITS-1);
printf("\toutput cout;\n");
printf("\n\n");

# Generate the sklansky parallel-prefix tree
# -----------------------------
print "\t// parallel-prefix, Sklansky\n";
for($x=0; $x<ceil(log($XBITS)/log(2)); $x++){
	$d=2**($x+1);
	$dh=2**$x;
	printf("\t// Stage %s: Generates H/I pairs that span %s bits\n",$x+1,2**($x));
	if($x==0){
		$i=1; # line counter
		for($y=0; $y<$XBITS ; $y+=$d) {
			if ($y==0) {
				printf ("\trgry g_%s_0 (H_%s_0, {g[%s],g[%s]});\n",$y+$d-1,$y+$d-1,
				$y+$d-1,$y);
			}
			else {
				printf ("\trblk b_%s_%s (H_%s_%s, I_%s_%s, {g[%s],g[%s]}, {p[%s],p[%s]});\n",$y+$d-1,$y,$y+$d-1,$y,
				$y+$d-1,$y,$y+$d-1,$y,$y+$d-2,$y-1);
			}
			if($i%8==0){
				print "\n";
			}
			$i++;
			}
	}
	else{
		$i=1; # line counter
		for($y=0; $y<$XBITS ; $y+=$d) {
			for($z=$y+$dh; $z<$y+$d; $z++) {
				if ($z-$y-$dh+1==1) {
					if ($y==0) {
						printf ("\tgrey g_%s_%s (H_%s_%s, {g[%s],H_%s_%s}, p[%s]);\n",
						$z,$y,$z,$y,
						$z,$y+$dh-1,$y,$z-1);
					}
					else {
						printf ("\tblack b_%s_%s (H_%s_%s, I_%s_%s, {g[%s],H_%s_%s}, {p[%s],I_%s_%s});\n",
						$z,$y,$z,$y,$z,$y,
						$z,$y+$dh-1,$y,$z-1,$y+$dh-1,$y);
					}
				}
				else {
					if ($y==0) {
						printf ("\tgrey g_%s_%s (H_%s_%s, {H_%s_%s,H_%s_%s}, I_%s_%s);\n",
						$z,$y,$z,$y,
						$z,$y+$dh,$y+$dh-1,$y,$z,$y+$dh);
					}
					else {
						printf ("\tblack b_%s_%s (H_%s_%s, I_%s_%s, {H_%s_%s,H_%s_%s}, {I_%s_%s,I_%s_%s});\n",
						$z,$y,$z,$y,$z,$y,
						$z,$y+$dh,$y+$dh-1,$y,$z,$y+$dh,$y+$dh-1,$y);
					}
				}
				if($i%8==0){
				print "\n";
				}
				$i++;
			}
		}
	}
}

printf("\n\t// Final Stage: Apply c_k+1=p_k&H_k_0\n");
printf ("\tassign c[1]=g[0];\n\n");
for($y=1; $y < $XBITS ; $y++) {
	
    printf ("\tassign h[%s]=H_%s_0;\t",$y,$y);
	printf ("\tassign c[%s]=p[%s]&H_%s_0;\n",$y+1,$y,$y);
	
	if($y%8==0){
		print "\n";
	}
}
# post-computation
printf("// post-computation\n");
printf("\t assign h[%s]=g[%s]|c[%s];\n",$XBITS,$XBITS,$XBITS);
printf("\t assign sum=p[%s:1]^h|g[%s:1]&c;\n",$XBITS,$XBITS);

printf("\t assign cout=p[%s]&h[%s];\n\n",$XBITS,$XBITS);

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

# reduced Black/Grey cells
printf("\n\n// reduced Black cell");
printf("\nmodule rblk(hout, iout, gin, pin);");

printf("\n\n input [1:0] gin, pin;");
printf("\n output hout, iout;");

printf("\n\n assign iout=pin[1]&pin[0];");
printf("\n assign hout=gin[1]|gin[0];");

printf("\n\nendmodule");
printf("\n\n// reduced Grey cell");
printf("\nmodule rgry(hout, gin);");

printf("\n\n input[1:0] gin;");
printf("\n output hout;");

printf("\n\n assign hout=gin[1]|gin[0];");

printf("\n\nendmodule\n");
