library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;

entity cpu is
    port ( reset     : in std_logic;
           clk       : in std_logic;
           rom_data  : in std_logic_vector (11 downto 0);
           rom_addr  : out std_logic_vector (11 downto 0);
           ram_addr  : out std_logic_vector (7 downto 0);
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
           flagn     : in std_logic;
           flage     : in std_logic
           );
end cpu;

architecture behavioral of cpu is

    type state is (idle, dar_buses, fetch, decode, lectura_sp, execute, stall);

    signal currentstate, nextstate       : state;
    signal type_inst                     : std_logic_vector (1 downto 0) := "00";
    signal cuenta_inst                   : unsigned(11 downto 0) := (others => '0');
    signal instruccion                   : std_logic_vector(5 downto 0) := "000000";
    signal registro_segunda              : std_logic_vector(11 downto 0) := (others => '0');
    signal flag_salto                    : std_logic := '0';

begin


rom_addr <= std_logic_vector(cuenta_inst);

ffs: process (reset, clk, nextstate)
    begin
        if (reset = '0') then
            currentstate <= idle;
        elsif (clk'event and clk = '1') then
            currentstate <= nextstate;
        end if;
    end process;

inst_counter: process(reset, clk, currentstate, nextstate, type_inst, instruccion, flagz, registro_segunda)
    begin
        if (reset = '0') then
            cuenta_inst <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (currentstate = decode and nextstate <= lectura_sp) then
                cuenta_inst <= cuenta_inst + 1; -- suma uno para leer 2� palabra
            elsif (currentstate = execute) then
                case (type_inst) is
                    when type_1 =>  cuenta_inst <= cuenta_inst + 1;
                    when type_2 =>
                        if (instruccion = jmp_uncond) then
                            cuenta_inst <= unsigned(registro_segunda); -- salto incondicional
                        elsif (instruccion = jmp_cond) then
                            if (flagz = '1') then
                                cuenta_inst <= unsigned(registro_segunda);
                            else
                                cuenta_inst <= cuenta_inst + 1;
                            end if;
                        end if;
                    when type_3 =>  cuenta_inst <= cuenta_inst + 1;
                    when others =>  null;
                end case;
            elsif (currentstate = stall and nextstate = idle) then -- pasar a la siguiente inst
                cuenta_inst <= cuenta_inst + 1;
            end if;
        end if;
    end process;


cpu_proc: process (currentstate, dma_rq, rom_data, flagz, type_inst, instruccion, registro_segunda, index_reg, dma_ready)
    begin
        databus <= (others => 'z');
        ram_addr <= (others => 'z');
        case currentstate is

            when idle => ------------------------------------------------------------------
                -- dma
                dma_ack   <= '0';
                send_comm <= '0';
                -- ram
                ram_write <= '0';
                ram_addr  <= (others => 'z');
                ram_oe    <= '1';
                -- databus
                databus <= (others => 'z');
                -- alu
                alu_op <= nop;

                -- nextstate
                if (dma_rq = '1') then
                    nextstate <= dar_buses;
                elsif(dma_rq = '0') then
                    nextstate <= fetch;
                else
                    nextstate <= idle;
                end if;

            when dar_buses => ------------------------------------------------------------------
                -- dma
                dma_ack   <= '1';
                send_comm <= '0';
                -- ram
                ram_write <= '0';
                ram_addr  <= (others => 'z');
                ram_oe    <= '1';
                -- databus
                databus <= (others => 'z');
                -- alu
                alu_op <= nop;

                -- nextstate
                if (dma_rq = '0') then
                    nextstate <= idle;
                else
                    nextstate <= dar_buses;
                end if;

            when fetch => ------------------------------------------------------------------
                -- dma
                dma_ack   <= '0';
                send_comm <= '0';
                -- ram
                ram_write <= '0';
                ram_addr  <= (others => 'z');
                ram_oe    <= '1';
                -- databus
                databus <= (others => 'z');
                -- alu
                alu_op <= nop;

                -- se�ales internas
                type_inst   <= rom_data(7 downto 6);
                instruccion <= rom_data(5 downto 0);

                -- nextstate
                if (dma_rq = '1') then
                    nextstate <= dar_buses;
                else
                    nextstate <= decode;
                end if;

            when decode => ------------------------------------------------------------------
                -- dma
                dma_ack   <= '0';
                send_comm <= '0';
                -- ram
                ram_write <= '0';
                ram_addr  <= (others => 'z');
                ram_oe    <= '1';
                -- databus
                databus <= (others => 'z');
                -- alu
                alu_op <= nop;

                -- analizar las instrucciones + nextstate
                case type_inst is
                    when type_1 =>
                        nextstate <= execute;
                    when type_2 =>
                        nextstate <= lectura_sp;
                    when type_3 =>
                        case instruccion (4 downto 0) is
                            when src_acc & dst_a =>
                                nextstate <= execute;
                            when src_acc & dst_b =>
                                nextstate <= execute;
                            when src_acc & dst_indx =>
                                nextstate <= execute;
                            when others =>
                                nextstate <= lectura_sp;
                        end case;
                    when type_4 =>
                        nextstate <= execute;
                    when others =>
                        nextstate <= decode;
                end case;

            when lectura_sp => ------------------------------------------------------------------
                -- dma
                dma_ack   <= '0';
                send_comm <= '0';
                -- ram
                ram_write <= '0';
                ram_addr  <= (others => 'z');
                ram_oe    <= '1';
                -- databus
                databus <= (others => 'z');
                -- alu
                alu_op <= nop;

                -- se�ales internas
                registro_segunda <= rom_data;

                -- hay que cargar la ram con anterioridad
                if (instruccion(5 downto 3) = (ld & src_mem)) then
                    ram_addr <= registro_segunda(7 downto 0);
                    ram_oe <= '0';
                elsif (instruccion(5 downto 3) = (ld & src_indxd_mem)) then
                    ram_addr <= std_logic_vector(unsigned(registro_segunda(7 downto 0)) + unsigned(index_reg(7 downto 0)));
                    ram_oe <= '0';
                elsif (instruccion(5 downto 0) = (wr & src_acc & dst_mem)) then
                    ram_addr <= registro_segunda(7 downto 0);
                    alu_op <= op_oeacc;
                elsif (instruccion(5 downto 0) = (wr & src_acc & dst_indxd_mem)) then
                    ram_addr <= std_logic_vector(unsigned(registro_segunda(7 downto 0)) + unsigned(index_reg(7 downto 0)));
                    alu_op <= op_oeacc;
                end if;

                -- nextstate
                nextstate <= execute;

            when execute => ------------------------------------------------------------------
                -- dma
                dma_ack   <= '0';
                send_comm <= '0';
                -- ram
                ram_write <= '0';
                ram_addr  <= (others => 'z');
                ram_oe    <= '1';
                -- databus
                databus <= (others => 'z');

                -- alu: tareas a realizar seg�n la instrucci�n
                case type_inst is
                    when type_1 =>
                        case instruccion is
                            when alu_add =>
                                alu_op <= op_add;
                            when alu_sub =>
                                alu_op <= op_sub;
                            when alu_shiftl =>
                                alu_op <= op_shiftl;
                            when alu_shiftr =>
                                alu_op <= op_shiftr;
                            when alu_and =>
                                alu_op <= op_and;
                            when alu_or =>
                                alu_op <= op_or;
                            when alu_xor =>
                                alu_op <= op_xor;
                            when alu_cmpe =>
                                alu_op <= op_cmpe;
                            when alu_cmpg =>
                                alu_op <= op_cmpg;
                            when alu_cmpl =>
                                alu_op <= op_cmpl;
                            when alu_ascii2bin =>
                                alu_op <= op_ascii2bin;
                            when alu_bin2ascii =>
                                alu_op <= op_bin2ascii;
                            when others =>
                                alu_op <= nop;
                        end case;

                        if (dma_rq = '1') then
                            nextstate <= dar_buses;
                        else
                            nextstate <= idle;
                        end if;

                    when type_2 =>
                        alu_op <= nop;

                        if (dma_rq = '1') then
                            nextstate <= dar_buses;
                        else
                            nextstate <= idle;
                        end if;

                    when type_3 =>
                        case instruccion(5) is
                            when ld =>
                                case instruccion(4 downto 3) is
                                    when src_acc =>            -- movimiento entre registros
                                        case instruccion(2 downto 0) is
                                            when dst_a =>
                                                alu_op <= op_mvacc2a;
                                            when dst_b =>
                                                alu_op <= op_mvacc2b;
                                            when dst_indx =>
                                                alu_op <= op_mvacc2id;
                                            when others =>
                                                alu_op <= nop;
                                        end case;
                                    when src_constant =>             -- cargar una constante
                                        databus <= registro_segunda(7 downto 0);
                                        case instruccion(2 downto 0) is
                                            when dst_a =>
                                                alu_op <= op_lda;
                                            when dst_b =>
                                                alu_op <= op_ldb;
                                            when dst_acc =>
                                                alu_op <= op_ldacc;
                                            when dst_indx =>
                                                alu_op <= op_ldid;
                                            when others =>
                                                alu_op <= nop;
                                        end case;
                                    when src_mem =>                  -- cargar desde memoria
                                        ram_addr <= registro_segunda(7 downto 0);
                                        ram_oe <= '0';
                                        case instruccion(2 downto 0) is
                                            when dst_a =>
                                                alu_op <= op_lda;
                                            when dst_b =>
                                                alu_op <= op_ldb;
                                            when dst_acc =>
                                                alu_op <= op_ldacc;
                                            when dst_indx =>
                                                alu_op <= op_ldid;
                                            when others =>
                                                alu_op <= nop;
                                        end case;
                                    when src_indxd_mem =>           -- cargar desde el index
                                        ram_addr <= std_logic_vector(unsigned(registro_segunda(7 downto 0)) + unsigned(index_reg(7 downto 0)));
                                        ram_oe <= '0';
                                        case instruccion(2 downto 0) is
                                            when dst_a =>
                                                alu_op <= op_lda;
                                            when dst_b =>
                                                alu_op <= op_ldb;
                                            when dst_acc =>
                                                alu_op <= op_ldacc;
                                            when dst_indx =>
                                                alu_op <= op_ldid;
                                            when others =>
                                                alu_op <= nop;
                                        end case;
                                    when others =>
                                        null;
                                end case;
                            when wr =>
                                case instruccion (4 downto 0) is
                                    when src_acc & dst_mem =>
                                        ram_write <= '1';
                                        ram_addr <= registro_segunda(7 downto 0);
                                        alu_op <= op_oeacc;
                                    when src_acc & dst_indxd_mem =>
                                        ram_write <= '1';
                                        ram_addr <= std_logic_vector(unsigned(registro_segunda(7 downto 0)) + unsigned(index_reg(7 downto 0)));
                                        alu_op <= op_oeacc;
                                    when others =>
                                        ram_write <= '0';
                                        ram_addr  <= (others => 'z');
                                        alu_op <= nop;
                                end case;
                            when others =>
                                null;
                        end case;

                        if (dma_rq = '1') then
                            nextstate <= dar_buses;
                        else
                            nextstate <= idle;
                        end if;

                    when type_4 =>
                        alu_op <= nop;
                        send_comm <= '1';

                        nextstate <= stall;

                    when others =>
                        alu_op <= nop;
                        nextstate <= execute;
                end case;

            when stall => ------------------------------------------------------------------
                -- dma
                dma_ack   <= '0';
                send_comm <= '0';
                -- ram
                ram_write <= '0';
                ram_addr  <= (others => 'z');
                ram_oe    <= '1';
                -- databus
                databus <= (others => 'z');
                -- alu
                alu_op <= nop;

                -- nextstate
                if(dma_ready = '1') then
                    nextstate <= idle;
                else
                    nextstate <= stall;
                end if;
        end case;
    end process;

end behavioral;