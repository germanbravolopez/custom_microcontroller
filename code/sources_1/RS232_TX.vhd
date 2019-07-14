----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.09.2018 19:03:28
-- Design Name: 
-- Module Name: RS232_TX - Behavioral
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

entity RS232_TX is
    Port ( Reset : in STD_LOGIC;
           Clk   : in STD_LOGIC;
           Start : in STD_LOGIC;
           Data  : in STD_LOGIC_VECTOR (7 downto 0);
           EOT   : out STD_LOGIC;
           TX    : out STD_LOGIC);
end RS232_TX;

architecture Behavioral of RS232_TX is

    type State is (Idle, StartBit, SendData, StopBit);
    
    signal CurrentState, NextState     : State;
    signal FlagBitWidth, FlagDataCount : std_logic;
    signal BitWidth                    : unsigned (7 downto 0);
    signal DataCount                   : unsigned(2 downto 0);
    constant PulseEndOfCount           : integer := 174;  -- 173,611 ciclos por bit 

begin

Next_process: process (CurrentState, Start, FlagBitWidth, FlagDataCount, Data) 
    begin
        case CurrentState is
            when Idle =>
                if (Start = '1') then
                    NextState <= StartBit;
                else
                    NextState <= Idle;
                end if;
            when StartBit =>
                if (FlagBitWidth = '1') then
                    NextState <= SendData;
                else
                    NextState <= StartBit;
                end if;
            when SendData =>
                if (FlagDataCount = '1') then
                    NextState <= StopBit;
                else
                    NextState <= SendData;
                end if;
            when StopBit =>
                if (FlagBitWidth = '1') then
                    NextState <= Idle;
                else
                    NextState <= StopBit;
                end if;
        end case;
    end process;

FFs: process (Reset, Clk) 
    begin
        if (Reset = '0') then
            CurrentState <= Idle;
        elsif (Clk'event and Clk = '1') then
            CurrentState <= NextState;
        end if;
    end process;

Outputs: process (CurrentState, DataCount, Data, FlagDataCount) 
    begin
        case CurrentState is
            when Idle =>
                EOT <= '1';
                TX  <= '1';
            when StartBit =>
                EOT <= '0';
                TX  <= '0';
            when SendData =>
                EOT <= '0';
                TX  <= Data(to_integer(DataCount));
                if (FlagDataCount = '1') then
                    TX <= Data(7);
                end if;
            when StopBit =>
                EOT <= '0';
                TX  <= '1';
        end case;
    end process;

BitWidth_counter: process (Clk, Reset, CurrentState) 
    begin
        if (Reset = '0' or CurrentState = Idle) then
            BitWidth <= (others => '0');
            FlagBitWidth <= '0';
        elsif (Clk'event and Clk='1') then
            BitWidth <= BitWidth + to_unsigned(1, 8);
            if (BitWidth = PulseEndOfCount) then
                BitWidth <= (others => '0');
                FlagBitWidth <= '1';
            else 
                FlagBitWidth <= '0';
            end if;
        end if;
    end process;
        
DataCounter: process (Clk, Reset, CurrentState, FlagBitWidth)
    begin
        if (Reset = '0' or CurrentState = StartBit) then
            DataCount <= (others => '0');
            FlagDataCount <= '0';
        elsif (Clk'event and Clk = '1') then
            if (CurrentState = SendData and FlagBitWidth = '1') then
                DataCount <= DataCount + to_unsigned(1,3);
                if (DataCount = 7) then
                    DataCount <= (others => '0');
                    FlagDataCount <= '1';
                else
                    FlagDataCount <= '0'; 
                end if;
            end if;
        end if;
    end process;

end Behavioral;