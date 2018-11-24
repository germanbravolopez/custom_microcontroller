library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
LIBRARY work;
   USE work.PIC_pkg.all;
   
entity tb_ALU is
end tb_ALU;

architecture Testbench of tb_ALU is

  component Alu
    port (
          Reset       : in std_logic; -- asynnchronous, active low
          Clk         : in std_logic; -- Sys clock, 20MHz, rising_edge
          Command_alu : in alu_op; -- command instruction from CPU
          FlagZ       : out std_logic; -- Zero flag
          FlagC       : out std_logic; -- Carry flag
          FlagN       : out std_logic; -- Nibble carry bit
          FlagE       : out std_logic; -- Error flag
          Index_Reg   : out std_logic_vector(7 downto 0);   -- Index register
          Databus     : inout std_logic_vector(7 downto 0)); -- System Data bus
  end component;
  
     signal Clk      :     std_logic;
     signal Reset    :     std_logic;
     signal Flagz, FlagC:     std_logic;
     signal Index_Reg  :     std_logic_vector(7 downto 0);
     signal databus  :  std_logic_vector(7 downto 0);
     signal Command_alu:   alu_op;

begin

  UUT: ALU
    port map (
      clk     => clk,
      reset       => reset,
      databus => databus,
      FlagZ => FlagZ,
      FlagC => FlagC,
      Index_reg => Index_reg,
      command_alu => command_alu
      );


 
  -- Clock generator
  p_clk : PROCESS
  BEGIN
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;

  -- Reset & Start generator
  p_reset : PROCESS
  BEGIN
     reset <= '0', '1' after 40 ns;

     command_alu <= op_lda,     
           op_ldb after 100 ns,
           op_ldacc after 200 ns,    -- StartBit
         op_ldid after 300 ns,   -- LSb
          op_mvacc2id after 400 ns,           
           op_mvacc2a after 500 ns,
          op_mvacc2b after 600 ns,
           op_add after 700 ns,
          --op_sub after 800 ns,
          op_ldacc after 800 ns,
          op_shiftl after 900 ns,
           op_shiftr after 1000 ns,
          op_and after 1100 ns,
           op_or after 1200 ns,
           op_xor after 1300 ns,  -- MSb
            op_cmpe after 1400 ns,
            op_cmpl after 1500 ns,
         op_lda after 1600 ns,
          op_ascii2bin after 1700 ns,
            op_bin2ascii after 1800 ns,
           op_oeacc after 1900 ns;  -- MSb      
                
         
                
        Databus<= "10110101",
           "10100100" after 90 ns,
           "00111001" after 1599 ns,
            "ZZZZZZZZ" after 1800 ns;

 
           wait;
  END PROCESS;

end Testbench;