-- cpu.vhd: Simple 8-bit CPU (BrainFuck interpreter)
-- Copyright (C) 2025 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): Andrej Vadovsky xvadova00
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cpu is
 port (
   CLK   : in std_logic;  -- hodinovy signal
   RESET : in std_logic;  -- asynchronni reset procesoru
   EN    : in std_logic;  -- povoleni cinnosti procesoru
 
   -- synchronni pamet RAM
   DATA_ADDR  : out std_logic_vector(12 downto 0); -- adresa do pameti
   DATA_WDATA : out std_logic_vector(7 downto 0); -- mem[DATA_ADDR] <- DATA_WDATA pokud DATA_EN='1'
   DATA_RDATA : in std_logic_vector(7 downto 0);  -- DATA_RDATA <- ram[DATA_ADDR] pokud DATA_EN='1'
   DATA_RDWR  : out std_logic;                    -- cteni (1) / zapis (0)
   DATA_EN    : out std_logic;                    -- povoleni cinnosti
   
   -- vstupni port
   IN_DATA   : in std_logic_vector(7 downto 0);   -- IN_DATA <- stav klavesnice pokud IN_VLD='1' a IN_REQ='1'
   IN_VLD    : in std_logic;                      -- data platna
   IN_REQ    : out std_logic;                     -- pozadavek na vstup data
   
   -- vystupni port
   OUT_DATA : out  std_logic_vector(7 downto 0);  -- zapisovana data
   OUT_BUSY : in std_logic;                       -- LCD je zaneprazdnen (1), nelze zapisovat
   OUT_INV  : out std_logic;                      -- pozadavek na aktivaci inverzniho zobrazeni (1)
   OUT_WE   : out std_logic;                      -- LCD <- OUT_DATA pokud OUT_WE='1' a OUT_BUSY='0'

   -- stavove signaly
   READY    : out std_logic;                      -- hodnota 1 znamena, ze byl procesor inicializovan a zacina vykonavat program
   DONE     : out std_logic                       -- hodnota 1 znamena, ze procesor ukoncil vykonavani programu (narazil na instrukci halt)
 );
end cpu;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cpu is
    signal pc_reg : std_logic_vector(12 downto 0);   
    signal ptr_reg : std_logic_vector(12 downto 0);  
    signal cnt_reg : std_logic_vector(7 downto 0) ;
    signal print_data : std_logic_vector(7 downto 0) ;
    signal tmp_reg : std_logic_vector(7 downto 0);
        type state_type is (
        s_init,
        s_init_wait,             
        s_fetch,         
        s_decode,
        s_inc_read,
        s_dec_read,
        s_inc_write,
        s_dec_write,
        s_numbers_letters_wait,
        s_numbers_letters,
        s_doStart_wait,
        s_doStart,
        s_doEnd_wait,
        s_do_end_waiting,
        s_doEnd,
        s_doEnd_next,
        s_loopStart_wait,
        s_loopStart,
        s_loop_start_waiting,
        s_loop_end_waiting,
        s_loopEnd_wait,
        s_loopEnd,
        s_loopEnd_next,
        s_loop_next,
        s_print_wait,
        s_print,
        s_wait_read,
        s_read,
        sh            
    );
    signal pc_inc : std_logic ; 
    signal pc_dec : std_logic ;
    signal ptr_inc : std_logic ;
    signal ptr_dec : std_logic ;
    signal ptr_set : std_logic ;
    signal pc_reset : std_logic ;
    signal cnt_inc : std_logic;
    signal cnt_dec : std_logic ;
    signal cnt_set : std_logic;
    signal present_state : state_type;
    signal next_state : state_type;
begin


process(CLK,RESET)
begin
    if RESET = '1'  then
      pc_reg <= (others => '0');
      ptr_reg <= (others => '0');
      cnt_reg <= (others => '0');
      present_state <= s_init;
    elsif rising_edge(CLK) then
      if EN = '1'   then
        present_state <= next_state;

        if ptr_set = '1' then
          if pc_reg = "1111111111111" then
            ptr_reg <= (others => '0');
          else
          ptr_reg <= pc_reg + 1;  
          end if;
        elsif ptr_inc = '1' then
          if ptr_reg = "1111111111111" then
            ptr_reg <= (others => '0');
          else
          ptr_reg <= ptr_reg + 1;
          end if;
        elsif ptr_dec = '1' then
          if ptr_reg = "0000000000000" then
            ptr_reg <= (others => '1');
          else
          ptr_reg <= ptr_reg - 1;
          end if;
        end if;

        if pc_reset = '1' then
          pc_reg <= (others => '0');
        elsif pc_inc = '1' then
          if pc_reg = "1111111111111" then
            pc_reg <= (others => '0');
          else
          pc_reg <= pc_reg + 1;
          end if;
        elsif pc_dec = '1' then
          if pc_reg = "0000000000000" then
            pc_reg <= (others => '1');
          else
          pc_reg <= pc_reg - 1;
          end if;
        end if;

        if cnt_set = '1' then
            cnt_reg <= x"01";
        elsif cnt_inc = '1' then
            cnt_reg <= cnt_reg + 1;
        elsif cnt_dec = '1' then
            cnt_reg <= cnt_reg - 1;
        end if;

        if present_state = s_numbers_letters_wait then 
          if DATA_RDATA >= x"30" and DATA_RDATA <= x"39" then 
            tmp_reg(7 downto 4) <= DATA_RDATA(3 downto 0);  
            tmp_reg(3 downto 0) <= x"0"; 
          elsif DATA_RDATA >= x"41" and DATA_RDATA <= x"46" then 
            tmp_reg(7 downto 4) <= DATA_RDATA(3 downto 0) + x"9";
            tmp_reg(3 downto 0) <= x"0";
          else
            tmp_reg <= (others => '0');
          end if;

      end if;
      end if;
    end if;
  end process;

