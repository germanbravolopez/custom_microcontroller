----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.10.2018 14:13:43
-- Design Name: 
-- Module Name: RS232-DMA-RAM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.PIC_pkg.all;


entity RS232_DMA_RAM is
  Port ( 
    Reset     : in  std_logic; -- Asynchronous, active low
    Clk       : in  std_logic; -- System clock, 20 MHz, rising_edge
    RS232_RX  : in  std_logic; -- RS232 RX line
    RS232_TX  : out std_logic; -- RS232 TX line
    DMA_RQ    : out STD_LOGIC; -- Solicitud de los buses para recibir
    DMA_ACK   : in  STD_LOGIC; -- Aceptación para el DMA_RQ
    Send_comm : in  STD_LOGIC; -- Orden de envío
    READY     : out STD_LOGIC; -- Disponibilidad del DMA para enviar
    Switches  : out std_logic_vector(7 downto 0);
    Temp_L    : out std_logic_vector(6 downto 0);
    Temp_H    : out std_logic_vector(6 downto 0));
end RS232_DMA_RAM;

architecture Behavioral of RS232_DMA_RAM is

-- Components

  component DMA is
    Port ( 
        Reset : in STD_LOGIC;
        Clk : in STD_LOGIC;
        RCVD_Data : in STD_LOGIC_VECTOR (7 downto 0);
        RX_Full : in STD_LOGIC;
        RX_Empty : in STD_LOGIC;
        Data_Read : out STD_LOGIC;
        ACK_out : in STD_LOGIC;
        TX_RDY : in STD_LOGIC;
        Valid_D : out STD_LOGIC;
        TX_Data : out STD_LOGIC_VECTOR (7 downto 0);
        Address : out STD_LOGIC_VECTOR (7 downto 0);
        Databus : inout STD_LOGIC_VECTOR (7 downto 0);
        Write_en : out STD_LOGIC;
        OE : out STD_LOGIC;
        DMA_RQ : out STD_LOGIC;
        DMA_ACK : in STD_LOGIC;
        Send_comm : in STD_LOGIC;
        READY : out STD_LOGIC);
  end component;

  component RAM is
    port ( 
        Clk      : in    std_logic;
        Reset    : in    std_logic;
        write_en : in    std_logic;
        oe       : in    std_logic;
        address  : in    std_logic_vector(7 downto 0);
        databus  : inout std_logic_vector(7 downto 0);
        Switches : out   std_logic_vector(7 downto 0);
        Temp_L   : out   std_logic_vector(6 downto 0);
        Temp_H   : out   std_logic_vector(6 downto 0));
  end component;
    
  component RS232top is
    port (
        Reset     : in  std_logic;   -- Low_level-active asynchronous reset
        Clk       : in  std_logic;   -- System clock (20MHz), rising edge used
        Data_in   : in  std_logic_vector(7 downto 0);  -- Data to be sent
        Valid_D   : in  std_logic;   -- Handshake signal from guest system, low when data is valid
        Ack_in    : out std_logic;   -- ACK for data received, low once data has been stored
        TX_RDY    : out std_logic;   -- System ready to transmit
        TD        : out std_logic;   -- RS232 Transmission line
        RD        : in  std_logic;   -- RS232 Reception line
        Data_out  : out std_logic_vector(7 downto 0);  -- Received data
        Data_read : in  std_logic;   -- Data read for guest system
        Full      : out std_logic;   -- Full internal memory
        Empty     : out std_logic);  -- Empty internal memory
  end component;

-- Signals

  signal RX_Full, RX_Empty, ACK_out, TX_RDY : std_logic; -- in
  signal Data_read, Valid_D, Write_en, OE : std_logic; -- out
  signal RCVD_Data, Databus, TX_Data, Address : std_logic_vector(7 downto 0);
  
  signal Ack_in : std_logic;
  signal TD, RD, Full, Empty : std_logic;
  signal Data_out, Data_in : std_logic_vector(7 downto 0);

begin -- RTL

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
      
  RAM_inst : RAM
    port map (
      Clk      => Clk,
      Reset    => Reset,
      write_en => Write_en,
      oe       => OE,
      address  => Address,
      databus  => Databus,
      Switches => Switches,
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
      Write_en  => Write_en,
      OE        => OE,
      DMA_RQ    => DMA_RQ,
      READY     => READY);


end Behavioral;
