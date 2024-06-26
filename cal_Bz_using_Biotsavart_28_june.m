% Bio-Savart Law to calculate the magnetic field generated by coil array
% author: Zhihua Ren
% date: 25 june 2020
% location: Columbia University
%% input
% coil_trace: the trace of all 15 coil
% current: it has size of 15, define all the current direction and
% amplitude parfor the coil array

%% output
% Bz: the magnetic field Bz generated by all current loops

function BZ = cal_Bz_using_Biotsavart_28_june(X,Y,Z,current,coil_trace)

mu0 = 4*pi*1e-7; % vacuum permeability [N/A^2]



% creat space to save magnetic fields
% BX = zeros(size(X,1),size(X,2),size(X,3));
% BY = zeros(size(X,1),size(X,2),size(X,3));
% BZ = zeros(size(X,1),size(X,2),size(X,3));


x_P = coil_trace(1,:);
y_P = coil_trace(2,:);
z_P = coil_trace(3,:);

% x_P_ = permute(reshape(repmat(x_P,size(X)),size(coil_trace,2),size(X,1),size(X,2),size(X,3)),[2,3,4,1]);
% y_P_ = permute(reshape(repmat(y_P,size(Y)),size(coil_trace,2),size(Y,1),size(Y,2),size(Y,3)),[2,3,4,1]);
% z_P_ = permute(reshape(repmat(z_P,size(Z)),size(coil_trace,2),size(Z,1),size(Z,2),size(Z,3)),[2,3,4,1]);
%
% PkM3 = (sqrt((X-x_P_).^2 ...
%             +(Y-y_P_).^2 ...
%             +(Z-z_P_).^2)).^3;
%
% DBz = (permute(reshape(repmat(x_P(2:end)-x_P(1:end-1),size(X)),size(coil_trace,2)-1,size(X,1),size(X,2),size(X,3)),[2,3,4,1]) ...
%     .* (Y-y_P_(:,:,:,1:end-1)) ...
%     - permute(reshape(repmat(y_P(2:end)-y_P(1:end-1),size(Y)),size(coil_trace,2)-1,size(Y,1),size(Y,2),size(Y,3)),[2,3,4,1])) ...
%     .* (X-x_P_(:,:,:,1:end-1)) ...
%     ./ PkM3(:,:,:,1:end-1);
% BZ = mu0*current/4/pi*sum(DBz,4);

% Add contribution of each source point P on each field point M (where we want to calculate the field)
parfor m = 1:size(X,1)
    v = zeros(size(X,2),size(X,3))
    for n = 1:size(X,2)
        for p = 1:size(X,3)
            
            % M is the obeservation point
            x_M = X(m,n,p);
            y_M = Y(m,n,p);
            z_M = Z(m,n,p);
            %             DBz = zeros(length(x_P)-1);
            
            % Loop on each discretized segment of Gamma PkPk+1
            %             for k = 1:length(x_P)-1
            %                 PkM3 = (sqrt((x_M-x_P(k))^2 + (y_M-y_P(k))^2 + (z_M-z_P(k))^2))^3;
            %                 %                 DBx(k) = ((y_P(k+1)-y_P(k))*(z_M-z_P(k))-(z_P(k+1)-z_P(k))*(y_M-y_P(k)))/PkM3;
            %                 %                 DBy(k) = ((z_P(k+1)-z_P(k))*(x_M-x_P(k))-(x_P(k+1)-x_P(k))*(z_M-z_P(k)))/PkM3;
            %                 DBz(k) = ((x_P(k+1)-x_P(k))*(y_M-y_P(k))-(y_P(k+1)-y_P(k))*(x_M-x_P(k)))/PkM3;
            %             end
            %             % Sum
            %             %             BX(m,n,p) = BX(m,n,p) + mu0*current/4/pi*sum(DBx);
            %             %             BY(m,n,p) = BY(m,n,p) + mu0*current/4/pi*sum(DBy);
            %             BZ(m,n,p) = BZ(m,n,p) + mu0*current/4/pi*sum(DBz);
            
            PkM3 = (sqrt((x_M-x_P).^2 + (y_M-y_P).^2 + (z_M-z_P).^2)).^3;
            DBz = ((x_P(2:end)-x_P(1:end-1)).*(y_M-y_P(1:end-1))-(y_P(2:end)-y_P(1:end-1)).*(x_M-x_P(1:end-1)))./PkM3(1:end-1);
            v(n,p) = mu0*current/4/pi*sum(DBz);
            %             BZ(m,n,p) = mu0*current/4/pi*sum(DBz);
        end
    end
    BZ(m,:,:) = v;
end




end