process(present_state,DATA_RDATA,OUT_BUSY,IN_VLD,pc_reg,ptr_reg)
begin
    next_state <= present_state;
    DATA_EN <= '0';
    DATA_RDWR <= '1';
    pc_inc <= '0';      
    pc_dec <= '0'; 
    pc_reset <= '0';     
    ptr_inc <= '0';     
    ptr_dec <= '0';     
    ptr_set <= '0';
    cnt_inc <= '0';  
    cnt_dec <= '0';  
    cnt_set <= '0';
    IN_REQ <= '0';     
    OUT_WE <= '0';     
    OUT_DATA <= (others => '0');  
    OUT_INV <= '0';    
    DATA_ADDR <= (others => '0');  
    case present_state is

      when s_doEnd_next =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= pc_reg;   
        if DATA_RDATA = x"29" then
          cnt_inc <= '1';
          pc_dec <= '1';
          next_state <= s_do_end_waiting;
        elsif DATA_RDATA = x"28" then
          if cnt_reg = x"01" then
            pc_inc <= '1';
            next_state <= s_fetch;
          else
            cnt_dec <= '1';
            pc_dec <='1';
            next_state <= s_do_end_waiting;
          end if;
        else
          pc_dec <='1';
          next_state <= s_do_end_waiting;
        end if;

        when s_do_end_waiting =>
          DATA_EN <= '1';
          DATA_RDWR <= '1';
          DATA_ADDR <= pc_reg; 
          next_state <= s_doEnd_next; 

      when s_doEnd =>
      if DATA_RDATA = x"00" then  
        pc_inc <= '1';
        next_state <= s_fetch;  
      else
        cnt_set <= '1';
        pc_dec <= '1';
        next_state <= s_doEnd_next;  
      end if;

      when s_doEnd_wait =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= ptr_reg;  
        next_state <= s_doEnd;

      when s_doStart =>
        pc_inc <= '1';
        next_state <= s_fetch;

      when s_doStart_wait =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= ptr_reg;
        next_state <= s_doStart;

      when s_loopEnd_next =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= pc_reg;   
        if DATA_RDATA = x"5D" then
          cnt_inc <= '1';
          pc_dec <= '1';
          next_state <= s_loop_end_waiting;
        elsif DATA_RDATA = x"5B" then
          if cnt_reg = x"01" then
            pc_inc <= '1';
            next_state <= s_fetch;
          else
            cnt_dec <= '1';
            pc_dec <='1';
            next_state <= s_loop_end_waiting;
          end if;
        else
          pc_dec <='1';
          next_state <= s_loop_end_waiting;
        end if;

        when s_loop_end_waiting =>
          DATA_EN <= '1';
          DATA_RDWR <= '1';
          DATA_ADDR <= pc_reg; 
          next_state <= s_loopEnd_next; 

      when s_loopEnd =>
        if DATA_RDATA = x"00" then
          pc_inc <= '1';
          next_state <= s_fetch;
        else
          cnt_set <= '1';
          pc_dec <= '1';
          next_state <= s_loopEnd_next;
        end if;

      when s_loopEnd_wait =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= ptr_reg;
        next_state <= s_loopEnd;

      when s_loop_next =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= pc_reg;   
        if DATA_RDATA = x"5B" then
          cnt_inc <= '1';
          pc_inc <= '1';
          next_state <= s_loop_start_waiting;
        elsif DATA_RDATA = x"5D" then
          if cnt_reg = x"01" then
            pc_inc <='1';
            next_state <= s_fetch;
          else
            cnt_dec <= '1';
            pc_inc <= '1';
            next_state <= s_loop_start_waiting;
          end if;
        else
          pc_inc <='1';
          next_state <= s_loop_start_waiting;
        end if;
      
        when s_loop_start_waiting =>
          DATA_EN <= '1';
          DATA_RDWR <= '1';
          DATA_ADDR <= pc_reg; 
          next_state <= s_loop_next; 


      when s_loopStart_wait =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= ptr_reg;
        next_state <= s_loopStart;
      
      when s_loopStart=>
        pc_inc <= '1';
        if DATA_RDATA = x"00" then
          cnt_set <= '1';
          next_state <= s_loop_next;
        else
          next_state <= s_fetch;
        end if;

      when s_numbers_letters_wait =>  
        DATA_EN <= '1';        
        DATA_RDWR <= '1';        
        DATA_ADDR <= ptr_reg;  
        next_state <= s_numbers_letters;

      when s_numbers_letters =>
        DATA_EN <= '1';
        DATA_RDWR <= '0';
        DATA_ADDR <= ptr_reg;
        DATA_WDATA <= tmp_reg;
        pc_inc <= '1';
        next_state <= s_fetch;

      when s_wait_read =>
      IN_REQ <= '1';
      next_state <=s_read;

      when s_read =>
      IN_REQ <= '1';
      if IN_VLD = '1' then
        DATA_EN <= '1';
        DATA_RDWR <= '0';
        DATA_ADDR <= ptr_reg;
        DATA_WDATA <= IN_DATA;
        pc_inc <= '1';
        next_state <= s_fetch;
      else
        next_state <= s_read;
      end if;


      when s_print_wait =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= ptr_reg; 
        next_state <=s_print_wait; 
        if  OUT_BUSY = '0'  then
          next_state <=s_print;
        end if;
        
      when s_print =>
      DATA_EN <= '1';  
      DATA_RDWR <= '1';
      DATA_ADDR <= ptr_reg;  
      OUT_DATA <= DATA_RDATA;  
      OUT_WE <= '1';
      pc_inc <= '1';  
      next_state <= s_fetch;

      when s_inc_read =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';           
        DATA_ADDR <= ptr_reg;
        next_state <=s_inc_write;

      when s_inc_write =>
        DATA_EN <= '1';
        DATA_RDWR <= '0';              
        DATA_ADDR <= ptr_reg;
        DATA_WDATA <= DATA_RDATA + 1;
        next_state <=s_fetch;

      when s_dec_read =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';           
        DATA_ADDR <= ptr_reg;
        next_state <=s_dec_write;

      when s_dec_write =>
        DATA_EN <= '1';
        DATA_RDWR <= '0';              
        DATA_ADDR <= ptr_reg;
        DATA_WDATA <= DATA_RDATA- 1;
        next_state <=s_fetch;

      when s_init =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= pc_reg;
        next_state <= s_init_wait;

      when s_init_wait =>
      DATA_EN <= '1';
      DATA_RDWR <= '1'; 
      DATA_ADDR <= pc_reg;
      if DATA_RDATA = x"40" then
        ptr_set <= '1';
        pc_reset <= '1';
        next_state <=s_fetch;
      else
        pc_inc <= '1';
        next_state <= s_init;
      end if;
          
      when s_fetch =>
        DATA_EN <= '1';
        DATA_RDWR <= '1';
        DATA_ADDR <= pc_reg;
        next_state <= s_decode;

      when s_decode =>
        if DATA_RDATA = x"40" then            -- @
          next_state <=sh;

        elsif DATA_RDATA = x"3E" then            -- >
          pc_inc <= '1';
          ptr_inc <= '1';
          next_state <=s_fetch;

        elsif DATA_RDATA = x"3C" then            -- <
          pc_inc <= '1';
          ptr_dec <= '1';
          next_state <=s_fetch;

        elsif DATA_RDATA = x"2B" then            -- +
          pc_inc <= '1';
          next_state <=s_inc_read;

        elsif DATA_RDATA = x"2D" then            -- -
          pc_inc <= '1';
          next_state <=s_dec_read;

        elsif DATA_RDATA = x"5B" then            -- [
          next_state <=s_loopStart_wait;

        elsif DATA_RDATA = x"5D" then            -- ]
          next_state <=s_loopEnd_wait;

        elsif DATA_RDATA = x"28" then            -- (
          next_state <=s_doStart_wait;

        elsif DATA_RDATA = x"29" then            -- )
          next_state <=s_doEnd_wait;

        elsif DATA_RDATA = x"2E" then            -- .
          next_state <=s_print_wait;

        elsif DATA_RDATA = x"2C" then            -- ,
          next_state <=s_wait_read;
        elsif (DATA_RDATA >= x"30" and DATA_RDATA <= x"39") or (DATA_RDATA >= x"41" and DATA_RDATA <= x"46") then     -- pismena a cisla
          next_state <= s_numbers_letters_wait;
        else
          pc_inc <= '1';  
          next_state <= s_fetch;
        end if;
      when sh =>
        next_state <= sh;

    end case;
end process;


process(present_state)
begin
    READY <= '0';
    DONE <= '0';

    if present_state /= s_init then
        READY <= '1';
    end if;
    
    if present_state = sh then
        DONE <= '1';
    end if;

end process;

end behavioral;

