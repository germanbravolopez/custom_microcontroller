----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2018 18:21:33
-- Design Name: 
-- Module Name: MAIN_CONTROL - Behavioral
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

entity MAIN_CONTROL is
    Port ( Reset     : in STD_LOGIC;
           Clk       : in STD_LOGIC;
           ROM_Data  : in STD_LOGIC_VECTOR (11 downto 0);
           ROM_Addr  : out STD_LOGIC_VECTOR (11 downto 0);
           RAM_Addr  : out STD_LOGIC_VECTOR (7 downto 0);
           RAM_CS    : out STD_LOGIC;
           RAM_Write : out STD_LOGIC;
           RAM_OE    : out STD_LOGIC;
           Databus   : inout STD_LOGIC_VECTOR (7 downto 0);
           DMA_RQ    : in STD_LOGIC;
           DMA_ACK   : out STD_LOGIC;
           SEND_comm : out STD_LOGIC;
           DMA_READY : in STD_LOGIC;
           ALU_op    : out alu_op;
           Index_Reg : in STD_LOGIC;
           FlagZ     : in STD_LOGIC;
           FlagC     : in STD_LOGIC;
           FlagN     : in STD_LOGIC;
           FlagE     : in STD_LOGIC);
end MAIN_CONTROL;

architecture Behavioral of MAIN_CONTROL is


    type State is (Idle, Dar_Buses, Fetch1, Fetch2, Decode, Execute1, Execute2, LecturaSalto, 
        DecisionSalto, Execute3, Mov_Registros, LecturaSegundaPalabra, Resto, Execute4, Stall);
    
    signal CurrentState, NextState       : State;
    signal type_instruccion              : std_logic_vector (1 downto 0);
    signal flag_mov_registros            : std_logic;
    signal flag_salto                    : std_logic;
    signal Cuenta_Instruccion            : unsigned(11 downto 0);
    signal instruccion                   : std_logic_vector(5 downto 0);
    signal registro_segunda              : std_logic_vector(11 downto 0);
    
begin

Next_process: process (currentstate) 
    begin
        case CurrentState is
            when Idle =>
                if(dma_rq = '1') then
                    NextState <= dar_buses;
                elsif(dma_rq='0') then
                    NextState <= fetch1;
                else
                    NextState <= Idle;
                end if;
            when dar_buses =>
                if(dma_rq = '0') then
                    NextState <= idle;
                else
                    NextState <= dar_buses;
                end if;
            when fetch1 =>
                NextState <= fetch2;
            when fetch2 =>
                NextState <= decode;
            when decode =>
                case type_instruccion is
                    when TYPE_1 =>
                        NextState <= Execute1;
                    when TYPE_2 =>            
                        NextState <= Execute2;
                    when TYPE_3 =>            
                        NextState <= Execute3;
                    when TYPE_4 =>            
                        NextState <= Execute4;
                    when others =>
                        NextState <= decode;
                end case;
            when execute1 =>
                NextState <= Idle;
            when execute2 =>
                NextState <= LecturaSalto;
            when LecturaSalto =>
                NextState <= DecisionSalto;
            when DecisionSalto =>
                NextState <= Idle;
                
            when Execute3 =>
                if(flag_mov_registros = '1') then
                    NextState <= Mov_Registros;
                else
                    NextState <= LecturaSegundaPalabra;
                end if;
                            
            when Mov_Registros =>
                NextState <= Idle;
            
            when LecturaSegundaPalabra =>
                NextState <= Resto;
                
            when Resto =>
                NextState <= Idle;
            
            when Execute4 =>
                NextState <= Stall;
                
            when Stall =>
                if (DMA_Ready = '1') then
                    NextState <= Idle;
                else
                    NextState <= Stall;
                end if;
        end case;
    end process;


FFs: process (Reset, Clk, NextState, CurrentState) 
    begin
        if Reset = '0' then
            CurrentState <= Idle;
        elsif Clk'event and Clk = '1' then
            CurrentState <= NextState;
        end if;
    end process;

