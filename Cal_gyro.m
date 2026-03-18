function [Tg, Kg] = Cal_gyro(raw_data, static_interval, sampling_rate, Bg, Ta, Ka, Ba)
    % 时间间隔
    dt = 1 / sampling_rate; 

    % 初始优化参数 b0
    b0 = [0, 0, 0,...
          0, 0, 0,...
          0.9, 0.9, 0.9]; 

    % 设置优化选项
    options = optimset('TolX', 1e-6, 'TolFun', 1e-6, 'Algorithm', ...
        'Levenberg-Marquardt', 'Display', 'iter', 'MaxIter', 200);

    % 优化过程中不绘图
    plot_flag = false;

    % 进行最小二乘优化
    [b, resnorm] = lsqnonlin(@(b) optimal_gyro(b, raw_data, static_interval, ...
        Ta, Ka, Ba, Bg, dt, plot_flag), b0, [], [], options);

    plot_flag = false;
    optimal_gyro(b, raw_data, static_interval, Ta, Ka, Ba, Bg, dt, plot_flag);


    % 使用优化结果计算 Tg, Kg    
    Tg = [1, -b(1), b(2); 
          b(3), 1, -b(4); 
          -b(5), b(6), 1];
    
    Kg = [b(7), 0, 0;
          0, b(8), 0;
          0, 0, b(9)];
   
end


function E = optimal_gyro(b, raw_data, static_interval, Ta, Ka, Ba, Bg, dt, plot_flag)
    % 提取 Tg, Kg 
    Tg = [1, -b(1), b(2); b(3), 1, -b(4); -b(5), b(6), 1];  
    Kg = [b(7), 0, 0; 0, b(8), 0; 0, 0, b(9)];  
   
    cal_acc = (Ta * Ka * ((raw_data(:, 2:4))' + Ba))';  % 校准后的加速度值
   
    % 初始化
    n = size(raw_data, 1);
    E = zeros(size(static_interval, 1)-2, 1);
    acc_hat = zeros(n, 3);
    valid =zeros(size(static_interval, 1)-2:2);

    %% 迭代旋转矩阵计算陀螺仪误差
    % 遍历所有动态区间 
    for j = 2 : size(static_interval, 1)-1
                
        start_dynamic = static_interval(j, 2);  
        end_dynamic = static_interval(j + 1, 1);  
        
        R_hat = eye(3);
       
        % 迭代第j个区间内的旋转矩阵
        for i = start_dynamic : end_dynamic+50
            gyro_free = Tg * Kg * (raw_data(i, 5:7) + Bg')';  % 去除零偏后的陀螺仪数据
            axis = gyro_free / norm(gyro_free);  % 计算旋转轴（单位向量）
            theta = norm(gyro_free) * dt;  % 计算旋转角度

            % 当前时刻的旋转矩阵
            R_hat = R_hat * rodrigues_rotation(axis, theta);
        end
        
        % 终点加速度估计值
        acc_hat(end_dynamic+50,:) = (R_hat' * cal_acc(start_dynamic,:)')';
        
        % 记录有效值
        valid(j-1,1) = norm(acc_hat(end_dynamic+50,:));
        valid(j-1,2) = norm(cal_acc(end_dynamic+50,:));
        
        E(j-1,1) = norm(acc_hat(end_dynamic+50,:) - cal_acc(end_dynamic+50,:))^2;
    end

    %% 绘制估计值与校准值对比曲线
    if plot_flag
        figure;
        hold on;

        % 校准值(绿色)
        plot(valid(:,2), '-', 'Color', [63 169 84] / 255, 'LineWidth', 1.5, 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', [63 169 84] / 255);
        % 估计值(蓝色)
        plot(valid(:,1), '-', 'Color', [53, 81, 156] / 255, 'LineWidth', 1.5, 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', [53, 81, 156] / 255);

        legend('Calibrated Acceleration', 'Estimated Acceleration');
        title('Optimizing parameter divergence');
        xlabel('Time (s)');
        ylabel('Norm');
        grid on;
    end
     
end

function R_hat = rodrigues_rotation(axis, theta)
    % 罗德里格斯旋转公式，计算旋转矩阵
    skew_axis = [0, -axis(3), axis(2); axis(3), 0, -axis(1); -axis(2), axis(1), 0];
    R_hat = eye(3) + sin(theta) * skew_axis + (1 - cos(theta)) * (skew_axis * skew_axis);
end
