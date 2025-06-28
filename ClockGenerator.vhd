----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:00:55 11/26/2023 
-- Design Name: 
-- Module Name:    ClockGenerator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClockGenerator is
    Port ( Clk : in  STD_LOGIC;
           DAC_Clk : out  STD_LOGIC);
end ClockGenerator;

architecture Behavioral of ClockGenerator is

	-- Temp Clock
	signal tempClock : std_logic := '0';
	-- Clock Count
	signal count : integer := 0;
	
begin
	process (clk)
	begin
		if (clk'Event and clk = '1') then
			 tempClock <= NOT tempClock;
			if (count  = 307200) then
				tempClock <= NOT tempClock;
				DAC_Clk <= tempClock;
				count <= 0;
			else
				count <= count + 1;
			end if;
			DAC_Clk <= tempClock;
		end if;
	end process;
end Behavioral;

