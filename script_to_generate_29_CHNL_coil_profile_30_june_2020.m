% generate the coil array trace to perform the calculation of active
% shimming

% Author: Zhihua Ren
% Date: 28th June 2020
% Affiliation: Columbia University
% E-mail: zr2216@columbia.edu

close all, clc, clear all

% diameter of the cylinder with rectangle coils distributed 
D = 254e-3 + 4e-3*2;
% there will be 7 rectangle coils on the cylindrical surface
% the face coil will occupy two small coils' space
% number of rectangle coils each row 
% however, in row 1
N_rec = 7;
% the percentage of overlap for inductive decoupling 
p_overlap = 0.14;
% the angle of each coil 
angle_step = 2*pi/(N_rec+1);
% height of each coil 
H_rec = D/2/2*(1+p_overlap);

% offset of z for dome coil
z_offset = -D/4;
% number of elements 
gridnumber = 40;

x_offset = 0.283/2; % unit: m
y_offset = 0.03; % unit:m


%% for rectangle coil array on the cylindrical surface
angle_space = 0;

% for row 1: 7 coils 
% index of rows on cylindrical surface
i = 1;

for j = 1 : N_rec
    if j == 1
        angle = 2*angle_step;
    else
        angle = angle_step;
    end
    
    % line 1
    if j ==1
        theta_list1 = linspace(-angle/(1-p_overlap/2)/2+angle_space, angle/(1-p_overlap/2)/2+angle_space, gridnumber);
    else
        theta_list1 = linspace(-angle/(1-p_overlap)/2+angle_space, angle/(1-p_overlap)/2+angle_space, gridnumber);
    end
    
    R1 = D/2*ones(1,length(theta_list1));
    Z1 = 0*ones(1,length(theta_list1));
    [X1,Y1,Z1] = pol2cart(theta_list1,R1,Z1);
    Z1 = Z1;
    
    % line 2
    if j == 1
        Z2 = linspace(0,-D/2,gridnumber);
    else
        Z2 = linspace(0,-H_rec,gridnumber);
    end
    
    if j==1
        theta_list2 = (angle/(1-p_overlap/2)/2+angle_space)*ones(1,length(Z2));
    else
        theta_list2 = (angle/(1-p_overlap)/2+angle_space)*ones(1,length(Z2));
    end
    R2 = D/2*ones(1,length(Z2));
    [X2,Y2,Z2] = pol2cart(theta_list2,R2,Z2);
    Z2 = Z2;
    
    % line 3
    if j==1
        theta_list3 = linspace(angle/(1-p_overlap/2)/2+angle_space, -angle/(1-p_overlap/2)/2+angle_space, gridnumber);
    else
        theta_list3 = linspace(angle/(1-p_overlap)/2+angle_space, -angle/(1-p_overlap)/2+angle_space, gridnumber);
    end
    R3 = D/2*ones(1,length(theta_list3));
    if j == 1
        Z3 = -D/2*ones(1,length(theta_list3));
    else
        Z3 = -H_rec*ones(1,length(theta_list3));
    end
    
    [X3,Y3,Z3] = pol2cart(theta_list3,R3,Z3);
    Z3 = Z3;
    
    % line 4
    if j == 1
        Z4 = linspace(-D/2,0,gridnumber);
    else
        Z4 = linspace(-H_rec,0,gridnumber);
    end
    
    if j==1
        theta_list4 = (-angle/(1-p_overlap/2)/2+angle_space)*ones(1,length(Z4));
    else
        theta_list4 = (-angle/(1-p_overlap)/2+angle_space)*ones(1,length(Z4));
    end
    R4 = D/2*ones(1,length(Z4));
    [X4,Y4,Z4] = pol2cart(theta_list4,R4,Z4);
    Z4 = Z4;
    
    % remember to remove firt point when add four lines together 
    X_1 = [X1(1:end-1) X2(1:end-1) X3(1:end-1) X4(1:end)];
    Y_1 = [Y1(1:end-1) Y2(1:end-1) Y3(1:end-1) Y4(1:end)];
    Z_1 = [Z1(1:end-1) Z2(1:end-1) Z3(1:end-1) Z4(1:end)];
    trace1 = [X_1; Y_1; Z_1];
    trace2 = [-X_1+x_offset; Y_1+y_offset; Z_1];
    ch29_coil_array_sub_FOV1.rec_coil(i,j).trace = trace1;
    ch29_coil_array_sub_FOV2.rec_coil(i,j).trace = trace2;
    
    if j ==1
        angle_space = angle_space + 2*pi/(N_rec+1)*3/2;
    else
        angle_space = angle_space + 2*pi/(N_rec+1);
    end
    
    
