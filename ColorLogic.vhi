
-- VHDL Instantiation Created from source file ColorLogic.vhd -- 18:34:54 11/26/2023
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT ColorLogic
	PORT(
		Hcount : IN std_logic;
		Vcount : IN std_logic;
		BallXPosition : IN std_logic;
		BallYPosition : IN std_logic;
		Player1YPosition : IN std_logic;
		Player2YPosition : IN std_logic;          
		Rout : OUT std_logic_vector(7 downto 0);
		Gout : OUT std_logic_vector(7 downto 0);
		Bout : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	Inst_ColorLogic: ColorLogic PORT MAP(
		Hcount => ,
		Vcount => ,
		BallXPosition => ,
		BallYPosition => ,
		Player1YPosition => ,
		Player2YPosition => ,
		Rout => ,
		Gout => ,
		Bout => 
	);


