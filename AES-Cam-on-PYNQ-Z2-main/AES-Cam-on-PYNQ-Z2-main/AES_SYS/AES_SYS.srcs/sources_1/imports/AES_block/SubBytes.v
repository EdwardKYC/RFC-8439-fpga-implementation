`include "./SubBytes_8bits.v"

module SubBytes(data_in,data_out);
input [127:0] data_in;
output [127:0] data_out;

SubBytes_8bits u_Sub_0(.data_in(data_in[127:120]),.data_out(data_out[127:120]));
SubBytes_8bits u_Sub_1(.data_in(data_in[119:112]),.data_out(data_out[119:112]));
SubBytes_8bits u_Sub_2(.data_in(data_in[111:104]),.data_out(data_out[111:104]));
SubBytes_8bits u_Sub_3(.data_in(data_in[103:96]),.data_out(data_out[103:96]));
SubBytes_8bits u_Sub_4(.data_in(data_in[95:88]),.data_out(data_out[95:88]));
SubBytes_8bits u_Sub_5(.data_in(data_in[87:80]),.data_out(data_out[87:80]));
SubBytes_8bits u_Sub_6(.data_in(data_in[79:72]),.data_out(data_out[79:72]));
SubBytes_8bits u_Sub_7(.data_in(data_in[71:64]),.data_out(data_out[71:64]));
SubBytes_8bits u_Sub_8(.data_in(data_in[63:56]),.data_out(data_out[63:56]));
SubBytes_8bits u_Sub_9(.data_in(data_in[55:48]),.data_out(data_out[55:48]));
SubBytes_8bits u_Sub_10(.data_in(data_in[47:40]),.data_out(data_out[47:40]));
SubBytes_8bits u_Sub_11(.data_in(data_in[39:32]),.data_out(data_out[39:32]));
SubBytes_8bits u_Sub_12(.data_in(data_in[31:24]),.data_out(data_out[31:24]));
SubBytes_8bits u_Sub_13(.data_in(data_in[23:16]),.data_out(data_out[23:16]));
SubBytes_8bits u_Sub_14(.data_in(data_in[15:8]),.data_out(data_out[15:8]));
SubBytes_8bits u_Sub_15(.data_in(data_in[7:0]),.data_out(data_out[7:0]));

endmodule
