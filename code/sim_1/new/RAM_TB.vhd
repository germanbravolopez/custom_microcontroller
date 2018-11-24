----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.10.2018 17:48:00
-- Design Name: 
-- Module Name: RAM_TB - Testbench
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

USE work.PIC_pkg.all;

entity tb_RAM is
--  Port ( );
end tb_RAM;

architecture Testbench of tb_RAM is
    component RAM
        PORT (
       Clk      : in    std_logic;
       Reset    : in    std_logic;
       write_en : in    std_logic;
       oe       : in    std_logic;
       address  : in    std_logic_vector(7 downto 0);
       databus  : inout std_logic_vector(7 downto 0);
       Switches : out   std_logic_vector(7 downto 0);
       Temp_L   : out   std_logic_vector(6 downto 0);
       Temp_H   : out   std_logic_vector(6 downto 0));
    END component;
    
    signal Clk, Reset, write_en, oe : std_logic;
    signal address : std_logic_vector(7 downto 0);
    signal databus, Switches : std_logic_vector(7 downto 0);
    signal Temp_L, Temp_H : std_logic_vector(6 downto 0); 
    
begin

    uut: RAM
        port map(
        Clk       =>  Clk,        
        Reset     =>  Reset,   
        write_en  =>  write_en,
        oe        =>  oe,      
        address   =>  address, 
        databus   =>  databus, 
        Switches  =>  Switches,
        Temp_L    =>  Temp_L,  
        Temp_H    =>  Temp_H);

    p_clk: process
        begin
            Clk <= '1', '0' after 25 ns;
            wait for 50 ns;
        end process;
    
    test: process
        begin
            Reset <= '0'; wait for 200 ns;
            Reset <= '1'; oe <= '1';
            address <= SWITCH_BASE;
            databus <= "00000001";
            write_en <= '1'; wait for 50 ns;
            
            address <= std_logic_vector(unsigned(SWITCH_BASE) + to_unsigned(7, 8));
            databus <= "00000001";
            write_en <= '1'; wait for 50 ns;
            
            address <= T_STAT;
            databus <= "00100011";
            write_en <= '1'; wait for 50 ns;
            
            write_en <= '0';
            databus <= (others => 'Z'); wait for 50 ns; -- Hay que escribir ZZ en el bus durante un clock cycle para que sepa
                                                        -- que hay cambio escr -> lect
            
            address <= T_STAT;            
            oe <= '0';
     
            wait;
            
        end process;

end Testbench;