end

% for row 2, move row 1 along z-axis with -H_rec offset
for i = 2:2
    for j = 1: N_rec-1
        ch29_coil_array_sub_FOV1.rec_coil(i,j).trace = ch29_coil_array_sub_FOV1.rec_coil(i-1,j+1).trace;
        ch29_coil_array_sub_FOV1.rec_coil(i,j).trace(3,:) = ch29_coil_array_sub_FOV1.rec_coil(i,j).trace(3,:) - (D/2-H_rec);
        ch29_coil_array_sub_FOV2.rec_coil(i,j).trace = ch29_coil_array_sub_FOV2.rec_coil(i-1,j+1).trace;
        ch29_coil_array_sub_FOV2.rec_coil(i,j).trace(3,:) = ch29_coil_array_sub_FOV2.rec_coil(i,j).trace(3,:) - (D/2-H_rec);
    end
end



%% modelling of 8*2 trapezoidal coils on the dome
N_tra = 8;
angle_step = 2*pi/N_tra;
angle_width = angle_step/(1-p_overlap);
coil_angle = angle_step/2;

% start and end angle for trapezoidal coils
% for row 1 
theta_start = pi/2-pi/5;
theta_end = pi/6;
i = 1;

for j = 1:N_tra
%     if i == 1 || i == N_tra
%         theta_end = pi/6;
%     else
%         theta_end = 0;
%     end
    
    % line 1
    PHI = linspace(-angle_width/2 + coil_angle,angle_width/2 + coil_angle,gridnumber);  % Azimuthal/Longitude/Circumferential
    THETA = theta_start*ones(1,length(PHI));  % Altitude /Latitude /Elevation
    R = D/2*ones(1,length(PHI));
    [X1,Y1,Z1] = sph2cart(PHI,THETA,R);
    
    % line 2 
    THETA = linspace(theta_start,theta_end,gridnumber);
    PHI = (angle_width/2 + coil_angle)*ones(1,length(THETA));
    R = D/2*ones(1,length(PHI));
    [X2,Y2,Z2] = sph2cart(PHI,THETA,R);
    
    
    % line 4 
    PHI = linspace(angle_width/2 + coil_angle,-angle_width/2 + coil_angle,gridnumber);  % Azimuthal/Longitude/Circumferential
    THETA = theta_end*ones(1,length(PHI)); 
    R = D/2*ones(1,length(PHI));
    [X3,Y3,Z3] = sph2cart(PHI,THETA,R);
    
       
    % line 5
    THETA = linspace(theta_end,theta_start,gridnumber);
    PHI = (-angle_width/2 + coil_angle)*ones(1,length(THETA));
    R = D/2*ones(1,length(PHI));
    [X4,Y4,Z4] = sph2cart(PHI,THETA,R);
    

    % remember to remove firt point when add four lines together 
    X_1 = [X1(1:end-1) X2(1:end-1) X3(1:end-1) X4(1:end)];
    Y_1 = [Y1(1:end-1) Y2(1:end-1) Y3(1:end-1) Y4(1:end)];
    Z_1 = [Z1(1:end-1) Z2(1:end-1) Z3(1:end-1) Z4(1:end)];
    
    
    trace1 = [X_1; Y_1; Z_1];
    trace2 = [-X_1+x_offset; Y_1+y_offset; Z_1];
    ch29_coil_array_sub_FOV1.tra_coil(i,j).trace = trace1;
    ch29_coil_array_sub_FOV2.tra_coil(i,j).trace = trace2;
    
    coil_angle = coil_angle + angle_step;
