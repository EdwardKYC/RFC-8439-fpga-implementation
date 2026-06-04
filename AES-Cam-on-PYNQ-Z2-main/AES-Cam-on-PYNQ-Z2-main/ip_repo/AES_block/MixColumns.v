`include "./MixColumns_8bits.v"

module MixColumns(data_in,data_out);
input [127:0] data_in;
output [127:0] data_out;

//first column
MixColumns_8bits u_mix_0(data_in[127:120],data_in[119:112],data_in[111:104],data_in[103:96],data_out[127:120]);
MixColumns_8bits u_mix_1(data_in[119:112],data_in[111:104],data_in[103:96],data_in[127:120],data_out[119:112]);
MixColumns_8bits u_mix_2(data_in[111:104],data_in[103:96],data_in[127:120],data_in[119:112],data_out[111:104]);
MixColumns_8bits u_mix_3(data_in[103:96],data_in[127:120],data_in[119:112],data_in[111:104],data_out[103:96]);

//second column
MixColumns_8bits u_mix_4(data_in[95:88],data_in[87:80],data_in[79:72],data_in[71:64],data_out[95:88]);
MixColumns_8bits u_mix_5(data_in[87:80],data_in[79:72],data_in[71:64],data_in[95:88],data_out[87:80]);
MixColumns_8bits u_mix_6(data_in[79:72],data_in[71:64],data_in[95:88],data_in[87:80],data_out[79:72]);
MixColumns_8bits u_mix_7(data_in[71:64],data_in[95:88],data_in[87:80],data_in[79:72],data_out[71:64]);

//third column
MixColumns_8bits u_mix_8(data_in[63:56],data_in[55:48],data_in[47:40],data_in[39:32],data_out[63:56]);
MixColumns_8bits u_mix_9(data_in[55:48],data_in[47:40],data_in[39:32],data_in[63:56],data_out[55:48]);
MixColumns_8bits u_mix_10(data_in[47:40],data_in[39:32],data_in[63:56],data_in[55:48],data_out[47:40]);
MixColumns_8bits u_mix_11(data_in[39:32],data_in[63:56],data_in[55:48],data_in[47:40],data_out[39:32]);

//fourth column
MixColumns_8bits u_mix_12(data_in[31:24],data_in[23:16],data_in[15:8],data_in[7:0],data_out[31:24]);
MixColumns_8bits u_mix_13(data_in[23:16],data_in[15:8],data_in[7:0],data_in[31:24],data_out[23:16]);
MixColumns_8bits u_mix_14(data_in[15:8],data_in[7:0],data_in[31:24],data_in[23:16],data_out[15:8]);
MixColumns_8bits u_mix_15(data_in[7:0],data_in[31:24],data_in[23:16],data_in[15:8],data_out[7:0]);

endmodule

