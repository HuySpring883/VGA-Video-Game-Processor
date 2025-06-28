----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:57:32 11/26/2023 
-- Design Name: 
-- Module Name:    VideoGameProcessor - Behavioral 
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

entity VideoGameProcessor is
    Port ( 
			  -- Inputs
			  clk : in  STD_LOGIC;
			  SW0 : in  STD_LOGIC;
           SW1 : in  STD_LOGIC;
           SW2 : in  STD_LOGIC;
           SW3 : in  STD_LOGIC;
			  
			  -- Outputs
			  H : out  STD_LOGIC;
           V : out  STD_LOGIC;
           DAC_CLK : out  STD_LOGIC;
           Rout : out  STD_LOGIC_VECTOR (7 downto 0);
           Gout : out  STD_LOGIC_VECTOR (7 downto 0);
           Bout : out  STD_LOGIC_VECTOR (7 downto 0));
end VideoGameProcessor;

architecture Behavioral of VideoGameProcessor is
	
	-- Clock Generator Component
	COMPONENT ClockGenerator
	PORT(
		Clk : IN std_logic;          
		DAC_Clk : OUT std_logic
		);
	END COMPONENT;
	
	-- Hsync and Vsync Component
	COMPONENT SynchronizationCalculator
	PORT(
		Clk : IN std_logic;
		CL_Hcount : out integer;
		Cl_Vcount : out integer;
		H : OUT std_logic;
		V : OUT std_logic
		);
	END COMPONENT;
	
	-- Color Logic Component
	COMPONENT ColorLogic
	PORT(
		Hcount : IN integer;
		Vcount : IN integer;
		BallXPosition : IN integer;
		BallYPosition : IN integer;
		Player1YPosition : IN integer;
		Player2YPosition : IN integer;          
		toRout : OUT std_logic_vector(7 downto 0);
		toGout : OUT std_logic_vector(7 downto 0);
		toBout : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	-- Movement Logic Component
	COMPONENT MovementLogic
	PORT(
		Clk : IN std_logic;
		SW0 : IN std_logic;
		SW1 : IN std_logic;          
		Player1YPosition : OUT integer;
		Player2YPosition : OUT integer;
		BallXPosition : OUT integer;
		BallYPosition : OUT integer
		);
	END COMPONENT;
	
	-- Internal Signals
	signal toDAC_CLK : std_logic := '0';
	signal toHcount : integer;
	signal toVcount : integer;
	signal toBallXPosition : integer;
	signal toBallYPosition : integer;
	signal toPlayer1YPosition : integer;
	signal toPlayer2YPosition : integer;  
	
	-- Test Color Logic Signals
	signal testRout : std_logic_vector(7 downto 0) := (others => '0');
	signal testBout : std_logic_vector(7 downto 0) := (others => '1');
	signal testGout : std_logic_vector(7 downto 0) := (others => '0');

begin

	-- Clock Generator Instantiation
	sys_ClockGenerator: ClockGenerator PORT MAP(
		Clk => clk,
		DAC_Clk => toDAC_CLK
	);
	
	-- Hsync and Vsync Instantiation
	sys_SynchronizationCalculator: SynchronizationCalculator PORT MAP(
		Clk => toDAC_CLK,
		CL_Hcount => toHcount,
		CL_Vcount => toVcount,
		H => H,
		V => V
	);
	
	-- Color Logic Instantiation
	sys_ColorLogic: ColorLogic PORT MAP(
		Hcount => toHcount,
		Vcount => toVcount,
		BallXPosition => toBallXPosition,
		BallYPosition => toBallYPosition,
		Player1YPosition => toPlayer1YPosition,
		Player2YPosition => toPlayer2YPosition,
		toRout => Rout,
		toGout => Gout,
		toBout => Bout
	);
	
	-- Movement Logic Instantiation
	sys_MovementLogic: MovementLogic PORT MAP(
		Clk => toDAC_CLK,
		SW0 => SW0,
		SW1 => SW1,
		Player1YPosition => toPlayer1YPosition,
		Player2YPosition => toPlayer2YPosition,
		BallXPosition => toBallXPosition,
		BallYPosition => toBallYPosition
	);
	
	DAC_CLK <= toDAC_CLK;
	
end Behavioral;

