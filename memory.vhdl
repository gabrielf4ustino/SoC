library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
  generic (
    addr_width : natural := 16; -- Memory Address Width (in bits)
    data_width : natural := 8 -- Data Width (in bits)
  );
  port (
    clock : in std_logic; -- Clock signal; Write on Falling-Edge

    data_read : in std_logic; -- When '1', read data from memory
    data_write : in std_logic; -- When '1', write data to memory
    -- Data address given to memory
    data_addr : in std_logic_vector(addr_width - 1 downto 0);
    -- Data sent from memory when data_read = '1' and data_write = '0'
    data_in : in std_logic_vector(data_width - 1 downto 0);
    -- Data sent to memory when data_read = '0' and data_write = '1'
    data_out : out std_logic_vector((data_width * 4) - 1 downto 0)
  );
end entity;
architecture dataflow of memory is
  type ram_type is array ((integer'(2) ** addr_width) - 1 downto 0) of std_logic_vector (data_width - 1 downto 0);
  signal ram_single_port : ram_type;
begin
  process (clock)
  begin
    if (clock'event and clock = '1') then
      if (data_write = '1') then
        ram_single_port(to_integer(unsigned(data_addr))) <= data_in;
      end if;
      if (data_read = '1') then
        data_out <= ram_single_port(to_integer(unsigned(data_addr)));
      end if;
    end if;
  end process;
end architecture;