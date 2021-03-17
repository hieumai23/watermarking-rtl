----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2021 01:23:11 PM
-- Design Name: 
-- Module Name: reg_file_8b - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


--64 rows
entity reg_file_8b is
port(
    w_addr: in std_logic_vector(5 downto 0);
    w_data: in std_logic_vector (7 downto 0);
    rw_en: in std_logic_vector (1 downto 0);
    r_addr: in std_logic_vector(5 downto 0);
    r_data: out std_logic_vector(7 downto 0);
    clk: in std_logic
);
end reg_file_8b;

architecture Behavioral of reg_file_8b is

component mem_row_8b
port(
    w_data: in std_logic_vector (7 downto 0);
    rw_en: in std_logic_vector (1 downto 0);
    clk: in std_logic;
    q: out std_logic_vector (7 downto 0)
);
end component;

component decoder_6_to_64 is
Port ( sel6 : in STD_LOGIC_VECTOR (5 downto 0);
y : out STD_LOGIC_VECTOR (63 downto 0));
end component;

type RW_DEC is array (0 to 63) of std_logic_vector(1 downto 0);

signal w_addr_decode: std_logic_vector(63 downto 0);
signal r_addr_decode: std_logic_vector(63 downto 0);
signal sel: RW_DEC;

begin

r_decoder: decoder_6_to_64 port map (sel6 => r_addr, y => r_addr_decode);
w_decoder: decoder_6_to_64 port map (sel6 => w_addr, y => w_addr_decode);

GEN_ROW: 
for i in 0 to 63 generate
    row_x: mem_row_8b port map(w_data => w_data, rw_en => sel(i), clk => clk, q => r_data);
end generate GEN_ROW;


process(clk)
begin

if clk'event and clk = '1' then
    case rw_en is
        when "01" => --read
            for j in 0 to 63 loop
                sel(j) <= (0 => r_addr_decode(j) and rw_en(0), 1 => r_addr_decode(j) and rw_en(1));
            end loop;
        when "10" => --write
            for j in 0 to 63 loop
                sel(j) <= (0 => w_addr_decode(j) and rw_en(0), 1 => w_addr_decode(j) and rw_en(1));
            end loop;
        when others =>
            for j in 0 to 63 loop
                sel(j) <= "00";
            end loop;
    end case;
end if;

end process;

end Behavioral;
