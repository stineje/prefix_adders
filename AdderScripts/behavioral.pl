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
printf("// Designware adder\n\n");
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

printf("\t assign {cout,sum}=a+b+cin;\n\n");

printf("endmodule");
