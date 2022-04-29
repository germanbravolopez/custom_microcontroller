library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;

entity dma is
    port ( reset     : in std_logic;
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
end dma;

architecture behavioral of dma is

    type state is (idle, inicio_tx, aviso_envio1, envio1, envio2, aviso_envio2, inicio_rx, espabiladr, recibir, the_end);
    
    signal currentstate, nextstate : state;
    signal count_rx                : unsigned(1 downto 0) := "00";
    signal next_clk                : unsigned(1 downto 0) := "00";
    
begin

ffs: process (reset, clk, nextstate) 
    begin
        if (reset = '0') then
            currentstate <= idle;
        elsif (clk'event and clk = '1') then
            currentstate <= nextstate;
        end if;
    end process;
    
    
next_process: process (currentstate, rx_empty, send_comm, tx_rdy, dma_ack, count_rx, next_clk) 
    begin
        case currentstate is
            when idle =>
                if(rx_empty = '0' and send_comm = '0') then
                    nextstate <= inicio_rx;
                elsif(send_comm = '1') then
                    nextstate <= inicio_tx;
                else
                    nextstate <= idle;
                end if;
            when inicio_tx =>
                if(tx_rdy = '1') then
                    nextstate <= aviso_envio1;
                else
                    nextstate <= inicio_tx;
                end if;
            when aviso_envio1 =>
                if (tx_rdy = '0') then   
                    nextstate <= envio1;
                else
                    nextstate <= aviso_envio1;
                end if;
            when envio1 =>
                if (tx_rdy = '1') then  
                    nextstate <= aviso_envio2;
                else
                    nextstate <= envio1;
                end if;
            when aviso_envio2 =>
                if (tx_rdy = '0') then  
                    nextstate <= envio2;
                else
                    nextstate <= aviso_envio2;
                end if;
            when envio2 =>
                if (tx_rdy = '1') then  
                    nextstate <= idle;
                else
                    nextstate <= envio2;
                end if;
            when inicio_rx =>
                if(dma_ack = '1') then
                    nextstate <= espabiladr;
                else
                    nextstate <= inicio_rx;
                end if;
            when espabiladr =>
                if (next_clk = "01") then
                    nextstate <= recibir;
                else
                    nextstate <= espabiladr;
                end if;
            when recibir =>
                if(count_rx < "10") then
                    nextstate <= idle;
                elsif (count_rx = "10") then
                    nextstate <= the_end;
                else
                    nextstate <= recibir;
                end if;
            when the_end =>
                if (count_rx = "00") then
                    nextstate <= idle;
                else
                    nextstate <= the_end;
                end if;
        end case;
    end process;

outputs: process (currentstate, databus, count_rx, rcvd_data) 
    begin
    databus <= (others => 'z');
    address <= (others => 'z');
        case currentstate is
            when idle =>
                --rx
                data_read <= '0';
                write_en <= '0';
                
                --tx
                oe_dma <= '1';
                valid_d <= '1';
                tx_data <= (others => 'z');
                
                --ambos
                dma_rq <= '0';
                ready  <= '1';
                address <= (others => 'z');
                databus <= (others => 'z');
                
            when inicio_tx =>
                --rx
                data_read <= '0';
                write_en <= '0';
                
                --tx
                oe_dma <= '1';
                valid_d <= '1';
                tx_data <= (others => 'z');
                
                --ambos
                dma_rq <= '0';
                ready  <= '0';
                address <= (others => 'z');
                databus <= (others => 'z');

            when aviso_envio1 =>
                --rx
                data_read <= '0';
                write_en <= '0';
                
                --tx
                oe_dma <= '0';
                valid_d <= '0';
                tx_data <= databus;
                
                --ambos
                dma_rq <= '0';
                ready  <= '0';
                address <= dma_tx_buffer_msb;

            when envio1 =>
                --rx
                data_read <= '0';
                write_en <= '0';
                
                --tx
                oe_dma <= '0';
                valid_d <= '1';
                tx_data <= databus;
                
                --ambos
                dma_rq <= '0';
                ready  <= '0';
                address <= dma_tx_buffer_msb;
                            
            when aviso_envio2 =>
                --rx
                data_read <= '0';
                write_en <= '0';
                
                --tx
                oe_dma <= '0';
                valid_d <= '0';
                tx_data <= databus;
                
                --ambos
                dma_rq <= '0';
                ready  <= '0';
                address <= dma_tx_buffer_lsb;
                                           
            when envio2 =>
                --rx
                data_read <= '0';
                write_en <= '0';
                
                --tx
                oe_dma <= '0';
                valid_d <= '1';
                tx_data <= databus;
                
                --ambos
                dma_rq <= '0';
                ready  <= '0';
                address <= dma_tx_buffer_lsb;
                            
            when inicio_rx =>
                --rx
                data_read <= '0';
                write_en <= '0';
                
                --tx
                oe_dma <= '1';
                valid_d <= '1';
                tx_data <= (others => 'z');
                
                --ambos
                dma_rq <= '1'; -- solicitud de los buses
                ready  <= '0';
                address <= (others => 'z');
                databus <= (others => 'z');

            when espabiladr =>
                --rx
                data_read <= '1';
                write_en <= '0'; -- todav�a no escribe en ram
                
                --tx
                oe_dma <= '1'; -- no se puede leer de la ram tampoco
                valid_d <= '1';
                tx_data <= (others => 'z');
                
                --ambos
                dma_rq <= '1';
                ready  <= '0';
                address <= (others => 'z');
                databus <= (others => 'z');
                
            when recibir =>
                --rx
                data_read <= '0';
                write_en <= '1';
                
                --tx
                oe_dma <= '1';
                valid_d <= '1';
                tx_data <= (others => 'z');
                
                --ambos
                dma_rq <= '1';
                ready  <= '0';                            
                case count_rx is                                  
                    when "00"   =>    address <= dma_rx_buffer_msb; 
                    when "01"   =>    address <= dma_rx_buffer_mid; 
                    when "10"   =>    address <= dma_rx_buffer_lsb; 
                    when others =>    address <= (others => 'z');   
                end case;                                                       
                databus <= rcvd_data; 
                                       
            when the_end =>
                --rx
                data_read <= '0';
                write_en <= '1';
                
                --tx
                oe_dma <= '1';
                valid_d <= '1';
                tx_data <= (others => 'z');
                
                --ambos
                dma_rq <= '1';
                ready  <= '0';
                address <= x"03";
                databus <= x"ff";
        end case;
    end process;
    
counterrecibir: process(clk, reset, currentstate) 
    begin
        if (reset = '0') then
            count_rx <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (count_rx = "11") then
                count_rx <= (others => '0');
            elsif (currentstate = recibir) then
                count_rx <= count_rx + to_unsigned(1,2);
            end if;
        end if;
    end process;
    
counternextclk : process(clk, reset, currentstate) 
        begin
            if (reset = '0') then
                next_clk <= (others => '0');
            elsif (clk'event and clk = '1') then
                if (next_clk = "10") then
                    next_clk <= (others => '0');
                elsif (currentstate = espabiladr) then
                    next_clk <= next_clk + to_unsigned(1,2);
                else
                    next_clk <= (others => '0');
                end if;
            end if;
        end process;    

end behavioral;
