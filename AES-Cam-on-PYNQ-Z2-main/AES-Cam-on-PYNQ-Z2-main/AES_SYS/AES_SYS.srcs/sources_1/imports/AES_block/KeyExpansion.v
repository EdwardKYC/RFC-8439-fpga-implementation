module KeyExpansion(key_in,round_constant,key_out);
input [127:0] key_in;
input [31:0] round_constant;
output [127:0] key_out;

//Rotword
wire [7:0] Rotword_out0;
wire [7:0] Rotword_out1;
wire [7:0] Rotword_out2;
wire [7:0] Rotword_out3;

assign Rotword_out0=key_in[23:16];
assign Rotword_out1=key_in[15:8];
assign Rotword_out2=key_in[7:0];
assign Rotword_out3=key_in[31:24];

//Subword
wire [7:0] Subword_out0;
wire [7:0] Subword_out1;
wire [7:0] Subword_out2;
wire [7:0] Subword_out3;

SubBytes_8bits u_subword_0(.data_in(Rotword_out0),.data_out(Subword_out0));
SubBytes_8bits u_subword_1(.data_in(Rotword_out1),.data_out(Subword_out1));
SubBytes_8bits u_subword_2(.data_in(Rotword_out2),.data_out(Subword_out2));
SubBytes_8bits u_subword_3(.data_in(Rotword_out3),.data_out(Subword_out3));

//xor round constant
wire [31:0] rcon_out;

assign rcon_out={Subword_out0,Subword_out1,Subword_out2,Subword_out3}^round_constant;

//key output
assign key_out[127:96]=rcon_out^key_in[127:96];
assign key_out[95:64]=key_out[127:96]^key_in[95:64];
assign key_out[63:32]=key_out[95:64]^key_in[63:32];
assign key_out[31:0]=key_out[63:32]^key_in[31:0];

endmodule
