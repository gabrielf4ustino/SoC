library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity soc is
generic (
    firmware_filename: string := "firmware.bin"
);
port (
    clock: in std_logic; -- Clock signal
    started: in std_logic -- Start execution when '1'
);
end entity;

architecture structural of soc is
    signal halt: std_logic := '1';
    signal codec_interrupt, codec_read, codec_write, codec_valid, instruction_read, instruction_write, mem_data_read, mem_data_write: std_logic := '0';
    signal instruction_in, mem_data_out: std_logic_vector((8*4)-1 downto 0) := (others => '0');
    signal instruction_addr, mem_data_addr: std_logic_vector(16-1 downto 0) := (others => '0');
    signal mem_data_in, instruction_out : std_logic_vector((8*2)-1 downto 0) := (others => '0');
    signal codec_data_out, codec_data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal instruction_addr_opcode_1, instruction_addr_opcode_2: std_logic_vector(15 downto 0) := (others => '0');


    begin
    
    start: process is
    file file_readed : text open read_mode is firmware_filename;
    variable line_readed: line;
    variable instruction: bit_vector(7 downto 0);
    variable zeros: bit_vector(7 downto 0) := (others => '0');

    begin
        if started = '0' and not endfile(file_readed) then
            halt <= '1';
            instruction_read <= '0';
            instruction_write <= '1';
            readline(file_readed,line_readed);
            read(line_readed,instruction);
            wait for 5 ns;
            instruction_out <= std_logic_vector(unsigned(to_stdlogicvector(instruction & zeros)));
            wait for 5 ns;
            instruction_write <= '0';
            if not endfile(file_readed) then
                instruction_addr_opcode_1 <= std_logic_vector(unsigned(instruction_addr_opcode_1) + 1);
            end if;
        elsif started = '1' and endfile(file_readed) then
            halt <= '1';
            instruction_read <= '1';
            instruction_write <= '0';
            if instruction_addr_opcode_1 /= instruction_addr_opcode_2 then
                halt <= '0';
            end if;
            wait for 5 ns;
        end if;
        wait until falling_edge(clock);
    end process;
    
    mux_instruction_addr: entity work.mux(behavioral)
        generic map(16)
        port map(instruction_addr_opcode_1, instruction_addr_opcode_2, started, instruction_addr);
    
    cpu: entity work.cpu(behavior)
        generic map(16, 8)
        port map(clock, halt, instruction_in((8*4)-1 downto (8*4)-8),  instruction_addr_opcode_2, mem_data_read,  mem_data_write,  mem_data_addr,
            mem_data_in,  mem_data_out,  codec_interrupt,  codec_read,codec_write, codec_valid,  codec_data_out, codec_data_in);

    data_memory: entity work.memory(behavior)
        generic map(16, 8)
        port map(clock, mem_data_read, mem_data_write, mem_data_addr, mem_data_in, mem_data_out);
        
    instruction_memory: entity work.memory(behavior)
        generic map(16, 8)
        port map(clock, instruction_read, instruction_write, instruction_addr, instruction_out, instruction_in);

    codec: entity work.codec(behavior)
        port map(codec_interrupt, codec_read, codec_write, codec_valid, codec_data_in, codec_data_out);


end architecture;