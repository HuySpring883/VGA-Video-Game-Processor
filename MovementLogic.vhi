
-- VHDL Instantiation Created from source file MovementLogic.vhd -- 20:32:05 11/26/2023
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT MovementLogic
	PORT(
		Clk : IN std_logic;
		SW0 : IN std_logic;
		SW1 : IN std_logic;          
		Player1YPosition : OUT std_logic;
		Player2YPosition : OUT std_logic;
		BallXPosition : OUT std_logic;
		BallYPosition : OUT std_logic
		);
	END COMPONENT;

	Inst_MovementLogic: MovementLogic PORT MAP(
		Clk => ,
		SW0 => ,
		SW1 => ,
		Player1YPosition => ,
		Player2YPosition => ,
		BallXPosition => ,
		BallYPosition => 
	);


