% :)
clear all;
close all;
clc;
% :)
%DATA NAME ():
m1 = 100;
m2 = 25;

data_place = input('LOAD THE DATA: ', 's');

disp('Excel Files');
[file, path] = uigetfile('*.xlsx');
full_file = fullfile(path, file);
disp(['Okunan Dosya: ' file]);
disp(' ');

%Load the Excel Data
data =  xlsread(full_file);

%Column 1: Distances in meters
distance = data(:,1);

alpha = [0.05, 0.4, 0.8];% Determing For Quadrant scan threshold ---- ÝDEAL ALPHA 0.15----
alpha_count = length(alpha); % Alpha quantity
colors = 'rgbcmyk'; % 

%
data = data(:, 2:end)';

%M:  number of measurements, N: number of data

[M, N] = size(data);

% Normalize the data. This is only valid when the number of data points is one.
norm_data = zeros(M,N);
for i = 1:M
    norm_data(i,:) = data(i,:)/sum(data(i,:));
end


hdrs = {'Gamma Ray','Neutron','Density'}; Type of data (sorted)
units = {'CPS', 'CPS', 'CPS'};


for i = 1:M %We perform calculations and plotting in a loop for each measurement.
    X = data(i,:)'; 
    f1 = figure(1); 
    
    subplot(1,3,1); %We open a window with 1 row and 3 columns, and draw in the first column.
    plot(X, distance, 'b-');%Plot the raw data 
        
    
    %Visual information such as titles, labels, and grid view is being added.
    title([data_place ' ' hdrs(i) ' Raw Data(CPS)' ]); 
    ylabel('Depth (m)'); %X axis
    xlabel(units(i)); %Y axis
    axis ij; 
    set(gca, 'LineWidth', 2); 
    set(gca, 'YTick', (0:10:max(distance)));

    grid on;
    subplot(1,3,2);%We open a window with 1 row and 3 columns, and draw in the 2nd column.
    hold on;
    axis ij;
    title([data_place ' ' hdrs(i) ' Quadrant Scan (QS)']);  
    ylabelDepth(m)'); 
    xlabel('QS');
    set(gca, 'LineWidth', 2);
    
    %We are plotting the same graph for each alpha. (QS)
    for j = 1: alpha_count
        
         %Since the RM, RM_w, dist, and dist_w values ??are two-dimensional arrays, we store them in a three-dimensional matrix. 
	%Then, we will compress each data point to 2D and plot it.
        [dist(j, :, :),RM(j, :, :),QS] = QuadScanalphawieghtedFull(X, alpha(j), 0, m1, m2);  
        plot(QS, distance, [colors(j) '-'], 'DisplayName', ['alpha: ' num2str(alpha(j))]);
    end
    grid on;
    legend show; 
    set(gca, 'YTick', (0:10:max(distance)));
    
    subplot(1,3,3);
	axis ij;
    hold on;
    title([data_place ' ' hdrs(i) ' Weighted Quadrant Scan(WQS)']); 
    ylabel('depth (m)');
    xlabel('WQS');
    set(gca, 'LineWidth', 2);

   %weighted quadrant scan 
    for j = 1: alpha_count
        [dist_w(j, :, :),RM_w(j, :, :), QS_w] = QuadScanalphawieghtedFull(X, alpha(j), 1, m1, m2);        
        plot(QS_w, distance, [colors(j) '-'], 'DisplayName', ['alpha: ' num2str(alpha(j))]);
    end   
    grid on;
    legend show;
    set(gca, 'YTick', (0:10:max(distance)));
    saveas(f1, strcat('Plot_', num2str(i), '_1.fig'));
    close(f1);

    %Reccurence plots
    
    f2=figure;
    for j = 1: alpha_count
        subplot(2, alpha_count, j);
        imagesc(distance, distance, squeeze(RM(j, :, :)));
        ylabel('Derinlik (m)');
        xlabel('Derinlik (m)');
        title([data_place ' ' hdrs(i) ' Recurrence Plots (alpha: ' num2str(alpha(j))]);  
        colorbar;
    end
    
    %Recurrene plots with weighted 
	 for j = 1: alpha_count
        subplot(2, alpha_count, alpha_count + j);
        imagesc(distance, distance, squeeze(RM_w(j, :, :)));
        ylabel('depth (m)');
        xlabel('depth (m)');
        title([data_place ' ' hdrs(i) ' Recurrence Plots Weighted, alpha: ' num2str(alpha(j))]);
        colorbar;
    end
    
    saveas(f2, strcat('RM_', num2str(i), '_1.fig'));
    close(f2);

    %norm matrix 
    f3=figure;
    for j = 1: alpha_count
        subplot(2, alpha_count, j);
        imagesc(distance, distance, squeeze(dist(j, :, :)));
        ylabel('depth (m)');
        xlabel('depth (m)');
        title([data_place ' ' hdrs(i) ' norm matrix  (alpha: ' num2str(alpha(j))]); 
        colorbar;
    end
    
    %norm matrix, weighted
    for j = 1: alpha_count
        subplot(2, alpha_count, alpha_count + j);
        imagesc(distance, distance, squeeze(dist_w(j, :, :)));
        title([data_place ' ' hdrs(i) ' norm matrix weighted, alpha: ' num2str(alpha(j))]);
        xlabel('depth (m)');
        ylabel('depth (m)');

        colorbar;
    end
    
    saveas(f3, strcat('Norm_', num2str(i), '_1.fig'));
    close(f3);
    clear RM RM_w dist dist_w;
