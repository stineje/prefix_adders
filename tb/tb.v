`define WIDTH 32

module tb();

    reg [`WIDTH-1:0] a,b;
    wire [`WIDTH-1:0] sum;
    reg cin;
    wire cout;

    reg clk, reset;

    reg [`WIDTH-1:0] golden_sum;
    reg golden_cout;

    integer file_open,file_scan,errors;

    adder dut(cout,sum,a,b,cin);

    initial begin
        clk=1'b0;
        errors=0;
        reset=0; #10; reset=1;
    end
    always #10 clk=~clk;

    initial begin
        $dumpfile("design.vcd");
        $dumpvars;
        $dumpon;
        file_open=$fopen("vectors.dat","r");
        if (file_open==0) begin
            $display("vectors.dat file not found"); $finish;
        end
    end

    always @(posedge clk) begin
        if (!$feof(file_open)) begin
            file_scan = $fscanf(file_open,"%d %d %d %d %d\n",a,b,cin,golden_sum,golden_cout);
        end else begin
            if (errors===0) begin
                $dumpoff;
                $dumpflush;
                $finish;
            end else begin
                $display("Number of errors:");
                $display(errors);
                $stop;
            end
        end
    end

    always @(negedge clk) begin
        if (reset==1) begin
            if (golden_sum!==sum || golden_cout!==cout) begin
                errors = errors+1;
                $display(a); $display(b); $display(errors);
            end
        end
    end

endmodule
