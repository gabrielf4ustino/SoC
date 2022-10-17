library ieee;
use ieee.numeric_std.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memory is
end;

architecture mixed of tb_memory is
  signal CLOCK : std_logic;
  signal SW : std_logic_vector(15 downto 0) := (others => '1');
  signal LEDR : std_logic_vector(31 downto 0);
  signal data_w, data_r : std_logic;
begin
  tb_memory : entity work.memory(structural)
    port map(
      clock => CLOCK,
      data_write => data_w,
      data_read => data_r,
      data_addr => SW(15 downto 0),
      data_in => SW(7 downto 0),
      data_out => LEDR);
  process is
    variable resultado : std_logic_vector(31 downto 0) := (others => '1');
  begin
    CLOCK <= '1', '0' after 1 ns, '1' after 2 ns, '0' after 3 ns;
    data_w <= '1', '0' after 2 ns;
    data_r <= '0', '1' after 2 ns;

    wait for 10 ns;
    assert LEDR = resultado
    report "Erro!"
      severity failure;
  end process;
end architecture;