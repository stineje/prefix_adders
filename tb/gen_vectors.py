#!/usr/bin/python3

import argparse

argparser = argparse.ArgumentParser(description="Make vectors for testbenches")
argparser.add_argument("-width",type=int,default=32,help="width")
argparser.add_argument("-num_vectors",type=int,default=100,help="num of vectors")

args=argparser.parse_args()
max_val=2**args.width
step=int(max_val/(0.6*args.num_vectors**0.5))

for a in range(0,2**args.width,step):
    if a+step>max_val:
        a=max_val-1
    for b in range(0,2**args.width,step):
        if b+step>max_val:
            b=max_val-1
        for c in [0,1]:
            print(a,b,c,(a+b+c)%max_val,int(a+b+c>=max_val))

