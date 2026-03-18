function IMU_calibration(raw_data, sampling_rate, window_duration, initial_duration, G, H)
    
    % raw_data: N×10数组, time, acc(3), gyro(3), mag(3)
    % sampling_rate = 200        采样频率, 200Hz
    % window_duration = 0.5      静态区间下限, 0.5s
    % initial_duration = 10      开机时最少静置时间, 10s
    % G = 9.79338                武汉重力, m/s^2, 标量
    % H = 50.0468                东南501磁场, µT, 标量
 
%     Run with: IMU_calibration(raw_data, 200, 0.5)
%     red    [192 42 59] / 255  
%     green  [63 169 84] / 255
%     blue   [53, 81, 156] / 255

    if nargin < 4 || isempty(initial_duration)
        initial_duration = 10; 
    end
    if nargin < 5 || isempty(G)
        G = 9.79338;  % 武汉重力
    end
    if nargin < 6 || isempty(H)
        H = 50.0707;    %东南501磁场
    end


    [threshold, Bg] = Initialization(raw_data, sampling_rate, initial_duration);
    [static_interval,static_acc] = Static_detector(raw_data, sampling_rate, window_duration, threshold);
    
    disp('Accelerometer Calibration');
    [Ta, Ka, Ba] = Cal_acc(static_acc, G);

    disp('Magnetormeter Calibration');
    [Dm, Bm] = Cal_mag(raw_data, H);
    
    disp('Gyroscope Calibration');
    [Tg, Kg] = Cal_gyro(raw_data, static_interval, sampling_rate, Bg, Ta, Ka, Ba);
    
    disp('The calibration results of the Accelerometer:')
    disp('Ba =')
    disp(Ba)
    
    Da =Ta*Ka;
    disp('Da =')
    disp(Da)
    
    disp('The calibration results of the Gyroscope:')
    disp('Bg =')
    disp(Bg)

    Dg = Tg*Kg;
    disp('Dg =')
    disp(Dg)
    
    disp('The calibration results of the Magnetometer:')
    disp('Bm =')
    disp(Bm)
    disp('Dm =')
    disp(Dm)

    %% 保存校准后数据
    cal_data(:,1) = raw_data(:,1);
    cal_data(:, 2:4) = (Ta*Ka*(raw_data(:,2:4)' + Ba))';
    cal_data(:, 5:7) = (Tg*Kg*(raw_data(:,5:7)' + Bg))';
    cal_data(:, 8:10) = (Dm*raw_data(:,8:10)' + Bm)';
    save('cal_data.mat', 'cal_data');

    %% 绘制磁力计3D散点图 
    plot_flag = true;
    if plot_flag
    % 绘制磁力计
    figure('Name', 'Magnetometer: Raw vs Calibrated', 'NumberTitle', 'off');
    hold on;
    
    %校准后质心
    mag_x = mean(cal_data(:, 8));
    mag_y = mean(cal_data(:, 9));
    mag_z = mean(cal_data(:, 10));
    disp(['Mag Center : (', num2str(mag_x), ', ', num2str(mag_y), ', ', num2str(mag_z), ')']);

    % 未校准数据(绿色)
    plot3(raw_data(:, 8), raw_data(:, 9), raw_data(:, 10), '-', 'Color', [63 169 84] / 255, 'LineWidth', 2.5);
    % 校准后数据(蓝色)
    plot3(cal_data(:, 8), cal_data(:, 9), cal_data(:, 10), '-', 'Color', [53, 81, 156] / 255, 'LineWidth', 2.5);

    set(gca, 'FontSize', 16.5);
    
    xlim([-60, 60]);
    ylim([-60, 60]);
    zlim([-60, 60]);
    
    xticks([-50, -25, 0, 25, 50]);
    yticks([-50, -25, 0, 25, 50]);
    zticks([-50, -25, 0, 25, 50]);

    axis equal;
    grid on;

    % 绘制加速度计
    figure('Name', 'Accelerometer: Raw vs Calibrated', 'NumberTitle', 'off');
    hold on;

    %校准后质心
    acc_x = mean(cal_data(:, 2));
    acc_y = mean(cal_data(:, 3));
    acc_z = mean(cal_data(:, 4));
    disp(['Acc Center : (', num2str(acc_x), ', ', num2str(acc_y), ', ', num2str(acc_z), ')']);

    % 未校准数据(绿色)
    scatter3(raw_data(:, 2), raw_data(:, 3), raw_data(:, 4), 15, [63 169 84] / 255, 'filled');
    % 校准后数据(蓝色)
    scatter3(cal_data(:, 2), cal_data(:, 3), cal_data(:, 4), 15, [192 42 59] / 255, 'filled');

    set(gca, 'FontSize', 16.5);
    
%     xlim([-12.5, 12.5]);
%     ylim([-12.5, 12.5]);
%     zlim([-12.5, 12.5]);
%     
%     xticks([-50, -25, 0, , 50]);
%     yticks([-50, -25, 0, 25, 50]);
%     zticks([-50, -25, 0, 25, 50]);

    axis equal;
    grid on;
    
    end
end