Outputs: process (Clk) 
    begin
        case CurrentState is
            when Idle =>
                registro_segunda <= (others => '0');
                
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
            when dar_buses =>
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '1';
                Send_Comm <= '0';
                ALU_OP <= nop;
            when fetch1 =>
                Databus <= (others => 'Z');
                Rom_Addr <= std_logic_vector(Cuenta_Instruccion);
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
            when fetch2 =>
                Databus <= (others => 'Z');
                --Rom_Addr ;
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
                Type_Instruccion <= rom_data(7 downto 6);
                Instruccion <= rom_data(5 downto 0);

            when decode =>
            --flag
            case instruccion is
                when SRC_ACC & DST_A =>
                    flag_mov_registros <= '1';
                when src_acc & dst_b =>
                    flag_mov_registros <= '1';
                when src_ACC & DsT_indX =>
                    flag_mov_registros <= '1';
                when others =>
                    flag_mov_registros <= '0';
            end case;
            
                            Databus <= (others => 'Z');
            --Rom_Addr <= 
            Ram_Addr <= (others => 'Z');
            Ram_Write <= 'Z';
            Ram_OE <= 'Z';
            DMA_ACK <= '0';
            Send_Comm <= '0';
            ALU_OP <= nop;
            
                
            when execute1 =>
                            Databus <= (others => 'Z');
            --Rom_Addr <= 
            Ram_Addr <= (others => 'Z');
            Ram_Write <= 'Z';
            Ram_OE <= 'Z';
            DMA_ACK <= '0';
            Send_Comm <= '0';
            
                case Instruccion is
                    when ALU_ADD =>
                        alu_op <= op_add;
                    when ALU_SUB =>  
                        alu_op <= op_sub;   
                    when ALU_SHIFTL => 
                        alu_op <= op_shiftl; 
                    when ALU_SHIFTR =>  
                        alu_op <= op_shiftr;
                    when ALU_AND =>      
                        alu_op <= op_and;
                    when ALU_OR =>
                        alu_op <= op_or;      
                    when ALU_XOR =>
                        alu_op <= op_xor;     
                    when ALU_CMPE =>
                        alu_op <= op_cmpe;    
                    when ALU_CMPG =>
                        alu_op <= op_cmpg;   
                    when ALU_CMPL =>
                        alu_op <= op_cmpl;    
                    when ALU_ASCII2BIN =>
                        alu_op <= op_ascii2bin;
                    when ALU_BIN2ASCII =>
                        alu_op <= op_bin2ascii;
                end case;
                
            when execute2 =>
                Rom_Addr <= std_logic_vector(Cuenta_Instruccion);
                
                                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
            when LecturaSalto =>
                registro_segunda <= rom_Data;
                
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                            
            when DecisionSalto =>
                if (instruccion = JMP_UNCOND) then
                    flag_salto <= '1';
                else
                    if (flagz = '1') then
                        flag_Salto <= '1';
                    else
                        flag_salto <= '0';
                    end if;
                end if;
----------------------------------------------aqui
            when Execute3 =>
                if(flag_mov_registros = '1') then
                    NextState <= Mov_Registros;
                else
                    NextState <= LecturaSegundaPalabra;
                end if;
                            
            when Mov_Registros =>
                NextState <= Idle;
            
            when LecturaSegundaPalabra =>
                NextState <= Resto;
                
            when Resto =>
                NextState <= Idle;
            
            when Execute4 =>

                
            when Stall =>
                
        end case;
    end process;
    
CounterInstrucciones : process(Reset, CurrentState) 
    begin
        if (Reset = '0') then
            Cuenta_Instruccion <= (others => '1');
        elsif (Currentstate = idle and dma_rq = '0') then
            if(flag_salto = '1') then
                Cuenta_Instruccion <= unsigned(registro_segunda);
            else
                Cuenta_Instruccion <= Cuenta_Instruccion + to_unsigned(1,12);
            end if;
        elsif (Currentstate = Decode and type_instruccion = type_2) then
            Cuenta_Instruccion <= Cuenta_Instruccion + to_unsigned(1,12);
        elsif (Currentstate = Execute3 and flag_mov_registros = '0') then
            Cuenta_Instruccion <= Cuenta_Instruccion + to_unsigned(1,12);
        end if;    
    end process;
CounterNextClk : process(clk, Reset, CurrentState) 
        begin
            if (Reset = '0') then
                Next_clk <= (others => '0');
            elsif (clk'event and clk = '1') then
                if (Next_clk = "10") then
                    Next_clk <= (others => '0');
                elsif (CurrentState = espabiladr) then
                    Next_clk <= Next_clk + to_unsigned(1,2);
                else
                    Next_clk <= (others => '0');
                end if;
            end if;
        end process;  


end Behavioral;