end


% for row 2 
i = 2;
theta_start = pi/5;
theta_end = 0;

for j = 1:N_tra
%     if i == 1 || i == N_tra
%         theta_end = pi/6;
%     else
%         theta_end = 0;
%     end
    
    % line 1
    PHI = linspace(-angle_width/2 + coil_angle,angle_width/2 + coil_angle,gridnumber);  % Azimuthal/Longitude/Circumferential
    THETA = theta_start*ones(1,length(PHI));  % Altitude /Latitude /Elevation
    R = D/2*ones(1,length(PHI));
    [X1,Y1,Z1] = sph2cart(PHI,THETA,R);
    
    % line 2 
    THETA = linspace(theta_start,theta_end,gridnumber);
    PHI = (angle_width/2 + coil_angle)*ones(1,length(THETA));
    R = D/2*ones(1,length(PHI));
    [X2,Y2,Z2] = sph2cart(PHI,THETA,R);
    
    % line 3
    Z = linspace(0,-D/2*p_overlap,gridnumber/5);
    PHI = (angle_width/2 + coil_angle)*ones(1,length(Z));
    R = D/2*ones(1,length(PHI));
    [X3,Y3,Z3] = pol2cart(PHI,R,Z);
    
    % line 4 
    PHI = linspace(angle_width/2 + coil_angle,-angle_width/2 + coil_angle,gridnumber);  % Azimuthal/Longitude/Circumferential
    Z = -D/2*p_overlap*ones(1,length(PHI));
    R = D/2*ones(1,length(PHI));
    [X4,Y4,Z4] = pol2cart(PHI,R,Z);
    
    % line 5
    Z = linspace(-D/2*p_overlap,0,gridnumber/5);
    PHI = (-angle_width/2 + coil_angle)*ones(1,length(Z));
    R = D/2*ones(1,length(PHI));
    [X5,Y5,Z5] = pol2cart(PHI,R,Z);
    
    
    % line 5
    THETA = linspace(theta_end,theta_start,gridnumber);
    PHI = (-angle_width/2 + coil_angle)*ones(1,length(THETA));
    R = D/2*ones(1,length(PHI));
    [X6,Y6,Z6] = sph2cart(PHI,THETA,R);
    

    % remember to remove firt point when add four lines together 
    X_1 = [X1(1:end-1) X2(1:end-1) X3(1:end-1) X4(1:end-1) X5(1:end-1) X6(1:end)];
    Y_1 = [Y1(1:end-1) Y2(1:end-1) Y3(1:end-1) Y4(1:end-1) Y5(1:end-1) Y6(1:end)];
    Z_1 = [Z1(1:end-1) Z2(1:end-1) Z3(1:end-1) Z4(1:end-1) Z5(1:end-1) Z6(1:end)];
    
    trace1 = [X_1; Y_1; Z_1];
    trace2 = [-X_1+x_offset; Y_1+y_offset; Z_1];
    ch29_coil_array_sub_FOV1.tra_coil(i,j).trace = trace1;
    ch29_coil_array_sub_FOV2.tra_coil(i,j).trace = trace2;
%     coil_array.tra_coil(i).trace = trace;
    
    coil_angle = coil_angle + angle_step;
end


figure()
% index of the coil  7+6 = 13 
for i = 1:2
    if i == 1
        N = N_rec;
    else
        N = N_rec - 1;
    end
    
    for j = 1:N
        
        plot3(ch29_coil_array_sub_FOV1.rec_coil(i,j).trace(1,:),ch29_coil_array_sub_FOV1.rec_coil(i,j).trace(2,:),ch29_coil_array_sub_FOV1.rec_coil(i,j).trace(3,:),'.-','Linewidth',2)
        hold on
