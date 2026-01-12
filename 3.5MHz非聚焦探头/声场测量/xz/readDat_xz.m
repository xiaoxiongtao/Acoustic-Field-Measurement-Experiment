  clear all;clc;
% read xy plane
    filename = 'x0.25_60z0.5_60_3.2-6.2cm.dat';
    fid=fopen(filename,'r');
    Data=fread(fid,'int16');
    fclose(fid);

    %% basic parameters
%     TransCoe        =       0.610;              % transform coef @1MHz， needle hydrophone
 TransCoe        =       0.518;              % transform coef @3.5MHz， needle hydrophone; 
%  TransCoe        =       0.552;% transform coef @3.5MHz， needle hydrophone
   
    gain            =        0.000017018;        % hydrophone gain
    interval        =      6000 ;              % the number of point of single acquisition

    times_x         =       60;                 % x-axis move points
    times_y         =       60;                % y-axis move points
     max_cnt        = times_x * times_y;
    compensate      =       2560;             % 实际数据总长度/实际总记录次数 - interval
    N5=find(Data==interval);
    N7=find(Data==1)+2;
    N8=find(Data==0)+1;
    N9=intersect(N7,N5);
    N10=intersect(N9,N8);
    N6=34.81;
    %% caculate pressure
  for j = 1:max_cnt
% for x=1:times_x
%     for y=1:times_y
        
        N4=0;
        N3=600;
%         N1=round(interval * (j-1) + compensate+1+N4);    %选取脉冲的左端点
%         N1=round(N10(j)+compensate);    %选取脉冲的左端点
%         N2=round(N1+N3); 
%         
        N1=round(N10(j)+compensate+N6*floor(j/times_y));    %选取脉冲的左端点
        N2=round(N1+N3); 

        temp = sort(Data(N1:N2));
        a1 = mean(sum(temp((N3-18):end)));
        b1 = mean(sum(temp(1:18)));
        
        vpp(j) = (a1-b1)/2;

        pressure(j).vpp = vpp(j);       % 水听器接收的信号，不是真实的电压
        pressure(j).vpp = vpp(j)*gain;       % 实际上vpp*gain是真正的电压
        pressure(j).data = pressure(j).vpp/TransCoe;    %声压结果，单位为MPa

        yhy(j) =  pressure(j).data;
    end

    res = zeros(times_y, times_x);
    for i = 1:times_y
        for j = 1 :times_x
            res(i,j) = yhy((i-1)*times_x + j);
        end
    end

    step_x = 0.25;   % 对应电动三维控制程序中的步长
    step_y = 0.5;
    display_x = (1:times_x)*step_x;
    display_y = (1:times_y)*step_y;
    
    figure
    imagesc(res);title('XZ plane acoustic pressure @foucs range');
    axis image;ylabel('y-axis / mm'); xlabel('x-axis / mm');colorbar;

