----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:34:54 11/26/2023 
-- Design Name: 
-- Module Name:    MovementLogic - Behavioral 
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

entity MovementLogic is
    Port ( Clk : in  STD_LOGIC;
           SW0 : in  STD_LOGIC;
           SW1 : in  STD_LOGIC;
           Player1YPosition : out  integer;
           Player2YPosition : out  integer;
           BallXPosition : out  integer;
           BallYPosition : out  integer);
end MovementLogic;

architecture Behavioral of MovementLogic is
	
	-- VGA Specifications
	constant H_ActiveImageArea : integer := 640;
	constant V_ActiveImageArea : integer := 480;

	-- Movement Specifications
	signal toBallXPosition : integer := 310;
	signal toBallYPosition : integer := 230;
	signal toPlayer1YPosition : integer := 360;
	signal toPlayer2YPosition : integer := 60;
	signal Player1XPosition : integer := 50;
	signal Player2XPosition : integer := 580;
	
	-- Border Specifications
	constant BorderTopOffset : integer := 20;
	constant BorderSideOffset : integer := 40;
	
	-- Ball Specifications
	constant BallWidth : integer := 10;
	
	-- Paddle Specifications
	constant PaddleHeight : integer := 80;

begin
	process(Clk, SW0, SW1)
	begin
		if (clk'event and clk = '1') then
			-- Paddle 1 Movement
			if (SW0 = '0') then
				if (toPlayer1YPosition < 360) then
					toPlayer1YPosition <= toPlayer1YPosition + 1;
					Player1YPosition <= toPlayer1YPosition;
				else
					toPlayer1YPosition <= 360;
					Player1YPosition <= toPlayer1YPosition;
				end if;
			else
				if (toPlayer1YPosition > BorderSideOffset) then
					toPlayer1YPosition <= toPlayer1YPosition - 1;
					Player1YPosition <= toPlayer1YPosition;
				else
					toPlayer1YPosition <= BorderSideOffset;
					Player1YPosition <= toPlayer1YPosition;
				end if;
			end if;
			-- Paddle 2 Movement
			if (SW1 = '0') then
				if (toPlayer2YPosition < 360) then
					toPlayer1YPosition <= toPlayer1YPosition + 1;
					Player1YPosition <= toPlayer1YPosition;
				else
					toPlayer1YPosition <= 360;
					Player1YPosition <= toPlayer1YPosition;
				end if;
			else
				if (toPlayer2YPosition > BorderSideOffset) then
					toPlayer1YPosition <= toPlayer1YPosition - 1;
					Player1YPosition <= toPlayer1YPosition;
				else
					toPlayer1YPosition <= BorderSideOffset;
					Player1YPosition <= toPlayer1YPosition;
				end if;
			end if;
			-- Ball Collision Movement
			if (toBallXPosition >= Player1XPosition and toBallXPosition < Player1XPosition + BallWidth) then
				-- Ball Collision Paddle/Player 1
				if (((toBallYPosition >= toPlayer1YPosition) or (toBallYPosition + BallWidth >= toPlayer1YPosition)) and ((toBallYPosition < toPlayer1YPosition + PaddleHeight) or (toBallYPosition + BallWidth < toPlayer1YPosition + PaddleHeight))) then
					-- X Direction
					toBallXPosition <= toBallXPosition + 1;
					BallXposition <= toBallXPosition;
				end if;
			elsif (toBallXPosition = BorderSideOffset) then
				-- Ball Collision Left Border
				if ((toBallYPosition >= BorderSideOffset and toBallYPosition < 160) or (toBallYPosition + BallWidth >= 360 and toBallYPosition + BallWidth < V_ActiveImageArea)) then
					-- X Direction
					toBallXPosition <= toBallXPosition + 1;
					BallXPosition <= toBallXPosition;
				end if;
			elsif (((toBallXPosition + BallWidth) >= Player2XPosition) and ((toBallXPosition + BallWidth) < Player2XPosition + BallWidth)) then	
				-- Ball Collision Paddle/Player 2
				if ((toBallYPosition >= toPlayer2YPosition or toBallYPosition + BallWidth >= toPlayer2YPosition) and (toBallYPosition < toPlayer2YPosition + PaddleHeight or toBallYPosition + BallWidth < toPlayer2YPosition + PaddleHeight)) then
					-- X Direction
					toBallXPosition <= toBallXPosition - 1;
					BallXPosition <= toBallXPosition;
				end if;
			elsif (toBallXPosition + BallWidth = H_ActiveImageArea) then
				-- Ball Collision Right Border
				if ((toBallYPosition >= BorderSideOffset and toBallYPosition < 160) or (toBallYPosition + BallWidth >= 360 and toBallYPosition + BallWidth < V_ActiveImageArea - BorderSideOffset)) then
					-- X Direction
					toBallXPosition <= toBallXPosition - 1;
					BallXPosition <= toBallXPosition;
				end if;
			else
				toBallXPosition <= 300;
				toBallYPosition <= 220;
				BallXPosition <= toBallXPosition;
				BallYPosition <= toBallYPosition;
			end if;
			
			-- Y Direction
			if (toBallYPosition - 1 <= BorderSideOffset) then
				toBallYPosition <= toBallYPosition - 1;
				BallYPosition <= toBallYPosition;
			elsif (toBallYPosition + BallWidth + 1 >= V_ActiveImageArea - BorderSideOffset) then
				toBallYPosition <= toBallYPosition + 1;
				BallYPosition <= toBallYPosition;
			end if;
		end if;
	end process;
end Behavioral;

