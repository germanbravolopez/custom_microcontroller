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
           FlagN     : in STD_LOGIC;
           FlagE     : in STD_LOGIC
           );
end MAIN_CONTROL;

architecture Behavioral of MAIN_CONTROL is

    type State is (Idle, Dar_buses, Fetch, Decode, Lectura_SP, Execute, Stall);
    
    signal CurrentState, NextState       : State;
    signal type_inst                     : std_logic_vector (1 downto 0) := "00";
    signal cuenta_inst                   : unsigned(11 downto 0) := (others => '0');
    signal instruccion                   : std_logic_vector(5 downto 0) := "000000";
    signal registro_segunda              : std_logic_vector(11 downto 0) := (others => '0');
    signal flag_salto                    : std_logic := '0';

begin


ROM_Addr <= std_logic_vector(cuenta_inst);

FFs: process (Reset, Clk, NextState) 
    begin
        if (Reset = '0') then
            CurrentState <= Idle;
        elsif (Clk'event and Clk = '1') then
            CurrentState <= NextState;
        end if;
    end process;
    
INST_COUNTER: process(Reset, Clk, CurrentState, NextState, type_inst, instruccion, flagZ, registro_segunda)
    begin
        if (Reset = '0') then
            cuenta_inst <= (others => '0');
        elsif (Clk'event and Clk = '1') then
            if (CurrentState = Decode and NextState <= Lectura_SP) then
                cuenta_inst <= cuenta_inst + 1; -- Suma uno para leer 2ª palabra
            elsif (CurrentState = Execute) then
                case (type_inst) is
                    when TYPE_1 =>  cuenta_inst <= cuenta_inst + 1;
                    when TYPE_2 =>
                        if (instruccion = JMP_UNCOND) then
                            cuenta_inst <= unsigned(registro_segunda); -- Salto incondicional
                        elsif (instruccion = JMP_COND) then
                            if (flagZ = '1') then 
                                cuenta_inst <= unsigned(registro_segunda);
                            else 
                                cuenta_inst <= cuenta_inst + 1;
                            end if;
                        end if;
                    when TYPE_3 =>  cuenta_inst <= cuenta_inst + 1;
                    when others =>  null;
                end case;
            elsif (CurrentState = Stall and NextState = Idle) then -- Pasar a la siguiente inst
                cuenta_inst <= cuenta_inst + 1;
            end if;
        end if;
    end process;


CPU_proc: process (CurrentState, DMA_RQ, ROM_Data, flagZ, type_inst, instruccion, registro_segunda, Index_Reg, DMA_Ready) 
    begin
        Databus <= (others => 'Z');
        RAM_Addr <= (others => 'Z');
        case CurrentState is
        
            when Idle => ------------------------------------------------------------------
                -- DMA
                DMA_ACK   <= '0';
                Send_Comm <= '0';
                -- RAM
                RAM_Write <= '0';
                RAM_Addr  <= (others => 'Z');
                RAM_OE    <= '1';
                -- Databus
                Databus <= (others => 'Z');
                -- ALU
                ALU_OP <= nop;
                
                -- NextState
                if (DMA_RQ = '1') then
                    NextState <= Dar_buses;
                elsif(DMA_RQ = '0') then
                    NextState <= Fetch;
                else
                    NextState <= Idle;
                end if;
                
            when dar_buses => ------------------------------------------------------------------
                -- DMA
                DMA_ACK   <= '1';
                Send_Comm <= '0';
                -- RAM
                RAM_Write <= '0';
                RAM_Addr  <= (others => 'Z');
                RAM_OE    <= '1';
                -- Databus
                Databus <= (others => 'Z');
                -- ALU
                ALU_OP <= nop;
                                
                -- NextState
                if (DMA_RQ = '0') then
                    NextState <= Idle;
                else
                    NextState <= Dar_buses;
                end if;

            when Fetch => ------------------------------------------------------------------
                -- DMA
                DMA_ACK   <= '0';
                Send_Comm <= '0';
                -- RAM
                RAM_Write <= '0';
                RAM_Addr  <= (others => 'Z');
                RAM_OE    <= '1';
                -- Databus
                Databus <= (others => 'Z');
                -- ALU
                ALU_OP <= nop;
                
                -- Señales internas
                type_inst   <= ROM_Data(7 downto 6);
                instruccion <= ROM_Data(5 downto 0);
                
                -- NextState
                if (DMA_RQ = '1') then
                    NextState <= Dar_buses;
                else
                    NextState <= Decode;
                end if;
                
            when Decode => ------------------------------------------------------------------
                -- DMA
                DMA_ACK   <= '0';
                Send_Comm <= '0';
                -- RAM
                RAM_Write <= '0';
                RAM_Addr  <= (others => 'Z');
                RAM_OE    <= '1';
                -- Databus
                Databus <= (others => 'Z');
                -- ALU
                ALU_OP <= nop;
                                
                -- Analizar las instrucciones + NextState
                case type_inst is
                    when TYPE_1 =>
                        NextState <= Execute;
                    when TYPE_2 => 
                        NextState <= Lectura_SP;
                    when TYPE_3 =>            
                        case instruccion (4 downto 0) is
                            when SRC_ACC & DST_A =>
                                NextState <= Execute;
                            when SRC_ACC & DST_B =>
                                NextState <= Execute;
                            when SRC_ACC & DST_INDX =>
                                NextState <= Execute;
                            when others =>
                                NextState <= Lectura_SP;
                        end case;
                    when TYPE_4 =>            
                        NextState <= Execute;
                    when others =>
                        NextState <= Decode;
                end case;
                
            when Lectura_SP => ------------------------------------------------------------------
                -- DMA
                DMA_ACK   <= '0';
                Send_Comm <= '0';
                -- RAM
                RAM_Write <= '0';
                RAM_Addr  <= (others => 'Z');
                RAM_OE    <= '1';
                -- Databus
                Databus <= (others => 'Z');
                -- ALU
                ALU_OP <= nop;
                
                -- Señales internas
                registro_segunda <= ROM_Data;
                
                -- Hay que cargar la ram con anterioridad
                if (instruccion(5 downto 3) = (LD & SRC_MEM)) then
                    RAM_Addr <= registro_segunda(7 downto 0);
                    RAM_OE <= '0';
                elsif (instruccion(5 downto 3) = (LD & SRC_INDXD_MEM)) then
                    RAM_Addr <= std_logic_vector(unsigned(registro_segunda(7 downto 0)) + unsigned(Index_Reg(7 downto 0)));
                    RAM_OE <= '0';
                elsif (instruccion(5 downto 0) = (WR & SRC_ACC & DST_MEM)) then
                    RAM_Addr <= registro_segunda(7 downto 0);
                    alu_op <= op_oeacc;
                elsif (instruccion(5 downto 0) = (WR & SRC_ACC & DST_INDXD_MEM)) then
                    RAM_Addr <= std_logic_vector(unsigned(registro_segunda(7 downto 0)) + unsigned(Index_Reg(7 downto 0)));
                    alu_op <= op_oeacc;
                end if;
                
                -- NextState
                NextState <= Execute;
                
            when Execute => ------------------------------------------------------------------
                -- DMA
                DMA_ACK   <= '0';
                Send_Comm <= '0';
                -- RAM
                RAM_Write <= '0';
                RAM_Addr  <= (others => 'Z');
                RAM_OE    <= '1';
                -- Databus
                Databus <= (others => 'Z');
                
                -- ALU: Tareas a realizar según la instrucción
                case type_inst is
                    when TYPE_1 =>
                        case instruccion is
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
                            when others =>
                                alu_op <= nop;
                        end case;
                        
                        if (DMA_RQ = '1') then     
                            NextState <= Dar_buses;
                        else                       
                            NextState <= Idle;     
                        end if;                    
                        
                    when TYPE_2 => 
                        alu_op <= nop;
                        
                        if (DMA_RQ = '1') then     
                            NextState <= Dar_buses;
                        else                       
                            NextState <= Idle;     
                        end if;                    
                        
                    when TYPE_3 =>     
                        case instruccion(5) is
                            when LD =>
                                case instruccion(4 downto 3) is
                                    when SRC_ACC =>            -- Movimiento entre registros
                                        case instruccion(2 downto 0) is
                                            when DST_A =>    
                                                alu_op <= op_mvacc2a;
                                            when DST_B =>
                                                alu_op <= op_mvacc2b;
                                            when DST_INDX =>
                                                alu_op <= op_mvacc2id;
                                            when others =>
                                                alu_op <= nop;
                                        end case;
                                    when SRC_CONSTANT =>             -- Cargar una constante
                                        Databus <= registro_segunda(7 downto 0);
                                        case instruccion(2 downto 0) is
                                            when DST_A =>    
                                                alu_op <= op_lda;
                                            when DST_B =>
                                                alu_op <= op_ldb;
                                            when DST_ACC =>
                                                alu_op <= op_ldacc;
                                            when DST_INDX =>
                                                alu_op <= op_ldid;
                                            when others =>
                                                alu_op <= nop;
                                        end case;
                                    when SRC_MEM =>                  -- Cargar desde memoria
                                        RAM_Addr <= registro_segunda(7 downto 0);
                                        RAM_OE <= '0';
                                        case instruccion(2 downto 0) is
                                            when DST_A =>         
                                                alu_op <= op_lda;                               
                                            when DST_B =>                        
                                                alu_op <= op_ldb;                               
                                            when DST_ACC =>                      
                                                alu_op <= op_ldacc;                             
                                            when DST_INDX =>                     
                                                alu_op <= op_ldid;  
                                            when others =>
                                                alu_op <= nop;
                                        end case;
                                    when SRC_INDXD_MEM =>           -- Cargar desde el index
                                        RAM_Addr <= std_logic_vector(unsigned(registro_segunda(7 downto 0)) + unsigned(Index_Reg(7 downto 0)));
                                        RAM_OE <= '0';
                                        case instruccion(2 downto 0) is
                                            when DST_A =>         
                                                alu_op <= op_lda;                               
                                            when DST_B =>                        
                                                alu_op <= op_ldb;                               
                                            when DST_ACC =>                      
                                                alu_op <= op_ldacc;                             
                                            when DST_INDX =>                     
                                                alu_op <= op_ldid;    
                                            when others =>
                                                alu_op <= nop;
                                        end case;
                                    when others =>
                                        null;
                                end case;
                            when WR =>
                                case instruccion (4 downto 0) is
                                    when SRC_ACC & DST_MEM =>
                                        RAM_Write <= '1';
                                        RAM_Addr <= registro_segunda(7 downto 0);
                                        alu_op <= op_oeacc;
                                    when SRC_ACC & DST_INDXD_MEM =>
                                        RAM_Write <= '1';
                                        RAM_Addr <= std_logic_vector(unsigned(registro_segunda(7 downto 0)) + unsigned(Index_Reg(7 downto 0)));
                                        alu_op <= op_oeacc;
                                    when others =>
                                        RAM_Write <= '0';
                                        RAM_Addr  <= (others => 'Z');
                                        alu_op <= nop;
                                end case;
                            when others =>
                                null;
                        end case;       
                        
                        if (DMA_RQ = '1') then     
                            NextState <= Dar_buses;
                        else                       
                            NextState <= Idle;     
                        end if;                    
                        
                    when TYPE_4 =>            
                        alu_op <= nop;
                        Send_Comm <= '1';
                        
                        NextState <= Stall;
                    
                    when others =>
                        alu_op <= nop;
                        NextState <= Execute;
                end case;

            when Stall => ------------------------------------------------------------------
                -- DMA
                DMA_ACK   <= '0';
                Send_Comm <= '0';
                -- RAM
                RAM_Write <= '0';
                RAM_Addr  <= (others => 'Z');
                RAM_OE    <= '1';
                -- Databus
                Databus <= (others => 'Z');
                -- ALU
                ALU_OP <= nop;
                                
                -- NextState
                if(DMA_READY = '1') then
                    NextState <= Idle;
                else
                    NextState <= Stall;
                end if;
        end case;
    end process;  

end Behavioral;