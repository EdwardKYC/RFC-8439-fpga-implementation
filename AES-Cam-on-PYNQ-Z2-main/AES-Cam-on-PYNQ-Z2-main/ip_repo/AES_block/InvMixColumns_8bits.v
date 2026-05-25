module InvMixColumns_8bits(data_in1,data_in2,data_in3,data_in4,data_out);
input [7:0] data_in1,data_in2,data_in3,data_in4; //data_in1 : x14(e) data, data_in2 : x11(b) data, data_in3 : x13(d) data, data_in4 : x9 data
output [7:0] data_out;

assign data_out[7]=data_in1[4] ^ data_in1[5] ^ data_in1[6] ^ data_in2[4] ^ data_in2[6] ^ data_in2[7] ^ data_in3[4] ^ data_in3[5] ^ data_in3[7] ^ data_in4[4] ^ data_in4[7];
assign data_out[6]=data_in1[3] ^ data_in1[4] ^ data_in1[5] ^ data_in1[7] ^ data_in2[3] ^ data_in2[5] ^ data_in2[6] ^ data_in2[7] ^ data_in3[3] ^ data_in3[4] ^ data_in3[6] ^ data_in3[7] ^ data_in4[3] ^ data_in4[6] ^ data_in4[7];
assign data_out[5]=data_in1[2] ^ data_in1[3] ^ data_in1[4] ^ data_in1[6] ^ data_in2[2] ^ data_in2[4] ^ data_in2[5] ^ data_in2[6] ^ data_in2[7] ^ data_in3[2] ^ data_in3[3] ^ data_in3[5] ^ data_in3[6] ^ data_in4[2] ^ data_in4[5] ^ data_in4[6] ^ data_in4[7];
assign data_out[4]=data_in1[1] ^ data_in1[2] ^ data_in1[3] ^ data_in1[5] ^ data_in2[1] ^ data_in2[3] ^ data_in2[4] ^ data_in2[5] ^ data_in2[6] ^ data_in2[7] ^ data_in3[1] ^ data_in3[2] ^ data_in3[4] ^ data_in3[5] ^ data_in3[7] ^ data_in4[1] ^ data_in4[4] ^ data_in4[5] ^ data_in4[6];
assign data_out[3]=data_in1[0] ^ data_in1[1] ^ data_in1[2] ^ data_in1[5] ^ data_in1[6] ^ data_in2[0] ^ data_in2[2] ^ data_in2[3] ^ data_in2[5] ^ data_in3[0] ^ data_in3[1] ^ data_in3[3] ^ data_in3[5] ^ data_in3[6] ^ data_in3[7] ^ data_in4[0] ^ data_in4[3] ^ data_in4[5] ^ data_in4[7];
assign data_out[2]=data_in1[0] ^ data_in1[1] ^ data_in1[6] ^ data_in2[1] ^ data_in2[2] ^ data_in2[6] ^ data_in2[7] ^ data_in3[0] ^ data_in3[2] ^ data_in3[6] ^ data_in4[2] ^ data_in4[6] ^ data_in4[7];
assign data_out[1]=data_in1[0] ^ data_in1[5] ^ data_in2[0] ^ data_in2[1] ^ data_in2[5] ^ data_in2[6] ^ data_in2[7] ^ data_in3[1] ^ data_in3[5] ^ data_in3[7] ^ data_in4[1] ^ data_in4[5] ^ data_in4[6];
assign data_out[0]=data_in1[5] ^ data_in1[6] ^ data_in1[7] ^ data_in2[0] ^ data_in2[5] ^ data_in2[7] ^ data_in3[0] ^ data_in3[5] ^ data_in3[6] ^ data_in4[0] ^ data_in4[5];
	
endmodule