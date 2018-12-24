
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

entity PICtop is
    port (
        Reset     : in  std_logic;           -- Asynchronous, active low
        CLK100MHZ : in  std_logic;           -- System clock, 20 MHz, rising_edge
        RS232_RX  : in  std_logic;           -- RS232 RX line
        RS232_TX  : out std_logic;           -- RS232 TX line
        Switches  : out std_logic_vector(7 downto 0);   -- Switch status bargraph
        Temp      : out std_logic_vector(7 downto 0);   -- Display value for T_STAT
--        CuentInst : out std_logic_vector(11 downto 0);
--        A_sal       : out std_logic_vector(7 downto 0);
--                   B_sal       : out std_logic_vector(7 downto 0);
--                   ACC_sal         : out std_logic_vector(7 downto 0);
--                   RAM_Add     : out std_logic_vector(7 downto 0);
--                   chipset_sal: out std_logic;
        Disp      : out std_logic_vector(7 downto 0));  -- Display activation for T_STAT
end PICtop;

architecture behavior of PICtop is

  ------------------------------------------------------------------------
  -- Clk Component for the conversion
  ------------------------------------------------------------------------

  component clk_converter
    port (
      clk_out1 : out    std_logic;
      reset    : in     std_logic;
      locked   : out    std_logic;
      clk_in1  : in     std_logic);
  end component;

  ------------------------------------------------------------------------
  -- RS232 Component
  ------------------------------------------------------------------------

  component RS232top
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;
  
  ------------------------------------------------------------------------
  -- RAM Component
  ------------------------------------------------------------------------

  component RAM
    PORT (
      Clk      : in    std_logic;
      Reset    : in    std_logic;
      we_dma   : in    std_logic;
      we_cpu   : in    std_logic;
      oe_cpu   : in    std_logic;
      oe_dma   : in    std_logic;
      ram_specific_sal: out array8_ram(0 to 63);
      ram_generic_sal : out array8_ram(64 to 255);
      address  : in    std_logic_vector(7 downto 0);
--      RAM_Add  : out std_logic_vector (7 downto 0);
--      chipset_sal : out std_logic;
      databus  : inout std_logic_vector(7 downto 0);
      Switches : out   std_logic_vector(7 downto 0);
      Temp_L   : out   std_logic_vector(6 downto 0);
      Temp_H   : out   std_logic_vector(6 downto 0));
  end component;

  ------------------------------------------------------------------------
  -- DMA Component
  ------------------------------------------------------------------------

  component DMA
    Port ( 
      Reset     : in STD_LOGIC;
      Clk       : in STD_LOGIC;
      RCVD_Data : in STD_LOGIC_VECTOR (7 downto 0);
      RX_Full   : in STD_LOGIC;
      RX_Empty  : in STD_LOGIC;
      ACK_out   : in STD_LOGIC;
      TX_RDY    : in STD_LOGIC;
      DMA_ACK   : in STD_LOGIC;
      Send_comm : in STD_LOGIC;
      Data_read : out STD_LOGIC;
      Valid_D   : out STD_LOGIC;
      TX_Data   : out STD_LOGIC_VECTOR (7 downto 0);
      Address   : out STD_LOGIC_VECTOR (7 downto 0);
      Databus   : inout STD_LOGIC_VECTOR (7 downto 0);
      Write_en  : out STD_LOGIC;
      OE_DMA    : out STD_LOGIC;
      DMA_RQ    : out STD_LOGIC;
      READY     : out STD_LOGIC);
  end component;
  
  ------------------------------------------------------------------------
  -- ALU Component
  ------------------------------------------------------------------------
  
  component ALU
    Port ( 
      Reset       : in STD_LOGIC;
      Clk         : in STD_LOGIC;
      Command_alu : in alu_op;
      Databus     : inout STD_LOGIC_VECTOR (7 downto 0);
      Index_Reg   : out STD_LOGIC_VECTOR (7 downto 0);
      FlagZ       : out STD_LOGIC;
      FlagC       : out STD_LOGIC;
      FlagN       : out STD_LOGIC;
--      A_sal       : out std_logic_vector(7 downto 0);
--      B_sal       : out std_logic_vector(7 downto 0);
--      ACC_sal     : out std_logic_vector(7 downto 0);
      FlagE       : out STD_LOGIC);
  end component;
  
  ------------------------------------------------------------------------
  -- ROM Component
  ------------------------------------------------------------------------

  component ROM
    port (
      Instruction     : out std_logic_vector(11 downto 0);  -- Instruction bus
      Program_counter : in  std_logic_vector(11 downto 0)); -- Instruction address
  end component;

  ------------------------------------------------------------------------
  -- MAIN_CONTROL Component
  ------------------------------------------------------------------------
  
  component MAIN_CONTROL
    Port ( 
      Reset     : in STD_LOGIC;
      Clk       : in STD_LOGIC;
      ROM_Data  : in STD_LOGIC_VECTOR (11 downto 0);
      ROM_Addr  : out STD_LOGIC_VECTOR (11 downto 0);
      RAM_Addr  : out STD_LOGIC_VECTOR (7 downto 0);
--      RAM_CS    : out STD_LOGIC;
      RAM_Write : out STD_LOGIC;
      RAM_OE    : out STD_LOGIC;
      Databus   : inout STD_LOGIC_VECTOR (7 downto 0);
      DMA_RQ    : in STD_LOGIC;
      DMA_ACK   : out STD_LOGIC;
      SEND_comm : out STD_LOGIC;
      DMA_READY : in STD_LOGIC;
      ALU_op    : out alu_op;
      Index_Reg : in STD_LOGIC_VECTOR (7 downto 0);
      FlagZ     : in STD_LOGIC;
      FlagC     : in STD_LOGIC;
--      CuentInst : out std_logic_vector(11 downto 0);
      FlagN     : in STD_LOGIC;
      FlagE     : in STD_LOGIC);
  end component;
  
  ------------------------------------------------------------------------
  -- Internal Signals
  ------------------------------------------------------------------------
  -- Common signals
  signal Clk       : std_logic;
  signal sinit     : std_logic; 
  signal Databus   : std_logic_vector(7 downto 0);
  signal Address   : std_logic_vector(7 downto 0);
  
  -- TX
  signal TX_Data   : std_logic_vector(7 downto 0);
  signal Valid_D   : std_logic; 
  signal Ack_out   : std_logic;
  signal TX_RDY    : std_logic;
  
  -- RX
  signal RCVD_Data : std_logic_vector(7 downto 0);
  signal RX_Full   : std_logic;
  signal RX_Empty  : std_logic;
  signal Data_read : std_logic;
  
  -- DMA-RAM
  signal OE_DMA    : std_logic;
  signal OE_CPU    : std_logic;
  signal WE_DMA    : std_logic;
  signal WE_CPU    : std_logic;
  
  -- DMA-
  signal Send_comm   : std_logic;
  signal DMA_ACK   : std_logic;
  signal READY   : std_logic;
  signal DMA_RQ   : std_logic;
  
  -- Temp outputs
  signal Temp_H    : std_logic_vector(6 downto 0);
  signal Temp_L    : std_logic_vector(6 downto 0);
  
  -- ALU
  signal Alu_op    : alu_op;
  signal Index_Reg : std_logic_vector (7 downto 0);
  signal FlagZ     : std_logic;
  signal FlagC     : std_logic;
  signal FlagN     : std_logic;
  signal FlagE     : std_logic;
  
  -- ROM
  signal INS_addr : std_logic_vector(11 downto 0);
  signal INS_bus  : std_logic_vector(11 downto 0);
  ------------------------------------------------------------------------
  signal ram_specific_sal: array8_ram(0 to 63);
  signal ram_generic_sal : array8_ram(64 to 255);
  signal counter_disp : integer range 0 to 2000 := 0;

