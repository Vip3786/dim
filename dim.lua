fadein=function()
S=(L)-(C)
if (S)<0 then K=(S)*-1 else K=(S) end
if (K)==0 then K=(K)+1 else K=(K) end
D=(F)/(K)
if (D)==0 then D=(D)+1 else D=(D) end
tmr.alarm(1,(D),1,function()
if C<L then C=(C+1) pwm.setduty(N,C)
elseif C>L then C=(C-1) pwm.setduty(N,C)
elseif C==L then tmr.stop(1) end
end)end
start_init=function() 
file.open("data.dat","r")
fr=file.readline()
L=tonumber(fr)F=tonumber(fr)r=tonumber(fr)g=tonumber(fr)b=tonumber(fr)
T=L
O=F
file.close()
pwm.setup(1,1,0)pwm.setup(5,1,0)pwm.setup(7,1,0)pwm.setup(2,1,0)pwm.start(1)pwm.start(5)pwm.start(7)pwm.start(2)
C=001
S=0
K=0
D=0
N=1
fadein()
wifi.setmode(wifi.STATION);
wifi.sta.config("HomeWifi","n46f78z2p0");
end
responseHeader = function(code,type)
return "HTTP/1.1 "..code.."\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\nContent-Type: "..type.."\r\n\r\n";
end
httpserver=function()
start_init();
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
conn:on("receive",function(conn,request)
conn:send(responseHeader("200 OK","application/json"));
local _, _, method,path,vars=string.find(request,"([A-Z]+) (.+)?(.+) HTTP");
if(method==nil)then
_, _,method,path=string.find(request,"([A-Z]+) (.+) HTTP");
end
local _G={}
if (vars~=nil)then
for k,v in string.gmatch(vars,"(%w+)=(%w+)&*") do
_G[k]=v
end
end
if (_G.cmd=="sets") then
file.remove("data.dat")
file.open("data.dat","w")
T=_G.target
O=_G.fadetime
r=_G.r
g=_G.g
b=_G.b
file.writeline(T)file.writeline(O)file.writeline(r)file.writeline(g)file.writeline(b)file.close()
end
if (_G.cmd=="setd") then
if _G.p then N=tonumber(_G.p) else N=1 end
L=tonumber(_G.target)
F=tonumber(_G.fadetime)
fadein()
end
if (_G.cmd=="getd") then
if _G.p then N=tonumber(_G.p) else N=1 end
conn:send('{"payload":"'..tostring(pwm.getduty(N))..'","fadetime":"'..O..'"}');
end
if (_G.cmd=="gets") then
conn:send('{"target":"'..T..'","fadetime":"'..O..'"}');
end
end)
conn:on("sent",function(conn)  
conn:close();
conn=nil;
collectgarbage();
end)
end)
end
httpserver()
