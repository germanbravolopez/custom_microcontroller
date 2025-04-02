library ieee;
use ieee.std_logic_1164.all;

package pic_pkg is

-------------------------------------------------------------------------------
-- types for the ram memory
-------------------------------------------------------------------------------

  subtype item_array8_ram is std_logic_vector (7 downto 0);
  type array8_ram is array (integer range <>) of item_array8_ram;

-------------------------------------------------------------------------------
-- useful constants for addressing purposes
-------------------------------------------------------------------------------

  constant dma_rx_buffer_msb : std_logic_vector(7 downto 0) := x"00";
  constant dma_rx_buffer_mid : std_logic_vector(7 downto 0) := x"01";
  constant dma_rx_buffer_lsb : std_logic_vector(7 downto 0) := x"02";
  constant new_inst          : std_logic_vector(7 downto 0) := x"03";
  constant dma_tx_buffer_msb : std_logic_vector(7 downto 0) := x"04";
  constant dma_tx_buffer_lsb : std_logic_vector(7 downto 0) := x"05";
  constant switch_base       : std_logic_vector(7 downto 0) := x"10";
  constant lever_base        : std_logic_vector(7 downto 0) := x"20";
  constant cal_op            : std_logic_vector(7 downto 0) := x"30";
  constant t_stat            : std_logic_vector(7 downto 0) := x"31";
  constant gp_ram_base       : std_logic_vector(7 downto 0) := x"40";

-------------------------------------------------------------------------------
-- constants to define type 1 instructions (alu)
-------------------------------------------------------------------------------

  constant type_1        : std_logic_vector(1 downto 0) := "00";
  constant alu_add       : std_logic_vector(5 downto 0) := "000000";
  constant alu_sub       : std_logic_vector(5 downto 0) := "000001";
  constant alu_shiftl    : std_logic_vector(5 downto 0) := "000010";
  constant alu_shiftr    : std_logic_vector(5 downto 0) := "000011";
  constant alu_and       : std_logic_vector(5 downto 0) := "000100";
  constant alu_or        : std_logic_vector(5 downto 0) := "000101";
  constant alu_xor       : std_logic_vector(5 downto 0) := "000110";
  constant alu_cmpe      : std_logic_vector(5 downto 0) := "000111";
  constant alu_cmpg      : std_logic_vector(5 downto 0) := "001000";
  constant alu_cmpl      : std_logic_vector(5 downto 0) := "001001";
  constant alu_ascii2bin : std_logic_vector(5 downto 0) := "001010";
  constant alu_bin2ascii : std_logic_vector(5 downto 0) := "001011";

-------------------------------------------------------------------------------
-- constants to define type 2 instructions (jump)
-------------------------------------------------------------------------------

  constant type_2     : std_logic_vector(1 downto 0) := "01";
  constant jmp_uncond : std_logic_vector(5 downto 0) := "00" & x"0";
  constant jmp_cond   : std_logic_vector(5 downto 0) := "00" & x"1";

-------------------------------------------------------------------------------
-- constants to define type 3 instructions (load & store)
-------------------------------------------------------------------------------

  constant type_3        : std_logic_vector(1 downto 0) := "10";
  -- instruction
  constant ld            : std_logic                    := '0';
  constant wr            : std_logic                    := '1';
  -- source
  constant src_acc       : std_logic_vector(1 downto 0) := "00";
  constant src_constant  : std_logic_vector(1 downto 0) := "01";
  constant src_mem       : std_logic_vector(1 downto 0) := "10";
  constant src_indxd_mem : std_logic_vector(1 downto 0) := "11";
  -- destination
  constant dst_acc       : std_logic_vector(2 downto 0) := "000";
  constant dst_a         : std_logic_vector(2 downto 0) := "001";
  constant dst_b         : std_logic_vector(2 downto 0) := "010";
  constant dst_indx      : std_logic_vector(2 downto 0) := "011";
  constant dst_mem       : std_logic_vector(2 downto 0) := "100";
  constant dst_indxd_mem : std_logic_vector(2 downto 0) := "101";

-------------------------------------------------------------------------------
-- constants to define type 4 instructions (send)
-------------------------------------------------------------------------------

  constant type_4        : std_logic_vector(1 downto 0) := "11";

-------------------------------------------------------------------------------
-- type containing the alu instruction set
-------------------------------------------------------------------------------

    type alu_op is (
      nop,                                  -- no operation
      op_lda, op_ldb, op_ldacc, op_ldid,    -- external value load
      op_mvacc2id, op_mvacc2a, op_mvacc2b,  -- internal load
      op_add, op_sub, op_shiftl, op_shiftr, -- arithmetic operations
      op_and, op_or, op_xor,                -- logic operations
      op_cmpe, op_cmpl, op_cmpg,            -- compare operations
      op_ascii2bin, op_bin2ascii,           -- conversion operations
      op_oeacc);                            -- output enable

end pic_pkg;

package body pic_pkg is
end pic_pkg;