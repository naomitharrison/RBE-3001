%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  RBE 3001 - DYNAMIC TRACKING - TEAM 3  %%
%% Will dynamically track a single object %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization Statements
clear all
close all
clear
clear java
clear classes;
vid = hex2dec('3742');
pid = hex2dec('0007');
disp (vid );
disp (pid);
javaaddpath ../lib/SimplePacketComsJavaFat-0.6.4.jar;
import edu.wpi.SimplePacketComs.*;
import edu.wpi.SimplePacketComs.device.*;
import edu.wpi.SimplePacketComs.phy.*;
import java.util.*;
import org.hid4java.*;
version -java
myHIDSimplePacketComs=HIDfactory.get();
myHIDSimplePacketComs.setPid(pid);
myHIDSimplePacketComs.setVid(vid);
myHIDSimplePacketComs.connect();
pp = PacketProcessor(myHIDSimplePacketComs);
addpath('Kinematics','Kinematics/Inverse','Kinematics/Differential','Kinematics/Forward','CameraCalibration','Trajectory','ObjectDetection','Plotting','Other');

%% Cam Configuration
cam = webcam();
cParams = camCal();

checkToOrigin= [-1 ,  0 ,  0  , 275.8;
    0 ,  1 ,  0  ,  113.6;
    0 ,  0 ,  -1  ,     0;
    0 ,  0 ,  0  , 1];

camToCheck= [-0.0017 , -0.8032 ,   0.5957,  107.6207;
    0.9998  ,  0.0094  ,  0.0155 , 109.2884;
    -0.0180  ,  0.5956  ,  0.8031 , 277.1416;
    0 ,        0   ,      0,       1.0000];

%% While Loop
while 1
    % Take a Snapshot
    imgOrg = snapshot(cam);
    
    % Find the Object
    [imOutput, robotFramePose,  colorAndBase, colorsOut] = findObjs(imgOrg, checkToOrigin, camToCheck, cParams);
    
    % Send the Packets
    if size(robotFramePose,1)>0
        T = ikin([robotFramePose(1),robotFramePose(2), 50]);
        shoulderPos = T(1);
        wristPos = T(3);
        elbowPos=  T(2);
        packet = zeros(15, 1, 'single');
        packet(1) =shoulderPos*4096/(2*pi);
        packet(2) = elbowPos*4096/(2*pi);
        packet(3) = wristPos*4096/(2*pi);
        pp.write(01, packet);
    end
end