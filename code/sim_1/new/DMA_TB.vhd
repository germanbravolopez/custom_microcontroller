----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2018 17:14:16
-- Design Name: 
-- Module Name: DMA_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_DMA is
end tb_DMA;

architecture TestBench of tb_DMA is

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
    
  signal clk, reset : std_logic := '0';
  constant half_period100 : time := 5 ns;
  
  signal RX_Full, RX_Empty, ACK_out, TX_RDY, DMA_Ack, Send_comm: std_logic; -- in
  signal Data_read, Valid_D, Write_en, OE, DMA_RQ, READY: std_logic; -- out
  signal RCVD_Data, Databus, TX_Data, Address : std_logic_vector(7 downto 0);

begin
    
    clk <= not clk after half_period100;
    reset <= '1' after 0.1 ns;
    
      UUT: DMA
        port map (
            Reset => Reset,
            Clk => Clk,
            RCVD_Data => RCVD_Data,
            RX_Full => RX_Full,
            RX_Empty => RX_Empty,
            Data_Read => Data_Read,
            ACK_out => ACK_out,
            TX_RDY => TX_RDY,
            Valid_D => Valid_D,
            TX_Data => TX_Data,
            Address => Address,
            Databus => Databus,
            Write_en => Write_en,
            OE => OE,
            DMA_RQ => DMA_RQ,
            DMA_ACK => DMA_ACK,
            Send_comm => Send_comm,
            READY => READY);
    
    process
    begin 
        DMA_Ack <= '0';
        Address <= (others=>'Z');
        Databus <= (others=>'Z');
        RX_Empty <= '1';
        RCVD_Data <= (others => '0');
        
        RX_Empty <= '0' after 2us, '1' after 2.005us, '0' after 3.995us, '1' after 4.005us, '0' after 5.995us, '1' after 6.005us;
        DMA_Ack <= '1' after 2.015us, '0' after 2.050us, '1' after 4.010us, '0' after 4.050us, '1' after 6.010us, '0' after 6.050us;
        RCVD_Data <= "00110000" after 2.005us, "01000000" after 4.005us, "01010000" after 6.005us;

        ACK_Out <= '0';
        Send_comm <= '0'; 
        TX_RDY <= '1', '0' after 11.035us, '1' after 11.045us, '0' after 11.055us, '1' after 11.085us, '0' after 11.095us;
        Send_comm <= '1' after 10.995us, '0' after 11.105us;
        Databus <= "00100010" after 11.015us, (others=>'Z') after 11.035us, "01100110" after 11.055us, (others=>'Z') after 11.075us;
        ACK_out <= '1', '0' after 11.025us, '1' after 11.035us, '0' after 11.085us, '1' after 11.095us;
        wait;
    end process;

end TestBench;
