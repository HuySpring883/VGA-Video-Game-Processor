
-- VHDL Instantiation Created from source file ClockGenerator.vhd -- 18:07:49 11/26/2023
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT ClockGenerator
	PORT(
		Clk : IN std_logic;          
		DAC_Clk : OUT std_logic
		);
	END COMPONENT;

	Inst_ClockGenerator: ClockGenerator PORT MAP(
		Clk => ,
		DAC_Clk => 
	);


