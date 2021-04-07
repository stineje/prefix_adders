#!/usr/bin/perl
  
# Perl script to generate Brent-Kung Prefix Adder
# Last update: 11/09/2007
   
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
printf("// Ripple-carry adder\n\n");
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

printf("\t wire [%s:1] c;\n\n",$XBITS);

# prefix tree
printf("\n// prefix tree\n");
printf("\t ripple prefix_tree(a, b, cin, c, sum);\n\n");

# post-computation
printf("// post-computation\n");

printf("\t assign cout=c[%s];\n\n",$XBITS);

printf("endmodule\n\n");


printf("module ripple (a, b, cin, cout, sum);\n");
printf("\t\n");
printf("\tinput [%s:0] a;\n",$XBITS-1);
printf("\tinput [%s:0] b;\n",$XBITS-1);
printf("\tinput cin;\n");
printf("\toutput [%s:1] cout;\n",$XBITS);
printf("\toutput [%s:0] sum;\n",$XBITS-1);
printf("\n");
printf("\twire [%s:0] c;\n",$XBITS);
printf("\tassign c[0]=cin;\n\n");
printf("\tassign cout=c[%s:1];\n\n",$XBITS);

for($i=0; $i<$XBITS ; $i+=1) { 
	printf ("\tfa fa_%s (a[%s], b[%s], c[%s], sum[%s], c[%s]);\n",
			$i,$i,$i,$i,$i,$i+1);
}

print "\nendmodule";
print "\n";

# print constant Black/Grey cells
printf("\n\n// fa");
printf("\nmodule fa(a, b, c, sum, cout);");

printf("\n\n input a, b, c;");
printf("\n output sum, cout;");

printf("\n assign {cout,sum}=a+b+c;");

printf("\n\nendmodule");
