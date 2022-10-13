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
  signal data_aux0, data_aux1, data_aux2, data_aux3 : std_logic_vector(addr_width - 1 downto 0);
  signal integer0, integer1, integer2, integer3 : integer;
begin
  
  integer0 <= to_integer(unsigned(data_addr));
  integer1 <= to_integer(unsigned(data_addr)) + 1;
  integer2 <= to_integer(unsigned(data_addr)) + 2;
  integer3 <= to_integer(unsigned(data_addr)) + 3;
  
  data_aux0 <= std_logic_vector(to_unsigned(integer0, data_width));
  data_aux1 <= std_logic_vector(to_unsigned(integer1, data_width));
  data_aux2 <= std_logic_vector(to_unsigned(integer2, data_width));
  data_aux3 <= std_logic_vector(to_unsigned(integer3, data_width));

  data_out((data_width*4) - 1 downto (data_width*3)) <= data_aux3;
  data_out((data_width*3) - 1 downto (data_width*2)) <= data_aux2;
  data_out((data_width*2) - 1 downto (data_width)) <= data_aux1;
  data_out(data_width - 1 downto 0) <= data_aux0;


end architecture;