library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
  generic (
    addr_width : natural := 16; -- Memory Address Width (in bits)
    data_width : natural := 8 -- Data Width (in bits)
  );
  port (
    clock : in std_logic; -- Clock signal
    halt : in std_logic; -- Halt processor execution when '1'

    ---- Begin Memory Signals ---
    -- Instruction byte received from memory
    instruction_in : in std_logic_vector(data_width - 1 downto 0);
    -- Instruction address given to memory
    instruction_addr : out std_logic_vector(addr_width - 1 downto 0);

    mem_data_read : out std_logic; -- When '1', read data from memory
    mem_data_write : out std_logic; -- When '1', write data to memory
    -- Data address given to memory
    mem_data_addr : out std_logic_vector(addr_width - 1 downto 0);
    -- Data sent from memory when data_read = '1' and data_write = '0'
    mem_data_in : out std_logic_vector((data_width * 2) - 1 downto 0);
    -- Data sent to memory when data_read = '0' and data_write = '1'
    mem_data_out : in std_logic_vector((data_width * 4) - 1 downto 0);
    ---- End Memory Signals ---

    ---- Begin Codec Signals ---
    codec_interrupt : out std_logic; -- Interrupt signal
    codec_read : out std_logic; -- Read signal
    codec_write : out std_logic; -- Write signal
    codec_valid : in std_logic; -- Valid signal

    -- Byte written to codec
    codec_data_out : in std_logic_vector(7 downto 0);
    -- Byte read from codec
    codec_data_in : out std_logic_vector(7 downto 0)
    ---- End Codec Signals ---
  );
end entity;
architecture behavior of cpu is
  signal op : std_logic_vector(3 downto 0);
  signal ip, sp : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  
begin

  p1 : process variable data_operator : std_logic_vector(data_width - 1 downto 0);

  begin
    if rising_edge(clock) then
      instruction_addr <= ip;
      op <= instruction_in(data_width - 1 downto data_width/2);
      wait for 5 ns;
      case op is
        when "0000" =>
          wait until falling_edge(halt);
          ip <= (others => '0');
          sp <= (others => '0');

        when "0001" =>
          codec_read <= '1';
          codec_write <= '0';
          codec_interrupt <= '0';
          wait for 5 ns;
          codec_interrupt <= '1';
          wait until codec_valid'event;
          sp <= std_logic_vector(unsigned(sp) + 1);
          mem_data_addr <= sp;
          mem_data_write <= '1';
          mem_data_in <= std_logic_vector(to_unsigned(to_integer(unsigned(codec_data_out)), (data_width * 2)));
          mem_data_write <= '0';

        when "0010" =>
          mem_data_addr <= sp;
          mem_data_read <= '1';
          wait for 5 ns;
          mem_data_read <= '0';
          sp <= std_logic_vector(unsigned(sp) - 1);
          codec_read <= '0';
          codec_write <= '1';
          codec_data_in <= mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          codec_interrupt <= '0';
          wait for 5 ns;
          codec_interrupt <= '1';
          wait until codec_valid'event;

        when "0011" =>
          sp <= std_logic_vector(unsigned(sp) + 1);
          mem_data_write <= '1';
          mem_data_addr <= sp;
          mem_data_in <= std_logic_vector(to_unsigned(to_integer(unsigned(ip(addr_width - 1 downto addr_width/2))), (data_width * 2)));
          wait for 5 ns;
          sp <= std_logic_vector(unsigned(sp) + 1);
          mem_data_addr <= sp;
          mem_data_in <= std_logic_vector(to_unsigned(to_integer(unsigned(ip(addr_width/2 - 1 downto 0))), (data_width * 2)));
          wait for 5 ns;
          mem_data_write <= '0';

        when "0100" =>
          sp <= std_logic_vector(unsigned(sp) + 1);
          mem_data_write <= '1';
          mem_data_addr <= sp;
          mem_data_in <= std_logic_vector(to_unsigned(to_integer(unsigned(instruction_in(data_width/2 - 1 downto 0))), (data_width * 2)));
          wait for 5 ns;
          mem_data_write <= '0';

        when "0101" =>
          mem_data_write <= '1';
          mem_data_addr <= sp;
          mem_data_in <= std_logic_vector(to_unsigned(0, (data_width * 2)));
          wait for 5 ns;
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_write <= '0';

        when "0110" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          sp <= std_logic_vector(unsigned(sp) + 1);
          mem_data_write <= '1';
          mem_data_read <= '0';
          mem_data_in <= std_logic_vector(to_unsigned(to_integer(unsigned(mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8))), (data_width * 2)));
          wait for 5 ns;
          mem_data_write <= '0';

        when "1000" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          data_operator := mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_addr <= sp;
          wait for 5 ns;
          mem_data_in <= std_logic_vector(signed(mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8)) + signed(data_operator));
          mem_data_write <= '1';
          mem_data_read <= '0';
          wait for 5 ns;
          mem_data_write <= '0';

        when "1001" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          data_operator := mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_addr <= sp;
          wait for 5 ns;
          mem_data_in <= std_logic_vector(signed(data_operator) - signed(mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8)));
          mem_data_write <= '1';
          mem_data_read <= '0';
          wait for 5 ns;
          mem_data_write <= '0';

        when "1010" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          data_operator := mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_addr <= sp;
          wait for 5 ns;
          mem_data_in <= data_operator nand mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          mem_data_write <= '1';
          mem_data_read <= '0';
          wait for 5 ns;
          mem_data_write <= '0';

        when "1011" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          data_operator := mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_addr <= sp;
          wait for 5 ns;
          if signed(data_operator) < signed(mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8)) then
            mem_data_in <= std_logic_vector(to_unsigned(1, (data_width * 2)));
          else
            mem_data_in <= std_logic_vector(to_unsigned(0, (data_width * 2)));
          end if;
          mem_data_write <= '1';
          mem_data_read <= '0';
          wait for 5 ns;
          mem_data_write <= '0';

        when "1100" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          data_operator := mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_addr <= sp;
          wait for 5 ns;
          mem_data_in <= std_logic_vector(shift_left(signed(data_operator), to_integer(signed(mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8)))));
          mem_data_write <= '1';
          mem_data_read <= '0';
          wait for 5 ns;
          mem_data_write <= '0';

        when "1101" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          data_operator := mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_addr <= sp;
          wait for 5 ns;
          mem_data_in <= std_logic_vector(shift_right(signed(data_operator), to_integer(signed(mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8)))));
          mem_data_write <= '1';
          mem_data_read <= '0';
          wait for 5 ns;
          mem_data_write <= '0';

        when "1110" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          data_operator := mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8);
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_addr <= sp;
          wait for 5 ns;
          if signed(data_operator) = signed(mem_data_out(data_width * 4 - 1 downto data_width * 4 - 8)) then
            sp <= std_logic_vector(unsigned(sp) - 1);
            wait for 5 ns;
            ip <= std_logic_vector(signed(ip) + signed(mem_data_out(data_width * 4 - 1 downto data_width * 4/2)));
          end if;
          mem_data_read <= '0';

        when "1111" =>
          mem_data_read <= '1';
          mem_data_addr <= sp;
          wait for 5 ns;
          ip <= mem_data_out(data_width * 4 - 1 downto data_width * 4/2);
          sp <= std_logic_vector(unsigned(sp) - 1);
          mem_data_read <= '0';

        when others =>
          report "ERRO!";
      end case;
    end if;
  end process;
end architecture;