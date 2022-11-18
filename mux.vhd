library ieee;
use ieee.std_logic_1164.all;

entity mux is
  generic (
    N : natural := 4
  );
  port (
    one, two : in std_logic_vector(N - 1 downto 0);
    option : in std_logic;
    output : out std_logic_vector(N - 1 downto 0)
  );
end entity;

architecture behavioral of mux is
begin

  output <= one when option = '0' else two;

end architecture;