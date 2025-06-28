----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:12:15 11/26/2023 
-- Design Name: 
-- Module Name:    SynchronizationCalculator - Behavioral 
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

entity SynchronizationCalculator is
    Port ( Clk : in  STD_LOGIC;
				SW3 : in STD_LOGIC;
			  Cl_Hcount : out INTEGER;
			  CL_Vcount : out INTEGER;
           H : out  STD_LOGIC;
           V : out  STD_LOGIC);
end SynchronizationCalculator;

architecture Behavioral of SynchronizationCalculator is

	-- Signals
	signal Hcount : integer := 0;
	signal Vcount : integer := 0;
	
	-- VGA Specifications
	constant H_FrontPorch : integer := 16;
	constant H_Row : integer := 800;
	constant H_ActiveImageArea : integer := 639;
	constant H_SyncPulse : integer := 96;
	constant V_FrontPorch : integer := 10;
	constant V_Column : integer := 525;
	constant V_ActiveImageArea : integer := 479;
	constant V_SyncPulse : integer := 2;

begin

	process(Clk)
	begin
		if (clk'event and clk = '1') then
			-- Pixel location calculation
			if (Hcount < H_Row - 1) then
				Hcount <= Hcount + 1;
				CL_Hcount <= Hcount;
			else
				Hcount <= 0;
				CL_Hcount <= Hcount;
				if (Vcount < V_Column - 1) then
					Vcount <= Vcount + 1;
					CL_Vcount <= Vcount;
				else
					Vcount <= 0;
					CL_Vcount <= Vcount;
				end if;
			end if;
			-- HSync
			if ((Hcount < H_ActiveImageArea + H_FrontPorch) or (Hcount >= H_ActiveImageArea + H_FrontPorch + H_SyncPulse)) then
				H <= '1';
			else
				H <= '0';
			end if;
			-- Vsync
			if ((Vcount < V_ActiveImageArea + V_FrontPorch) or (Vcount >= V_ActiveImageArea + V_FrontPorch + V_SyncPulse)) then
				V <= '1';
			else
				V <= '0';
			end if;
		end if;
	end process;

end Behavioral;

