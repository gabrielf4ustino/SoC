library ieee;
use ieee.numeric_std.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memory is
  generic (
    ADDR_WIDTH : integer := 2;
    DATA_WIDTH : integer := 3
  );

  port (
    CLOCK_50 : in std_logic;
    SW : in std_logic_vector(16 downto 0);
    LEDR : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end;

architecture mixed of tb_memory is
begin
  tb_memory : entity work.memory(dataflow)
    port map(
      clock => CLOCK_50,
      data_write => SW(16),
      data_read => SW(16),
      data_addr => SW(15 downto 14),
      data_in => SW(2 downto 0),
      data_out => LEDR);
end architecture;