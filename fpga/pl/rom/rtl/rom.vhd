library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;


entity rom is
  port (
    instruction     : out std_logic_vector(11 downto 0);  -- instruction bus
    program_counter : in  std_logic_vector(11 downto 0)); -- instruction address
end rom;

architecture automatic of rom is

constant w0  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w1  : std_logic_vector(11 downto 0) := x"003";
constant w2  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w3  : std_logic_vector(11 downto 0) := x"0ff";
constant w4  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpl;
constant w5  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w6  : std_logic_vector(11 downto 0) :=x"000";
constant w7  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_acc;
constant w8  : std_logic_vector(11 downto 0) := x"000";
constant w9  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w10  : std_logic_vector(11 downto 0) := x"003";
constant w11  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w12  : std_logic_vector(11 downto 0) := x"000";
constant w13  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b; -- comprobar si el comando es a
constant w14  : std_logic_vector(11 downto 0) := x"041";
constant w15  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w16  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w17  : std_logic_vector(11 downto 0) :=x"045";                                       -- saltar al 69
constant w18  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b; -- comprobar si el comando es i
constant w19  : std_logic_vector(11 downto 0) := x"049";
constant w20  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w21  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w22  : std_logic_vector(11 downto 0) :=x"02e";                                       -- saltar al 46
constant w23  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b; -- comprobar si el comando es t
constant w24  : std_logic_vector(11 downto 0) := x"054";
constant w25  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w26  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w27  : std_logic_vector(11 downto 0) :=x"05c";                                       -- saltar al 92
constant w28  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b; -- comprobar si el comando es s
constant w29  : std_logic_vector(11 downto 0) := x"053";
constant w30  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w31  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w32  : std_logic_vector(11 downto 0) :=x"07e";                                       -- saltar al 126
constant w33  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond; -- aqu� se ha comprobado que no es ning�n comd ant
constant w34  : std_logic_vector(11 downto 0) :=x"0d6";                     -- instrucci�n 214
constant w35  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_acc;
constant w36  : std_logic_vector(11 downto 0) := x"04f";
constant w37  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w38  : std_logic_vector(11 downto 0) := x"004";
constant w39  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_acc;
constant w40  : std_logic_vector(11 downto 0) := x"04b";
constant w41  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w42  : std_logic_vector(11 downto 0) := x"005";
constant w43  : std_logic_vector(11 downto 0) :=x"0" & type_4 & "000000";
constant w44  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w45  : std_logic_vector(11 downto 0) :=x"000";
constant w46  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w47  : std_logic_vector(11 downto 0) := x"001";
constant w48  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_ascii2bin;
constant w49  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_indx;
constant w50  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w51  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w52  : std_logic_vector(11 downto 0) := x"007";
constant w53  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpg;
constant w54  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w55  : std_logic_vector(11 downto 0) :=x"0d6";
constant w56  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w57  : std_logic_vector(11 downto 0) := x"002";
constant w58  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_ascii2bin;
constant w59  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w60  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w61  : std_logic_vector(11 downto 0) := x"001";
constant w62  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpg;
constant w63  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w64  : std_logic_vector(11 downto 0) :=x"0d6";
constant w65  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_indxd_mem;
constant w66  : std_logic_vector(11 downto 0) := x"010";
constant w67  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w68  : std_logic_vector(11 downto 0) :=x"023";                                        -- saltar al 35
constant w69  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w70  : std_logic_vector(11 downto 0) := x"001";
constant w71  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_ascii2bin;
constant w72  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w73  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_indx;
constant w74  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w75  : std_logic_vector(11 downto 0) := x"0ff";
constant w76  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w77  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w78  : std_logic_vector(11 downto 0) :=x"0d6";
constant w79  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w80  : std_logic_vector(11 downto 0) := x"002";
constant w81  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_ascii2bin;
constant w82  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w83  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w84  : std_logic_vector(11 downto 0) := x"009";
constant w85  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpg;
constant w86  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w87  : std_logic_vector(11 downto 0) :=x"0d6";
constant w88  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_indxd_mem;
constant w89  : std_logic_vector(11 downto 0) := x"020";
constant w90  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w91  : std_logic_vector(11 downto 0) :=x"023";
constant w92  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w93  : std_logic_vector(11 downto 0) := x"001";
constant w94  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_ascii2bin;
constant w95  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w96  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w97  : std_logic_vector(11 downto 0) := x"002";
constant w98  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpg;
constant w99  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w100  : std_logic_vector(11 downto 0) :=x"0d6";
constant w101  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w102  : std_logic_vector(11 downto 0) := x"000";
constant w103  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_add;
constant w104  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_shiftl;
constant w105  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_shiftl;
constant w106  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_shiftl;
constant w107  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_shiftl;
constant w108  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w109  : std_logic_vector(11 downto 0) := x"041";
constant w110  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w111  : std_logic_vector(11 downto 0) := x"002";
constant w112  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_ascii2bin;
constant w113  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w114  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w115  : std_logic_vector(11 downto 0) := x"0ff";
constant w116  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w117  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w118  : std_logic_vector(11 downto 0) :=x"0d6";
constant w119  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_b; -- esto no va bien en el post-sint
constant w120  : std_logic_vector(11 downto 0) := x"041";
constant w121  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_add;
constant w122  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w123  : std_logic_vector(11 downto 0) := x"031";
constant w124  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w125  : std_logic_vector(11 downto 0) :=x"023";
constant w126  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w127  : std_logic_vector(11 downto 0) := x"001";
constant w128  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w129  : std_logic_vector(11 downto 0) := x"041";
constant w130  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w131  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w132  : std_logic_vector(11 downto 0) :=x"091";
constant w133  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w134  : std_logic_vector(11 downto 0) := x"049";
constant w135  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w136  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w137  : std_logic_vector(11 downto 0) :=x"0a7";
constant w138  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w139  : std_logic_vector(11 downto 0) := x"054";
constant w140  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpe;
constant w141  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w142  : std_logic_vector(11 downto 0) :=x"0bd";
constant w143  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w144  : std_logic_vector(11 downto 0) :=x"0d6";
constant w145  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w146  : std_logic_vector(11 downto 0) := x"002";
constant w147  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_ascii2bin;
constant w148  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w149  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_indx;
constant w150  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w151  : std_logic_vector(11 downto 0) := x"009";
constant w152  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpg;
constant w153  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w154  : std_logic_vector(11 downto 0) :=x"0d6";
constant w155  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_indxd_mem & dst_a;
constant w156  : std_logic_vector(11 downto 0) := x"020";
constant w157  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_bin2ascii;
constant w158  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w159  : std_logic_vector(11 downto 0) := x"005";
constant w160  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_acc;
constant w161  : std_logic_vector(11 downto 0) := x"041";
constant w162  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w163  : std_logic_vector(11 downto 0) := x"004";
constant w164  : std_logic_vector(11 downto 0) :=x"0" & type_4 & "000000";
constant w165  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w166  : std_logic_vector(11 downto 0) :=x"000";
constant w167  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w168  : std_logic_vector(11 downto 0) := x"002";
constant w169  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_ascii2bin;
constant w170  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w171  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_indx;
constant w172  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w173  : std_logic_vector(11 downto 0) := x"007";
constant w174  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_cmpg;
constant w175  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_cond;
constant w176  : std_logic_vector(11 downto 0) :=x"0d6";
constant w177  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_indxd_mem & dst_a;
constant w178  : std_logic_vector(11 downto 0) := x"010";
constant w179  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_bin2ascii;
constant w180  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w181  : std_logic_vector(11 downto 0) := x"005";
constant w182  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_acc;
constant w183  : std_logic_vector(11 downto 0) := x"053";
constant w184  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w185  : std_logic_vector(11 downto 0) := x"004";
constant w186  : std_logic_vector(11 downto 0) :=x"0" & type_4 & "000000";
constant w187  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w188  : std_logic_vector(11 downto 0) :=x"000";
constant w189  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w190  : std_logic_vector(11 downto 0) := x"031";
constant w191  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w192  : std_logic_vector(11 downto 0) :="000011110000";
constant w193  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_and;
constant w194  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_shiftr;
constant w195  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_shiftr;
constant w196  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_shiftr;
constant w197  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_shiftr;
constant w198  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w199  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_bin2ascii;
constant w200  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w201  : std_logic_vector(11 downto 0) := x"004";
constant w202  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_mem & dst_a;
constant w203  : std_logic_vector(11 downto 0) := x"031";
constant w204  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_b;
constant w205  : std_logic_vector(11 downto 0) :="000000001111";
constant w206  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_and;
constant w207  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_acc & dst_a;
constant w208  : std_logic_vector(11 downto 0) :=x"0" & type_1 & alu_bin2ascii;
constant w209  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w210  : std_logic_vector(11 downto 0) := x"005";
constant w211  : std_logic_vector(11 downto 0) :=x"0" & type_4 & "000000";
constant w212  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w213  : std_logic_vector(11 downto 0) :=x"000";
constant w214  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_acc; -- mandar se�al de er por el tx
constant w215  : std_logic_vector(11 downto 0) := x"045";
constant w216  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w217  : std_logic_vector(11 downto 0) := x"004";
constant w218  : std_logic_vector(11 downto 0) :=x"0" & type_3 & ld & src_constant & dst_acc;
constant w219  : std_logic_vector(11 downto 0) := x"052";
constant w220  : std_logic_vector(11 downto 0) :=x"0" & type_3 & wr & src_acc & dst_mem;
constant w221  : std_logic_vector(11 downto 0) := x"005";
constant w222  : std_logic_vector(11 downto 0) :=x"0" & type_4 & "000000";                    -- hasta aqu�
constant w223  : std_logic_vector(11 downto 0) :=x"0" & type_2 & jmp_uncond;
constant w224  : std_logic_vector(11 downto 0) :=x"000";


