%This script processes the output from UTESpac and plots the time-series
%data
close all
clc

rootFolder = info.rootFolder;
outputStruct = getData_Derek(rootFolder);

%% plots
time = datetime(datevec(outputStruct.H(:,1)));

% sensible heat flux
figure;
plot(time,outputStruct.H(:,4))
ylabel('Sensible heat flux')
xlabel('Time')
grid on

%temperature from Sonic20Hz
figure;
plot(time,outputStruct.Sonic20Hz(:,5),time,outputStruct.Sonic20Hz(:,10),time,outputStruct.Sonic20Hz(:,15))
ylabel('Temperature')
xlabel('Time')
legend('Lower Sonic','Mid Sonic','Upper Sonic')
grid on

%derived T
figure;
plot(time,outputStruct.Sonic20Hz(:,5),time,outputStruct.Sonic20Hz(:,10),time,outputStruct.Sonic20Hz(:,15))
ylabel('Temperature')
xlabel('Time')
legend('Lower Sonic','Mid Sonic','Upper Sonic')
grid on

%humidity

%wind speed time series
figure;
plot(time,outputStruct.spdAndDir(:,3),time,outputStruct.spdAndDir(:,6),time,outputStruct.spdAndDir(:,9))
ylabel('Wind Speed [m/s]')
xlabel('Time')
legend('Lower Sonic','Mid Sonic','Upper Sonic')
grid on

%wind direction time series
figure;
scatter(time,outputStruct.spdAndDir(:,2),'.')
hold on
scatter(time,outputStruct.spdAndDir(:,5),'.')
scatter(time,outputStruct.spdAndDir(:,8),'.')
ylabel('Wind Direction')
xlabel('Time')
legend('Lower Sonic','Mid Sonic','Upper Sonic')
grid on

%wind speed vs direction
figure;
scatter(outputStruct.spdAndDir(:,2),outputStruct.spdAndDir(:,3),'.')
hold on
scatter(outputStruct.spdAndDir(:,5),outputStruct.spdAndDir(:,6),'.')
scatter(outputStruct.spdAndDir(:,8),outputStruct.spdAndDir(:,9),'.')
title('Wind Speed vs Wind Direction')
ylabel('Wind Speed')
xlabel('Wind Direction')
legend('Lower Sonic','Mid Sonic','Upper Sonic')
grid on

%wind speed vs direction COMPASS
% 0 degrees = NORTH
figure;
polarscatter(outputStruct.spdAndDir(:,2),outputStruct.spdAndDir(:,3),'.')
hold on
polarscatter(outputStruct.spdAndDir(:,5),outputStruct.spdAndDir(:,6),'.')
polarscatter(outputStruct.spdAndDir(:,8),outputStruct.spdAndDir(:,9),'.')
title('Wind Speed vs Wind Direction')
% ylabel('Wind Speed')
% xlabel('Wind Direction')
legend('Lower Sonic','Mid Sonic','Upper Sonic')
grid on

%rotated sonic
figure;
plot(time,outputStruct.rotatedSonic(:,1),time,outputStruct.rotatedSonic(:,4),time,outputStruct.rotatedSonic(:,7))
title('u wind speed')
ylabel('Wind Speed [m/s]')
xlabel('Time')
legend('Lower Sonic','Mid Sonic','Upper Sonic')
grid on

%radiation
figure;
plot(time,outputStruct.rotatedSonic(:,1),time,outputStruct.rotatedSonic(:,4),time,outputStruct.rotatedSonic(:,7))
title('u wind speed')
ylabel('Wind Speed [m/s]')
xlabel('Time')
legend('Lower Sonic','Mid Sonic','Upper Sonic')
grid on

%TKE