library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity video_out is
 generic (
   video_h   : integer := 800 ;
   video_v   : integer := 600 
  );
 port(
  clk           : in std_logic;
  divclk        : in std_logic;
  reset         : in std_logic;
  prestate      : in std_logic;
  act  		    : in std_logic_vector(2 downto 0);
 ------------vga---------------------------------
  Rout            : out std_logic_vector(3 downto 0); --
  Gout            : out std_logic_vector(3 downto 0); --
  Bout            : out std_logic_vector(3 downto 0); -- 
  hsync           : out std_logic;
  vsync           : out std_logic
 );
end video_out;

architecture yanxi of video_out is

signal count: integer:=1;           --全域變數，整數int，初始值1
signal tmp:   integer:=25;          --全域變數
signal x:     integer:=0;

 component vga        
 generic (
        horizontal_resolution : integer := 800 ;--解析度
        horizontal_Front_porch: integer :=  56 ;
        horizontal_Sync_pulse : integer := 120 ;
        horizontal_Back_porch : integer :=  64 ;
        h_sync_Polarity         :std_logic:= '1' ;
        vertical_resolution   : integer := 600 ;--解析度
        vertical_Front_porch  : integer :=  37 ;
        vertical_Sync_pulse   : integer :=   6 ;
        vertical_Back_porch   : integer :=  23 ;
        v_sync_Polarity         :std_logic:= '1' 
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        video_start_en : in std_logic;
        vga_hs_cnt : out integer;
        vga_vs_cnt : out integer;
        hsync : out std_logic;
        vsync : out std_logic
    );
 end component;
 signal vga_vs_cnt   : integer ;
 signal vga_hs_cnt   : integer ;
 signal center       : integer ;
 signal CLK50MHz   : std_logic;
 signal rst : std_logic;
 
begin
 rst <= not reset;
 
 vga_1 :vga  
 port map( 
  clk             => CLK50MHz, --
  rst          => rst,
  video_start_en  => '1',
  vga_hs_cnt      => vga_hs_cnt,
  vga_vs_cnt   => vga_vs_cnt,
  hsync    => hsync,
  vsync    => vsync
 );
 
 ------------------------------vga out 狀態機動作-------------------------
 process(rst,divclk,act)
begin
if reset = '0' then
	if rising_edge(divclk) then 
		case act is
			when "000"  =>--左移
			 if center >= 50 then
			     center <= center - 100;
			 end if;
			when "001"  =>--右移
		      if center <= 750 then
			     center <= center + 100;
			 end if;                             
			when "010" =>--右回擊              
			 if center >= 750 then
			     center <= 650;
			 elsif center >= 50 then
			     center <= center - 100;
			 end if;                  
			when "011" =>--左回擊
			 if center <= 50 then
			     center <= 150;
			 elsif center <= 750 then
			     center <= center + 100;
			 end if;                                  
			when "100"  =>
			 if prestate = '1' then
			     center <= 750;
			 else
			     center <= 50;
			end if;
			when others  => NULL;
		end case;
	end if;
else        
	center <= 50;
end if;
end process;
 
 process(rst, CLK50MHz, vga_hs_cnt, vga_vs_cnt)
 begin
  if (reset = '1') then
   Rout <= (others=>'0');
   Gout <= (others=>'0');
   Bout <= (others=>'0');
  elsif rising_edge(CLK50MHz) then
  if (vga_hs_cnt < video_h  and vga_vs_cnt < video_v ) then
   if ((vga_hs_cnt-center)*(vga_hs_cnt-center)+(vga_vs_cnt-300)*(vga_vs_cnt-300)) < 2500 then          --h > x       v > y       中400，300   半徑50
     Rout <= (others=>'0');
     Gout <= (others=>'1');
     Bout <= (others=>'0');
    else
     Rout <= (others=>'0');
     Gout <= (others=>'0');
     Bout <= (others=>'0');
    end if;
                  
   else
    Rout <= (others=>'0');
    Gout <= (others=>'0');
    Bout <= (others=>'0');
   end if; 
  end if;
 end process;


 ----------------------------------------------------------- 除頻電路(50MHz)
 process(clk,rst)
 begin
  if (reset = '1') then
   CLK50MHz <= '0';
  elsif (clk'event and clk = '1') then
   CLK50MHz<= not CLK50MHz;
  end if;  
  
 end process; 
 

end architecture;