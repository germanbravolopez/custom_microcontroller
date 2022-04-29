library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;

entity pic_top is
    port (
        reset     : in  std_logic;           -- asynchronous, active low
        clk100mhz : in  std_logic;           -- system clock, 20 mhz, rising_edge
        rs232_rx  : in  std_logic;           -- rs232 rx line
        rs232_tx  : out std_logic;           -- rs232 tx line
        switches  : out std_logic_vector(7 downto 0);   -- switch status bargraph
        temp      : out std_logic_vector(7 downto 0);   -- display value for t_stat
--        cuentinst : out std_logic_vector(11 downto 0);
--        a_sal       : out std_logic_vector(7 downto 0);
--                   b_sal       : out std_logic_vector(7 downto 0);
--                   acc_sal         : out std_logic_vector(7 downto 0);
--                   ram_add     : out std_logic_vector(7 downto 0);
--                   chipset_sal: out std_logic;
        disp      : out std_logic_vector(7 downto 0));  -- display activation for t_stat
end pic_top;

architecture behavior of pic_top is

  ------------------------------------------------------------------------
  -- clk component for the conversion
  ------------------------------------------------------------------------

  component clk_converter
    port (
      clk_out1 : out    std_logic;
      reset    : in     std_logic;
      locked   : out    std_logic;
      clk_in1  : in     std_logic);
  end component;

  ------------------------------------------------------------------------
  -- rs232 component
  ------------------------------------------------------------------------

  component rs232top
    port (
      reset     : in  std_logic;
      clk       : in  std_logic;
      data_in   : in  std_logic_vector(7 downto 0);
      valid_d   : in  std_logic;
      ack_in    : out std_logic;
      tx_rdy    : out std_logic;
      td        : out std_logic;
      rd        : in  std_logic;
      data_out  : out std_logic_vector(7 downto 0);
      data_read : in  std_logic;
      full      : out std_logic;
      empty     : out std_logic);
  end component;
  
  ------------------------------------------------------------------------
  -- ram component
  ------------------------------------------------------------------------

  component ram
    port (
      clk      : in    std_logic;
      reset    : in    std_logic;
      we_dma   : in    std_logic;
      we_cpu   : in    std_logic;
      oe_cpu   : in    std_logic;
      oe_dma   : in    std_logic;
      ram_specific_sal: out array8_ram(0 to 63);
      ram_generic_sal : out array8_ram(64 to 255);
      address  : in    std_logic_vector(7 downto 0);
--      ram_add  : out std_logic_vector (7 downto 0);
--      chipset_sal : out std_logic;
      databus  : inout std_logic_vector(7 downto 0);
      switches : out   std_logic_vector(7 downto 0);
      temp_l   : out   std_logic_vector(6 downto 0);
      temp_h   : out   std_logic_vector(6 downto 0));
  end component;

  ------------------------------------------------------------------------
  -- dma component
  ------------------------------------------------------------------------

  component dma
    port ( 
      reset     : in std_logic;
      clk       : in std_logic;
      rcvd_data : in std_logic_vector (7 downto 0);
      rx_full   : in std_logic;
      rx_empty  : in std_logic;
      ack_out   : in std_logic;
      tx_rdy    : in std_logic;
      dma_ack   : in std_logic;
      send_comm : in std_logic;
      data_read : out std_logic;
      valid_d   : out std_logic;
      tx_data   : out std_logic_vector (7 downto 0);
      address   : out std_logic_vector (7 downto 0);
      databus   : inout std_logic_vector (7 downto 0);
      write_en  : out std_logic;
      oe_dma    : out std_logic;
      dma_rq    : out std_logic;
      ready     : out std_logic);
  end component;
  
  ------------------------------------------------------------------------
  -- alu component
  ------------------------------------------------------------------------
  
  component alu
    port ( 
      reset       : in std_logic;
      clk         : in std_logic;
      command_alu : in alu_op;
      databus     : inout std_logic_vector (7 downto 0);
      index_reg   : out std_logic_vector (7 downto 0);
      flagz       : out std_logic;
      flagc       : out std_logic;
      flagn       : out std_logic;
--      a_sal       : out std_logic_vector(7 downto 0);
--      b_sal       : out std_logic_vector(7 downto 0);
--      acc_sal     : out std_logic_vector(7 downto 0);
      flage       : out std_logic);
  end component;
  
  ------------------------------------------------------------------------
  -- rom component
  ------------------------------------------------------------------------

  component rom
    port (
      instruction     : out std_logic_vector(11 downto 0);  -- instruction bus
      program_counter : in  std_logic_vector(11 downto 0)); -- instruction address
  end component;

  ------------------------------------------------------------------------
  -- cpu component
  ------------------------------------------------------------------------
  
  component cpu
    port ( 
      reset     : in std_logic;
      clk       : in std_logic;
      rom_data  : in std_logic_vector (11 downto 0);
      rom_addr  : out std_logic_vector (11 downto 0);
      ram_addr  : out std_logic_vector (7 downto 0);
--      ram_cs    : out std_logic;
      ram_write : out std_logic;
      ram_oe    : out std_logic;
      databus   : inout std_logic_vector (7 downto 0);
      dma_rq    : in std_logic;
      dma_ack   : out std_logic;
      send_comm : out std_logic;
      dma_ready : in std_logic;
      alu_op    : out alu_op;
      index_reg : in std_logic_vector (7 downto 0);
      flagz     : in std_logic;
      flagc     : in std_logic;
--      cuentinst : out std_logic_vector(11 downto 0);
      flagn     : in std_logic;
      flage     : in std_logic);
  end component;
  
  ------------------------------------------------------------------------
  -- internal signals
  ------------------------------------------------------------------------
  -- common signals
  signal clk       : std_logic;
  signal sinit     : std_logic; 
  signal databus   : std_logic_vector(7 downto 0);
  signal address   : std_logic_vector(7 downto 0);
  
  -- tx
  signal tx_data   : std_logic_vector(7 downto 0);
  signal valid_d   : std_logic; 
  signal ack_out   : std_logic;
  signal tx_rdy    : std_logic;
  
  -- rx
  signal rcvd_data : std_logic_vector(7 downto 0);
  signal rx_full   : std_logic;
  signal rx_empty  : std_logic;
  signal data_read : std_logic;
  
  -- dma-ram
  signal oe_dma    : std_logic;
  signal oe_cpu    : std_logic;
  signal we_dma    : std_logic;
  signal we_cpu    : std_logic;
  
  -- dma-
  signal send_comm   : std_logic;
  signal dma_ack   : std_logic;
  signal ready   : std_logic;
  signal dma_rq   : std_logic;
  
  -- temp outputs
  signal temp_h    : std_logic_vector(6 downto 0);
  signal temp_l    : std_logic_vector(6 downto 0);
  
  -- alu
  signal alu_op    : alu_op;
  signal index_reg : std_logic_vector (7 downto 0);
  signal flagz     : std_logic;
  signal flagc     : std_logic;
  signal flagn     : std_logic;
  signal flage     : std_logic;
  
  -- rom
  signal ins_addr : std_logic_vector(11 downto 0);
  signal ins_bus  : std_logic_vector(11 downto 0);
  ------------------------------------------------------------------------
  signal ram_specific_sal: array8_ram(0 to 63);
  signal ram_generic_sal : array8_ram(64 to 255);
  signal counter_disp : integer range 0 to 2000 := 0;

