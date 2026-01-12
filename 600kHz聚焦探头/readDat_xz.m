  clear all;clc;
% read xy plane
    filename = 'x0.25_20z0.25_40.dat';
    fid=fopen(filename,'r');
    Data=fread(fid,'int16');
    fclose(fid);

    %% basic parameters
%     TransCoe        =       0.610;              % transform coef @1MHz， needle hydrophone
%  TransCoe        =       0.518;              % transform coef @3.5MHz， needle hydrophone; 
%  TransCoe        =       0.552;% transform coef @3.5MHz， needle hydrophone
 TransCoe        =       3.235;              % transform coef @600kHz， needle hydrophone; 
   
    gain            =        0.000171075;        % hydrophone gain
    interval        =     10000 ;              % the number of point of single acquisition

    times_x         =      20;                 % x-axis move points
    times_y         =       40;                % y-axis move points
     max_cnt        = times_x * times_y;
    compensate      =       1150;             % 实际数据总长度/实际总记录次数 - interval
    N5=find(Data==interval);
    N7=find(Data==1)+2;
    N8=find(Data==0)+1;
    N9=intersect(N7,N5);
    N10=intersect(N9,N8);
    N6=32.59;
    %% caculate pressure
    
    
    for k=1:times_x

        N4=0;
        N3=6000;
        if mod(k,2)==1
            for  b=1:times_y
            j=((k-1)*times_y + b);
        N1=round(N10(j)+compensate+N6*(j-(floor(j/times_y)*times_y)));    %选取脉冲的左端点
        N2=round(N1+N3); 

        temp = sort(Data(N1:N2));
        a1 = mean(sum(temp((N3-10):end)));
        b1 = mean(sum(temp(1:10)));
        
        vpp(j) = (a1-b1)/2;

        pressure(j).vpp = vpp(j);       % 水听器接收的信号，不是真实的电压
        pressure(j).vpp = vpp(j)*gain;       % 实际上vpp*gain是真正的电压
        pressure(j).data = pressure(j).vpp/TransCoe;    %声压结果，单位为MPa

        yhy(j) =  pressure(j).data;
                    end
       else
            for  b=1:times_y
            j=((k-1)*times_y + b);
        N1=round(N10(j)+compensate+N6*((ceil(j/times_y)*times_y)-j));    %选取脉冲的左端点
        N2=round(N1+N3); 

        temp = sort(Data(N1:N2));
        a1 = mean(sum(temp((N3-10):end)));
        b1 = mean(sum(temp(1:10)));
        
        vpp(j) = (a1-b1)/2;

        pressure(j).vpp = vpp(j);       % 水听器接收的信号，不是真实的电压
        pressure(j).vpp = vpp(j)*gain;       % 实际上vpp*gain是真正的电压
        pressure(j).data = pressure(j).vpp/TransCoe;    %声压结果，单位为MPa

        yhy(j) =  pressure(j).data;     
        
    end
         end
    end
%     
% ((ceil(j/times_y)*times_y)-j+(floor(j/times_y)*times_y))

    res = zeros(times_y, times_x);
    for i = 1:times_y
        for j = 1 :times_x
             if mod(j,2)==1
            res(i,j) = yhy((j-1)*times_y + i);
             else
                 res(i,j) = yhy(j*times_y - i);
             end
        end
    end

    step_x = 0.25;   % 对应电动三维控制程序中的步长
    step_y = 0.25;
    display_x = (1:times_x)*step_x;
    display_y = (1:times_y)*step_y;
    
    figure
    imagesc(res);title('XZ plane acoustic pressure @foucs range');
    axis image;ylabel('y-axis / mm'); xlabel('x-axis / mm');colorbar;

