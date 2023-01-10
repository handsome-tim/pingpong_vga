library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity my_div1 is
port(rst,clk_in,mode1,mode2        : in std_logic;
     clk_out1 : out std_logic);
end my_div1;
architecture arch1 of my_div1 is
    signal cnt2        :std_logic;
    signal divisor1    :integer;
    signal cnt1        :integer:=0;
begin
    process(rst,mode1,mode2)
    begin
    if rst = '0' then
        if (mode1 = '1' and mode2 = '1') then
            divisor1 <= 10000000;
        elsif (mode1 = '1' and mode2 = '0') then
            divisor1 <= 20000000;
        else
            divisor1 <= 35000000;
        end if;
    else
        divisor1 <= 35000000;
    end if;
    end process;
    
    process(rst,clk_in,cnt2)
    begin
    if rst = '0' then
        if(clk_in'event and clk_in='1') then
            if cnt1 < divisor1 then
                cnt1  <= cnt1 + 1;
            else
                cnt1 <= 1; 
            end if;
            if((cnt1 = divisor1 / 2) or (cnt1 = divisor1)) then 
                cnt2 <= not cnt2;
            end if;
        end if;
    else 
        cnt2 <= '0';
    end if;
    end process;
    clk_out1 <= cnt2;
    end arch1;