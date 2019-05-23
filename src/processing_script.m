%  the script to process the data, use [runMe...] to define the parameters
%  author : P.J.Zhang
%  date : 2018-5-2 19:40:39

%% prepare data

% read data from data file
[T_ste,T_wind,F_ste,F_wind,freq_ste,freq_wind,S_ste_A,S_wind,S_ste_B] = ...
    read_data_wind_stereo(fname_stereo,fname_wind);

%% process the data using the parameters defined
% convert the time format from daycount to minute start from 0
T_ste_m  = (T_ste-t1)*24*60;
T_wind_m = (T_wind-t1)*24*60;

% cut out the matrix to savetime
T_ste_small   = T_ste_m(:,T_ste(1,:)>t1 & T_ste(1,:)<t2);
T_wind_small  = T_wind_m(:,T_ste(1,:)>t1 & T_ste(1,:)<t2);
F_ste_small   = F_ste(:,T_ste(1,:)>t1 & T_ste(1,:)<t2);
F_wind_small  = F_wind(:,T_ste(1,:)>t1 & T_ste(1,:)<t2);
S_ste_A_small = S_ste_A(:,T_ste(1,:)>t1 & T_ste(1,:)<t2);
S_wind_small  = S_wind(:,T_ste(1,:)>t1 & T_ste(1,:)<t2);
S_ste_B_small = S_ste_B(:,T_ste(1,:)>t1 & T_ste(1,:)<t2);

% plot the signal of the spectrometer
% draw_stereo_wind_selected ...
%     (T_ste_small,T_wind_small,F_ste_small,F_wind_small,...
%     S_ste_A_small,S_ste_B_small,S_wind_small,time_range,clim_ste,clim_wind)
     
% get arrival time of the time
[f_res_steA,t_res_steA] = get_arrival_time(T_ste_small,F_ste_small,S_ste_A_small,...
    upper_limit_stereo_A, lower_limit_stereo_A,f_step_STA,t_step,thresh_ste_A);
[f_res_WIND,t_res_WIND] = get_arrival_time(T_wind_small,F_wind_small,S_wind_small,...
    upper_limit_wind,     lower_limit_wind,f_step_WIND,t_step,thresh_wind);
[f_res_steB,t_res_steB] = get_arrival_time(T_ste_small,F_ste_small,S_ste_B_small,...
    upper_limit_stereo_B, lower_limit_stereo_B,f_step_STB,t_step,thresh_ste_B);

%% run the pso for t0 theta0 vs
%t0,theta0,vs
op_func_pso = @(xinp)(func_dt2_pso(f_res_steA,f_res_steB,f_res_WIND,...
    t_res_steA, t_res_steB, t_res_WIND,...
    xinp(1),xinp(2),xinp(3),v_sw,angel_A,angel_B,...
    r_ste_A_AU,r_WIND_AU,r_ste_B_AU));

nvars = 3;
duration = (t2-t1)*24*3600;
ub=[ duration , 2*pi , 3e5  ];
lb=[-600       ,  0   ,   0 ];
tic;
options = optimoptions('particleswarm','SwarmSize',280,...
    'HybridFcn',@fmincon,...
    'Display','iter',...
    'MaxStallIterations',12,...
    'UseParallel',true);

% if we have the x already in pso.mat we can skip these two lines 
[x,fval,exitflag] = particleswarm(op_func_pso,nvars,lb,ub,options);
save('pso20080129.mat','x')

load('pso20080129.mat')

toc
disp(['start time : ',num2str(x(1))])
disp(['angle : ',num2str(x(2)*180/pi)])
disp(['source velocity : ',num2str(x(3)/3e5)])

draw_result_parker_signal(x,v_sw,r_ste_A_AU,r_WIND_AU,r_ste_B_AU,angel_A,angel_B,...
    f_res_steA,t_res_steA,f_res_WIND,t_res_WIND,f_res_steB,t_res_steB,...
    T_ste_small,T_wind_small,F_ste_small,F_wind_small,...
    S_ste_A_small,S_ste_B_small,S_wind_small,time_range,clim_ste,clim_wind,fname_output)
 

