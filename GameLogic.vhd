----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:29:23 11/26/2023 
-- Design Name: 
-- Module Name:    ColorLogic - Behavioral 
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

entity ColorLogic is
    Port ( Hcount : in  integer;
           Vcount : in  integer;
           BallXPosition : in  integer;
           BallYPosition : in  integer;
           Player1YPosition : in  integer;
           Player2YPosition : in  integer;
           toRout : out  STD_LOGIC_VECTOR (7 downto 0);
           toGout : out  STD_LOGIC_VECTOR (7 downto 0);
           toBout : out  STD_LOGIC_VECTOR (7 downto 0));
end ColorLogic;

architecture Behavioral of ColorLogic is

	-- VGA Specifications
	constant H_FrontPorch : integer := 16;
	constant H_Row : integer := 800;
	constant H_ActiveImageArea : integer := 640;
	constant H_SyncPulse : integer := 96;
	constant V_FrontPorch : integer := 10;
	constant V_Column : integer := 525;
	constant V_ActiveImageArea : integer := 480;
	constant V_SyncPulse : integer := 2;
	
	-- Player Specifications
	constant Player1XPosition : integer := 50;
	constant Player2XPosition : integer := 580;
	constant PaddleWidth : integer := 10;
	constant PaddleHeight : integer := 80;
	
	-- Border Specifications
	constant BorderTopOffset : integer := 20;
	constant BorderSideOffset : integer := 40;
	constant BorderWidth : integer := 30;
	
	-- Ball Specifications
	constant BallWidth : integer := 10;
	
	-- Gate Specifications
	constant TopGateOffset : integer := 100;
	constant BottomGateOffset : integer := 380;

begin

--	-- Display Green
--	toRout <= (others => '0');
--	toGout <= (others => '1');
--	toBout <= (others => '0');

	process(Hcount, Vcount, BallXPosition, BallYPosition, Player1YPosition, Player2YPosition)
	begin
		if (Hcount >= BorderTopOffset and Hcount < H_ActiveImageArea - BorderTopOffset and Vcount >= BorderTopOffset and Vcount < V_ActiveImageArea - BorderTopOffset) then
			-- Field
			toRout <= (others => '0');
			toGout <= (others => '1');
			toBout <= (others => '0');
			-- Top and Bottom BorderBorder
			if (Vcount < BorderSideOffset or Vcount >= V_ActiveImageArea - BorderSideOffset) then
				-- Display white
--				toRout <= (others => '0');
--				toGout <= (others => '0');
--				toBout <= (others => '0');
			-- Left and Right Border
			elsif (((Hcount < BorderSideOffset or Hcount >= H_ActiveImageArea - BorderSideOffset)) and (Vcount < TopGateOffset or Vcount >= BottomGateOffset)) then
				-- Display White
--				Rout <= (others => '1');
--				Gout <= (others => '1');
--				Bout <= (others => '1');
			-- Ball
			elsif ((Hcount >= BallXPosition and Hcount < BallXPosition + BallWidth) and (Vcount >= BallYPosition and Vcount < BallYPosition + BallWidth)) then
				-- Display Yellow
--				Rout <= (others => '1');
--				Gout <= (others => '1');
--				Bout <= (others => '0');
			-- Player/Paddle 1
			elsif ((Hcount >= Player1XPosition and Hcount < Player1XPosition + BallWidth) and (Vcount >= Player1YPosition and Vcount < Player1YPosition + PaddleHeight)) then
				-- Display Blue
--				Rout <= (others => '0');
--				Gout <= (others => '0');
--				Bout <= (others => '1');
			-- Player/Paddle 2
			elsif ((Hcount >= Player2XPosition and Hcount < Player2XPosition + BallWidth) and (Vcount >= Player2YPosition and Vcount < Player2YPosition + PaddleHeight)) then
				-- Display Pink
--				Rout <= (others => '1');
--				Gout <= (others => '0');
--				Bout <= (others => '1');
			-- Center Dotted Line
			elsif (Vcount >= BorderSideOffset and Vcount < V_ActiveImageArea - BorderTopOffset and Hcount = BottomGateOffset) then
				-- Display Black
--				Rout <= (others => '0');
--				Gout <= (others => '0');
--				Bout <= (others => '0');
			else -- Background
				-- Display Green
--				Rout <= (others => '0');
--				Gout <= (others => '1');
--				Bout <= (others => '0');
			end if;
		-- Ball Color When Scored
		elsif ((Hcount >= BallXPosition and Hcount < BallXPosition + BallWidth) and (Vcount >= BallYPosition and Vcount < BallYPosition + BallWidth)) then
			-- Display Red
--			Rout <= (others => '1');
--			Gout <= (others => '0');
--			Bout <= (others => '0');
		end if;
	end process;

end Behavioral;

