`include "./InvSubBytes_8bits.v"

module InvSubBytes(data_in,data_out);
input [127:0] data_in;
output [127:0] data_out;

InvSubBytes_8bits u_InvSub_0(.data_in(data_in[127:120]),.data_out(data_out[127:120]));
InvSubBytes_8bits u_InvSub_1(.data_in(data_in[119:112]),.data_out(data_out[119:112]));
InvSubBytes_8bits u_InvSub_2(.data_in(data_in[111:104]),.data_out(data_out[111:104]));
InvSubBytes_8bits u_InvSub_3(.data_in(data_in[103:96]),.data_out(data_out[103:96]));
InvSubBytes_8bits u_InvSub_4(.data_in(data_in[95:88]),.data_out(data_out[95:88]));
InvSubBytes_8bits u_InvSub_5(.data_in(data_in[87:80]),.data_out(data_out[87:80]));
InvSubBytes_8bits u_InvSub_6(.data_in(data_in[79:72]),.data_out(data_out[79:72]));
InvSubBytes_8bits u_InvSub_7(.data_in(data_in[71:64]),.data_out(data_out[71:64]));
InvSubBytes_8bits u_InvSub_8(.data_in(data_in[63:56]),.data_out(data_out[63:56]));
InvSubBytes_8bits u_InvSub_9(.data_in(data_in[55:48]),.data_out(data_out[55:48]));
InvSubBytes_8bits u_InvSub_10(.data_in(data_in[47:40]),.data_out(data_out[47:40]));
InvSubBytes_8bits u_InvSub_11(.data_in(data_in[39:32]),.data_out(data_out[39:32]));
InvSubBytes_8bits u_InvSub_12(.data_in(data_in[31:24]),.data_out(data_out[31:24]));
InvSubBytes_8bits u_InvSub_13(.data_in(data_in[23:16]),.data_out(data_out[23:16]));
InvSubBytes_8bits u_InvSub_14(.data_in(data_in[15:8]),.data_out(data_out[15:8]));
InvSubBytes_8bits u_InvSub_15(.data_in(data_in[7:0]),.data_out(data_out[7:0]));

endmodule
