library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;

entity codec is
  port (
    interrupt : in std_logic; -- Interrupt signal
    read_signal : in std_logic; -- Read signal
    write_signal : in std_logic; -- Write signal
    valid : out std_logic; -- Valid signal

    -- Byte written to codec
    codec_data_in : in std_logic_vector(7 downto 0);
    -- Byte read from codec
    codec_data_out : out std_logic_vector(7 downto 0)
  );
end entity;
architecture structural of codec is
  signal signal_aux : std_logic_vector(7 downto 0);
begin
  process (interrupt)
  begin
    valid <= '0';
    if rising_edge(interrupt) then
      if read_signal = '0' and write_signal = '1' then
        signal_aux <= codec_data_in;
      end if;
      if read_signal = '1' and write_signal = '0' then
        codec_data_out <= signal_aux;
      end if;
      valid <= '1';
    end if;
  end process;
end architecture;