begin  -- automatic

with program_counter select
    instruction <=
 w0 when x"000",
 w1 when x"001",
 w2 when x"002",
 w3 when x"003",
 w4 when x"004",
 w5 when x"005",
 w6 when x"006",
 w7 when x"007",
 w8 when x"008",
 w9 when x"009",
 w10 when x"00a",
 w11 when x"00b",
 w12 when x"00c",
 w13 when x"00d",
 w14 when x"00e",
 w15 when x"00f",
 w16 when x"010",
 w17 when x"011",
 w18 when x"012",
 w19 when x"013",
 w20 when x"014",
 w21 when x"015",
 w22 when x"016",
 w23 when x"017",
 w24 when x"018",
 w25 when x"019",
 w26 when x"01a",
 w27 when x"01b",
 w28 when x"01c",
 w29 when x"01d",
 w30 when x"01e",
 w31 when x"01f",
 w32 when x"020",
 w33 when x"021",
 w34 when x"022",
 w35 when x"023",
 w36 when x"024",
 w37 when x"025",
 w38 when x"026",
 w39 when x"027",
 w40 when x"028",
 w41 when x"029",
 w42 when x"02a",
 w43 when x"02b",
 w44 when x"02c",
 w45 when x"02d",
 w46 when x"02e",
 w47 when x"02f",
 w48 when x"030",
 w49 when x"031",
 w50 when x"032",
 w51 when x"033",
 w52 when x"034",
 w53 when x"035",
 w54 when x"036",
 w55 when x"037",
 w56 when x"038",
 w57 when x"039",
 w58 when x"03a",
 w59 when x"03b",
 w60 when x"03c",
 w61 when x"03d",
 w62 when x"03e",
 w63 when x"03f",
 w64 when x"040",
 w65 when x"041",
 w66 when x"042",
 w67 when x"043",
 w68 when x"044",
 w69 when x"045",
 w70 when x"046",
 w71 when x"047",
 w72 when x"048",
 w73 when x"049",
 w74 when x"04a",
 w75 when x"04b",
 w76 when x"04c",
 w77 when x"04d",
 w78 when x"04e",
 w79 when x"04f",
 w80 when x"050",
 w81 when x"051",
 w82 when x"052",
 w83 when x"053",
 w84 when x"054",
 w85 when x"055",
 w86 when x"056",
 w87 when x"057",
 w88 when x"058",
 w89 when x"059",
 w90 when x"05a",
 w91 when x"05b",
 w92 when x"05c",
 w93 when x"05d",
 w94 when x"05e",
 w95 when x"05f",
 w96 when x"060",
 w97 when x"061",
 w98 when x"062",
 w99 when x"063",
 w100 when x"064",
 w101 when x"065",
 w102 when x"066",
 w103 when x"067",
 w104 when x"068",
 w105 when x"069",
 w106 when x"06a",
 w107 when x"06b",
 w108 when x"06c",
 w109 when x"06d",
 w110 when x"06e",
 w111 when x"06f",
 w112 when x"070",
 w113 when x"071",
 w114 when x"072",
 w115 when x"073",
 w116 when x"074",
 w117 when x"075",
 w118 when x"076",
 w119 when x"077",
 w120 when x"078",
 w121 when x"079",
 w122 when x"07a",
 w123 when x"07b",
 w124 when x"07c",
 w125 when x"07d",
 w126 when x"07e",
 w127 when x"07f",
 w128 when x"080",
 w129 when x"081",
 w130 when x"082",
 w131 when x"083",
 w132 when x"084",
 w133 when x"085",
 w134 when x"086",
 w135 when x"087",
 w136 when x"088",
 w137 when x"089",
 w138 when x"08a",
 w139 when x"08b",
 w140 when x"08c",
 w141 when x"08d",
 w142 when x"08e",
 w143 when x"08f",
 w144 when x"090",
 w145 when x"091",
 w146 when x"092",
 w147 when x"093",
 w148 when x"094",
 w149 when x"095",
 w150 when x"096",
 w151 when x"097",
 w152 when x"098",
 w153 when x"099",
 w154 when x"09a",
 w155 when x"09b",
 w156 when x"09c",
 w157 when x"09d",
 w158 when x"09e",
 w159 when x"09f",
 w160 when x"0a0",
 w161 when x"0a1",
 w162 when x"0a2",
 w163 when x"0a3",
 w164 when x"0a4",
 w165 when x"0a5",
 w166 when x"0a6",
 w167 when x"0a7",
 w168 when x"0a8",
 w169 when x"0a9",
 w170 when x"0aa",
 w171 when x"0ab",
 w172 when x"0ac",
 w173 when x"0ad",
 w174 when x"0ae",
 w175 when x"0af",
 w176 when x"0b0",
 w177 when x"0b1",
 w178 when x"0b2",
 w179 when x"0b3",
 w180 when x"0b4",
 w181 when x"0b5",
 w182 when x"0b6",
 w183 when x"0b7",
 w184 when x"0b8",
 w185 when x"0b9",
 w186 when x"0ba",
 w187 when x"0bb",
 w188 when x"0bc",
 w189 when x"0bd",
 w190 when x"0be",
 w191 when x"0bf",
 w192 when x"0c0",
 w193 when x"0c1",
 w194 when x"0c2",
 w195 when x"0c3",
 w196 when x"0c4",
 w197 when x"0c5",
 w198 when x"0c6",
 w199 when x"0c7",
 w200 when x"0c8",
 w201 when x"0c9",
 w202 when x"0ca",
 w203 when x"0cb",
 w204 when x"0cc",
 w205 when x"0cd",
 w206 when x"0ce",
 w207 when x"0cf",
 w208 when x"0d0",
 w209 when x"0d1",
 w210 when x"0d2",
 w211 when x"0d3",
 w212 when x"0d4",
 w213 when x"0d5",
 w214 when x"0d6",
 w215 when x"0d7",
 w216 when x"0d8",
 w217 when x"0d9",
 w218 when x"0da",
 w219 when x"0db",
 w220 when x"0dc",
 w221 when x"0dd",
 w222 when x"0de",
 w223 when x"0df",
 w224 when x"0e0",
    x"0" & type_1 & alu_add when others;

end automatic;

