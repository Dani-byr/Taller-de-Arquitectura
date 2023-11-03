--ALUMNA: Correa Daniela
--N.LEGAJO: 02903/7

entity Multiplier is 
	port (A, B: in Bit_Vector(3 downto 0); CLK, STB: in Bit; Result: out Bit_Vector(7 downto 0); Done: out Bit);		
end;


-- Se elige una arquitectura estructural porque se interconectaran componentes ya creados 
architecture structural of Multiplier is
	-- Declaro el Adder
	component Adder8
		port(A, B: in Bit_Vector(7 downto 0); Cin: in Bit; Cout: out Bit; Sum: out  Bit_Vector(7 downto 0));
	end component;
	
	-- Declaro un registro para instaciar A y B
	component ShiftN
		port(CLK: in Bit; CLR: in Bit; LD: in Bit; SH: in Bit; DIR: in Bit; D: in Bit_Vector; Q: out Bit_Vector);
	end component; 

    --Declaro un LATCH para instanciar ACC
    component Latch8 is
   		port (D: in Bit_Vector(7 downto 0); Clk: in Bit; Pre: in Bit; Clr: in Bit; Q: out Bit_Vector(7 downto 0));
	end component;
	
	-- Declaro el Controller
	component Controller
		port(STB, CLK, LSB, Stop: in  Bit; Init, Shift, Add, Done: out  Bit);
	end component;
	
	-- Declaro la compuerta nor
	component compuerta_nor8
		port(A: in Bit_Vector(7 downto 0); Res: out Bit); 
	end component;
	
	
	-- Declaro las señales                            
	signal Stop, Init, Shift, Add, Cout: Bit;
	signal NotCLK : Bit;
	signal Estable: Bit;
	signal NotInit: Bit;
	signal Q_A, Q_B, Q_ACC: Bit_Vector(7 downto 0); 
	signal SumP, Res: Bit_Vector(7 downto 0);

    -- Señales:
	-- - Q_A: salida del shifter A y entrada del nor
	-- - Q_B: salida del shifter B  y una de las entradas al Adder8
	-- - SumP: Salida del Adder8 y entrada al registro ACC
	-- - Q_ACC: salida del registro ACC y entrada al registro resultado 
	-- - Estable: señal que indica cuando los FF se estabilizan
	
	
    -- - Stop: Entrada de la FSM, resultado de la compuerta nor
    -- - Init: salida de la FSM y señal de entrada LOAD para los shifter A y B, y de Clr para el registro ACC  
	-- - Shift: salida de la FSM y señal de entrada SH para los shifter A y B
	-- - Add: salida de la FSM y señal de entrada Pre para el registro ACC 

														
begin
	NotCLK <= not CLK;
	Estable <= '0', '1' after 2 ns;
	NotInit <= Estable and not Init;
	
	RegA: ShiftN port map(CLK=>CLK,CLR=>'0', LD=>Init, SH=>Shift,DIR=>'0', D=>A, Q=>Q_A);
	RegB: ShiftN port map(CLK=>CLK,CLR=>'0', LD=>Init, SH=>Shift,DIR=>'1', D=>B, Q=>Q_B);
	Adder: Adder8 port map(A=>Q_ACC, B=>Q_B, Cin=>'0', Cout=>Cout, Sum=>SumP);		 
	RegACC: Latch8 port map(D=>SumP, CLK=>Add, Pre=>'1', Clr=>NotInit, Q=>Q_ACC);
	FSM: Controller port map(STB=>STB, CLK=>NotCLK, LSB=>Q_A(0), Stop=>Stop, Init=>Init, Shift=>Shift, Add=>Add, Done=>Done);   
	compNOR: compuerta_nor8 port map(A=>Q_A, Res=>Stop);
	
	Asignacion_Final: 
	block (Stop = '1' and CLK'event and Clk = '1')
	begin
		Result <= guarded Q_ACC;
	end block Asignacion_Final;
		
end;