%         plot3(ch29_coil_array_sub_FOV2.rec_coil(i,j).trace(1,:),ch29_coil_array_sub_FOV2.rec_coil(i,j).trace(2,:),ch29_coil_array_sub_FOV2.rec_coil(i,j).trace(3,:),'.-','Linewidth',2)
        grid on
    end
end

% 8+8 = 16
for i = 1:2
    for j = 1:N_tra
        plot3(ch29_coil_array_sub_FOV1.tra_coil(i,j).trace(1,:),ch29_coil_array_sub_FOV1.tra_coil(i,j).trace(2,:),ch29_coil_array_sub_FOV1.tra_coil(i,j).trace(3,:),'.-','Linewidth',2)
        hold on
%         plot3(ch29_coil_array_sub_FOV2.tra_coil(i,j).trace(1,:),ch29_coil_array_sub_FOV2.tra_coil(i,j).trace(2,:),ch29_coil_array_sub_FOV2.tra_coil(i,j).trace(3,:),'.-','Linewidth',2)
        grid on
    end
end
xlabel('x(m)')
ylabel('y(m)')
title('Geometry of 29ch Shim Coil Array')
setupmyfig()



% index of the coil 
figure()
coil_index = 0;
% for i = 2:2
%     if i == 1
%         N = N_rec;
%     else
%         N = N_rec - 1;
%     end
%     
%     for j = 1:N
%         coil_index = coil_index + 1;
%         
%         plot3(ch29_coil_array_sub_FOV1.rec_coil(i,j).trace(1,:),ch29_coil_array_sub_FOV1.rec_coil(i,j).trace(2,:),ch29_coil_array_sub_FOV1.rec_coil(i,j).trace(3,:),'.-','Linewidth',2)
%         hold on
% %         plot3(ch29_coil_array_sub_FOV2.rec_coil(i,j).trace(1,:),ch29_coil_array_sub_FOV2.rec_coil(i,j).trace(2,:),ch29_coil_array_sub_FOV2.rec_coil(i,j).trace(3,:),'.-','Linewidth',2)
%         grid on
%         xlabel('x(m)')
%         ylabel('y(m)')
%         xlim([-0.3 0.3]);
%         ylim([-0.15+0.03 0.15+0.03]);
%         zlim([-0.15 0.15]);
%         title({['Row. ',num2str(4)]});
%         setupmyfig()
%     end
% end

for i = 2:2
    for j = 1:N_tra
        coil_index = coil_index + 1;
%         figure()
        plot3(ch29_coil_array_sub_FOV1.tra_coil(i,j).trace(1,:),ch29_coil_array_sub_FOV1.tra_coil(i,j).trace(2,:),ch29_coil_array_sub_FOV1.tra_coil(i,j).trace(3,:),'.-','Linewidth',2)
        hold on
%         plot3(ch29_coil_array_sub_FOV2.tra_coil(i,j).trace(1,:),ch29_coil_array_sub_FOV2.tra_coil(i,j).trace(2,:),ch29_coil_array_sub_FOV2.tra_coil(i,j).trace(3,:),'.-','Linewidth',2)
        grid on
        xlabel('x(m)')
        ylabel('y(m)')
        xlim([-0.3 0.3]);
        ylim([-0.15+0.03 0.15+0.03]);
        zlim([-0.15 0.15]);
        title({['Row. ',num2str(2)]});
        setupmyfig()
    end
end








function setupmyfig()
 set(gcf,'color',[1 1 1]);
 set(gca,'DataAspectRatio', [1 1 1]);
%  set(gcf,'Position', [25,700,1650,500]);
 set(gca, 'FontName', 'Arial')
 set(gca, 'FontSize', 14)
 grid on
end