begin  -- RTL

temp_display: process (counter_disp, temp_l, temp_h, reset, clk) -- cada 1 ms se muestra por cada display el valor de su temperatura
    begin
        if (reset = '0') then
            temp <= '1' & temp_l;
            disp <= "11111110";
            counter_disp <= 0;
        elsif (clk'event and clk = '1') then
            if (counter_disp = 1000) then
                temp <= '1' & temp_h;
                disp <= "11111101";
                counter_disp <= counter_disp + 1;
            elsif (counter_disp = 2000) then
                temp <= '1' & temp_l;
                disp <= "11111110";
                counter_disp <= 0;
            else
                counter_disp <= counter_disp + 1;
            end if;
        end if;
    end process;


  RS232_PHY: RS232top
    port map (
      Reset     => Reset,
      Clk       => Clk,
      Data_in   => TX_Data,
      Valid_D   => Valid_D,
      Ack_in    => Ack_out,
      TX_RDY    => TX_RDY,
      TD        => RS232_TX,
      RD        => RS232_RX,
      Data_out  => RCVD_Data,
      Data_read => Data_read,
      Full      => RX_Full,
      Empty     => RX_Empty);
        
sinit <= not reset;

  Clk_convert : clk_converter
    port map ( 
      clk_out1 => Clk,
      reset    => sinit, --tiene reset activo en alto
      locked   => OPEN,
      clk_in1  => CLK100MHZ);
      
  RAM_inst : RAM
    port map (
      Clk      => Clk,
      Reset    => Reset,
      we_cpu   => we_cpu,
      we_dma   => we_dma,
      oe_cpu   => OE_CPU,
      oe_dma   => OE_DMA,
      address  => Address,
--      RAM_Add  => RAM_Add,
--      chipset_sal => chipset_sal,
      databus  => Databus,
      Switches => Switches,
      ram_specific_sal => ram_specific_sal,
      ram_generic_sal => ram_generic_sal,
      Temp_L   => Temp_L,
      Temp_H   => Temp_H);

  DMA_inst : DMA
    port map (
      Reset     => Reset,
      Clk       => Clk, 
      RCVD_Data => RCVD_Data,
      RX_Full   => RX_Full,
      RX_Empty  => RX_Empty,
      ACK_out   => ACK_out,
      TX_RDY    => TX_RDY,
      DMA_ACK   => DMA_ACK,
      Send_comm => Send_comm,
      Data_read => Data_read,
      Valid_D   => Valid_D,
      TX_Data   => TX_Data,
      Address   => Address,
      Databus   => Databus,
      Write_en  => WE_DMA,
      OE_DMA    => OE_DMA,
      DMA_RQ    => DMA_RQ,
      READY     => READY);
      
  ALU_inst : ALU
    port map (
      Reset       => Reset,
      Clk         => Clk,
      Command_alu => Alu_op,
      Databus     => Databus,
      Index_Reg   => Index_Reg,
      FlagZ       => FlagZ,
      FlagC       => FlagC,
      FlagN       => FlagN,
--      ACC_sal     => ACC_sal,
--      B_sal       => B_sal,
--      A_sal       => A_sal,
      FlagE       => FlagE);
      
  ROM_inst : ROM
    port map (
      Instruction     => INS_bus,
      Program_counter => INS_addr);
  

  
  MAIN : MAIN_CONTROL
    port map (
      Reset     => Reset,     
      Clk       => Clk,       
      ROM_Data  => INS_bus,  
      ROM_Addr  => INS_addr,
      RAM_Addr  => Address, 
--      RAM_CS    => OPEN, 
      RAM_Write => WE_CPU, 
      RAM_OE    => OE_CPU,    
      Databus   => Databus,   
      DMA_RQ    => DMA_RQ,    
      DMA_ACK   => DMA_ACK,   
      SEND_comm => SEND_comm, 
      DMA_READY => READY, 
      ALU_op    => Alu_op,    
      Index_Reg => Index_Reg, 
      FlagZ     => FlagZ,     
      FlagC     => FlagC,
--      CuentInst => CuentInst,     
      FlagN     => FlagN,     
      FlagE     => FlagE);       
  
end behavior;