begin  -- rtl

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


  rs232_phy: rs232top
    port map (
      reset     => reset,
      clk       => clk,
      data_in   => tx_data,
      valid_d   => valid_d,
      ack_in    => ack_out,
      tx_rdy    => tx_rdy,
      td        => rs232_tx,
      rd        => rs232_rx,
      data_out  => rcvd_data,
      data_read => data_read,
      full      => rx_full,
      empty     => rx_empty);
        
sinit <= not reset;

  clk_convert : clk_converter
    port map ( 
      clk_out1 => clk,
      reset    => sinit, --tiene reset activo en alto
      locked   => open,
      clk_in1  => clk100mhz);
      
  ram_inst : ram
    port map (
      clk      => clk,
      reset    => reset,
      we_cpu   => we_cpu,
      we_dma   => we_dma,
      oe_cpu   => oe_cpu,
      oe_dma   => oe_dma,
      address  => address,
--      ram_add  => ram_add,
--      chipset_sal => chipset_sal,
      databus  => databus,
      switches => switches,
      ram_specific_sal => ram_specific_sal,
      ram_generic_sal => ram_generic_sal,
      temp_l   => temp_l,
      temp_h   => temp_h);

  dma_inst : dma
    port map (
      reset     => reset,
      clk       => clk, 
      rcvd_data => rcvd_data,
      rx_full   => rx_full,
      rx_empty  => rx_empty,
      ack_out   => ack_out,
      tx_rdy    => tx_rdy,
      dma_ack   => dma_ack,
      send_comm => send_comm,
      data_read => data_read,
      valid_d   => valid_d,
      tx_data   => tx_data,
      address   => address,
      databus   => databus,
      write_en  => we_dma,
      oe_dma    => oe_dma,
      dma_rq    => dma_rq,
      ready     => ready);
      
  alu_inst : alu
    port map (
      reset       => reset,
      clk         => clk,
      command_alu => alu_op,
      databus     => databus,
      index_reg   => index_reg,
      flagz       => flagz,
      flagc       => flagc,
      flagn       => flagn,
--      acc_sal     => acc_sal,
--      b_sal       => b_sal,
--      a_sal       => a_sal,
      flage       => flage);
      
  rom_inst : rom
    port map (
      instruction     => ins_bus,
      program_counter => ins_addr);
  

  
  cpu_inst : cpu
    port map (
      reset     => reset,     
      clk       => clk,       
      rom_data  => ins_bus,  
      rom_addr  => ins_addr,
      ram_addr  => address, 
--      ram_cs    => open, 
      ram_write => we_cpu, 
      ram_oe    => oe_cpu,    
      databus   => databus,   
      dma_rq    => dma_rq,    
      dma_ack   => dma_ack,   
      send_comm => send_comm, 
      dma_ready => ready, 
      alu_op    => alu_op,    
      index_reg => index_reg, 
      flagz     => flagz,     
      flagc     => flagc,
--      cuentinst => cuentinst,     
      flagn     => flagn,     
      flage     => flage);       
  
end behavior;