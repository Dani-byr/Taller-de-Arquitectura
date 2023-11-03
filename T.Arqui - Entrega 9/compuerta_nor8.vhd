entity compuerta_nor8 is 
	port(A: in Bit_Vector(7 downto 0); Res: out Bit);
end compuerta_nor8;


architecture dataFlow of compuerta_nor8 is
begin
	Res <= not(A(7) or A(6) or A(5) or A(4) or A(3) or A(2) or A(1) or A(0));
end dataFlow;