end    

%The program ends if there is only one piece of data; otherwise, it continues.
if(M < 2) 
    return;
end


%Normalized data is being plotted.

subplot(1,3,1);
hold on;
for i = 1:M    
    X = norm_data(i,:)';
    plot(X, distance, [colors(i) '-'], 'DisplayName', [data_place '-' cell2mat(hdrs(i))]);
end

title([data_place ' Well Data']);
set(gca, 'YTick', (0:10:max(distance)));
ylabel('depth (m)');
xlabel(units(1));
axis ij;
set(gca, 'LineWidth', 2);
grid on;
legend show;

clear dist RM QS; %Recalculating and cleaning up old, unnecessary data for memory.

subplot(1,3,2);
hold on;
%Combined QS Results
for i=1:alpha_count
    
    [dist(i, :, :),RM(i, :, :),QS] = QuadScanalphawieghtedFull(norm_data', alpha(i), 0, m1, m2); 
    plot(QS, distance, [colors(i) '-'], 'DisplayName', ['alpha: ' num2str(alpha(i))]);
    
end

title('Combined QS Results (QS)');
ylabel('depth (m)');
xlabel('QS');
axis ij;
set(gca, 'LineWidth', 2);
grid on;
legend show;
set(gca, 'YTick', (0:10:max(distance)));

subplot(1,3,3);
hold on;

%Combined weighted QS Results 
for i=1:alpha_count
    
    [dist_w(i, :, :),RM_w(i, :, :),QS_w] = QuadScanalphawieghtedFull(norm_data', alpha(i), 1, m1, m2); 
    plot(QS_w, distance, [colors(i) '-'], 'DisplayName', ['alpha: ' num2str(alpha(i))]);
    
end

titleCombined weighted QS Results (WQS)');
ylabel('depth (m)');
xlabel('WQS');
axis ij;
set(gca, 'LineWidth', 2);
grid on;
legend show;
set(gca, 'YTick', (0:10:max(distance)));
saveas(f4, strcat('Plot_Bil_1.fig'));
close(f4);
%Multiple Recurrence Plots
f5=figure;
for i = 1:alpha_count
    subplot(2, alpha_count, i);
    imagesc(distance, distance, squeeze(RM(i,:,:)));
    ylabel('depth (m)');
    xlabel('Depth (m)');
    title(['Multiple Recurrence Plots (alpha: ' num2str(alpha(i))]);
    colorbar;
    subplot(2, alpha_count, i + alpha_count);
    imagesc(distance, distance, squeeze(RM_w(i,:,:)));
    ylabel('depth (m)');
    xlabel('Depth (m)');
    title([ 'Multiple Recurrence Plots weighted, alpha: ' num2str(alpha(i))]);
    colorbar;
end
saveas(f5, strcat('RM_Bil_1.fig'));
close(f5);
f6=figure;
for i = 1:alpha_count
    subplot(2, alpha_count, i);
    imagesc(distance, distance, squeeze(dist(i,:,:)));
    ylabel('depth (m)');
    xlabel('Depth (m)');
    title(['Multiple Norm Matrix (alpha: ' num2str(alpha(i))]);
    colorbar;
    subplot(2, alpha_count, i + alpha_count);
    imagesc(distance, distance, squeeze(dist_w(i,:,:)));
    ylabel('Depth (m)');
    xlabel('Depth (m)');
    title(['Multiple Norm Matrix weighted, alpha: ' num2str(alpha(i))]);
    colorbar;
end
saveas(f6, strcat('Norm_Bil_1.fig'));
close(f6);