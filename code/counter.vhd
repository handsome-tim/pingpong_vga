library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity FSM is   --�p�Ƴ���
	port(rst,clr_a,clr_b,clk1	: in std_logic;
	         led_loc                     :in std_logic_vector(3 downto 0);		
	         prestate                   : out std_logic;
		 led_act  			: out std_logic_vector(2 downto 0);--led_act��led����ܰʧ@
		 score_a,score_b      : out std_logic_vector(3 downto 0));--score���C�q��ܾ��W���Ʀr
		 
end FSM;
architecture main of FSM is
type FSM2 is(sa,sb,ha,hb,j);--�w�qFSM2=>sa,sb���o�y�Aha,hb�����y�P�_�Aj���o���P�_
signal s,point_a,point_b,temp:std_logic_vector(3 downto 0);
signal z:std_logic_vector(4 downto 0);
--signal act : std_logic_vector(2 downto 0);
signal ps :std_logic;
signal hit:FSM2;
begin
process(rst,clk1,clr_a,clr_b,hit,led_loc)
begin
if rst = '0' then
	if clk1 = '1' and clk1 'event then
		case hit is
			when sa  => z <= "00001";
			             ps	<= '0';
					    if clr_a = '1' then--a�o�y  
					        ps	<= '1';
					        led_act	<= "001";
					        hit <= hb;                                                                	                           
					    elsif clr_a = '0' then hit <= sa;
					    end if;
			when sb  => ps	<= '1';    
						if clr_b = '1' then --b�o�y 
							ps	<= '0'; 
							led_act	<= "000";                                                       	                                                             	                               
							hit <= ha;                                                               
						elsif clr_b = '0' then hit <= sb;
						end if;
			when ha  => case clr_a is 
							when '1' => if led_loc = "0111" then--���T�^��
											led_act  <= "011";
											hit <= hb;
										else --���~�^��
											led_act 		<= "100";
											point_b <= point_b +1 ;
											hit 	<= j; 
										end if;
							when '0' => case led_loc is    	                                               
											when "0111" =>     --�S������y
												point_b <= point_b +1 ;
												led_act 		<= "100";                                                 
												hit  	<= j;
											when others =>hit <= ha;
										end case;
							when others =>hit <= ha;
						end case;
			when hb  => case clr_b is 
							when '1' => if led_loc = "0000" then--���T�^��
											led_act  <= "010";
											hit <= ha;
										else --���~�^��
											led_act 		<= "100";
											point_a <= point_a +1;
											hit 	<= j; 
										end if;
							when '0' => case led_loc is 
											when "0000" =>
												point_a <= point_a +1;
												led_act 		<= "100";                                                
												hit  	<= j;
											when others =>hit <= hb;
										end case;                                                    
							when others =>hit	<= hb;                                 
						end case;                                                         
			when j   =>case ps is 
							when '0' 	=> hit	<= sa;    	                                       
							when '1' 	=> hit	<= sb;
							when others => NULL;
						end case;
		end case;
	end if;
else
    z <="00000";
	hit 	<= sa;
	ps 		<= '0';       
	point_a <= (others => '0');--�k��
	point_b <= (others => '0');--����
end if;
end process;
prestate    <= ps;
score_a 	<= point_a;
score_b 	<= point_b;
end main;