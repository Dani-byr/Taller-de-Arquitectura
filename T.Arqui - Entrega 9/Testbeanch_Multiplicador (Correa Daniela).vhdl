--ALUMNA: Correa Daniela
--N.LEGAJO: 02903/7

entity test_Multipler is end;
	
architecture Behavioral of test_Multipler is

	--Declaracion de componentes
	component Multiplier
		port(A, B: in Bit_Vector(3 downto 0); CLK, STB: in Bit; Result: out Bit_Vector(7 downto 0); Done: out Bit);
	end component; 
			
	--Declaracion de señales
    signal A, B: Bit_Vector(3 downto 0); 
	signal Result: Bit_Vector(7 downto 0);
	signal STB, Done, CLK: Bit;
	
	use work.Utils.all;
	
begin
	--Instanciacion del componente a testear 
	U1: Multiplier port map(A, B, CLK, STB, Result, Done);
	
	--Driver de las señales de test
	Clock(CLK, 8.62 ns, 8.62 ns);
	
	Stimulus: process		
	begin																																																																																																																																																																																																																																																																																																													                                
		A <= Convert(9, A'Length);
		B <= Convert(2, B'Length);
		wait until CLK'Event and CLK='1';
		STB <= '1', '0' after 17.24 ns;		
		wait;
	end process;
	
end;
