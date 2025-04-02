library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
library work;
   use work.pic_pkg.all;
   
entity tb_alu is
end tb_alu;

architecture testbench of tb_alu is

  component alu
    port (
          reset       : in std_logic; -- asynnchronous, active low
          clk         : in std_logic; -- sys clock, 20mhz, rising_edge
          command_alu : in alu_op; -- command instruction from cpu
          flagz       : out std_logic; -- zero flag
          flagc       : out std_logic; -- carry flag
          flagn       : out std_logic; -- nibble carry bit
          flage       : out std_logic; -- error flag
          index_reg   : out std_logic_vector(7 downto 0);   -- index register
          databus     : inout std_logic_vector(7 downto 0)); -- system data bus
  end component;
  
     signal clk      :     std_logic;
     signal reset    :     std_logic;
     signal flagz, flagc:     std_logic;
     signal index_reg  :     std_logic_vector(7 downto 0);
     signal databus  :  std_logic_vector(7 downto 0);
     signal command_alu:   alu_op;

begin

  uut: alu
    port map (
      clk     => clk,
      reset       => reset,
      databus => databus,
      flagz => flagz,
      flagc => flagc,
      index_reg => index_reg,
      command_alu => command_alu
      );


 
  -- clock generator
  p_clk : process
  begin
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  end process;

  -- reset & start generator
  p_reset : process
  begin
     reset <= '0', '1' after 40 ns;

     command_alu <= op_lda,     
           op_ldb after 100 ns,
           op_ldacc after 200 ns,    -- startbit
         op_ldid after 300 ns,   -- lsb
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
           op_xor after 1300 ns,  -- msb
            op_cmpe after 1400 ns,
            op_cmpl after 1500 ns,
         op_lda after 1600 ns,
          op_ascii2bin after 1700 ns,
            op_bin2ascii after 1800 ns,
           op_oeacc after 1900 ns;  -- msb      
                
         
                
        databus<= "10110101",
           "10100100" after 90 ns,
           "00111001" after 1599 ns,
            "zzzzzzzz" after 1800 ns;

 
           wait;
  end process;

end testbench;