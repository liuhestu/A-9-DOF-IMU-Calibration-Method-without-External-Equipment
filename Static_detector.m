function [static_interval, static_acc] = Static_detector...
            (raw_data, sampling_rate, window_duration, threshold)
    %% Static_detector
    % 功能：检测加速度数据中的静态区间，记录静态区间的起点和终点，
    %
    % 输入：
    % raw_data: 包含加速度（列2-4）和陀螺仪（列5-7）数据的原始矩阵
    % sampling_rate: 采样率，单位为Hz
    % window_duration: 滑动窗口的持续时间，单位为秒
    % threshold: 判断静态区间的加速度方差阈值
    %
    % 输出：
    % static_interval: 静态区间的起点和终点索引，形状为 [N, 2]
    % interval_point: 提取IMU在静态区间的数据

    %% 定义变量 
    plot_flag = true;   % 绘制静态区间
    k = 5;     % 整数倍threshold

    acc_data = raw_data(:, 2:4);
    num_samples = size(raw_data, 1);
    window_size = floor(window_duration * sampling_rate);   %滑动窗口大小
    half_window = floor(window_size / 2);
    acc_variance = zeros(num_samples, 1);
    threshold = k *threshold;

    %% 滑动窗口计算加速度方差
    % 遍历滑动窗口中心，避免滑动窗口超出数据边界，仅在数据的有效范围内计算
    for t = (half_window + 1):(num_samples - half_window)
        window_data = acc_data((t - half_window):(t + half_window), :);
        window_var = sqrt(sum(var(window_data, 0, 1).^2));
        acc_variance(t) = window_var;
    end

    %% 标识所有静态区间的起点和终点
    static_position = [];  % 存储静态区间起点和终点static_position
    j = 1;  % 静态区间计数器

    for t = 2:num_samples
        if acc_variance(t) < threshold && acc_variance(t - 1) >= threshold
            % 静态区间起点
            static_position(j, 1) = t;
        elseif acc_variance(t) >= threshold && acc_variance(t - 1) < threshold
            % 静态区间终点
            static_position(j, 2) = t - 1;
            j = j + 1;  % 计数器自增
        end
    end

    %% 筛选有效静态区间
    static_interval = [];  % 存储筛选后的有效静态区间static_interval
    static_acc = [];  % 存储静态区间的加速度
    
    j = 1;  % 有效静态区间计数器

    for i = 1:size(static_position, 1)-1
        % 检查静态区间的长度是否满足最小要求
        if static_position(i, 2) - static_position(i, 1) >= window_size
            % 记录有效静态区间的起点1和终点2
            static_interval(j, 1) = static_position(i, 1);
            static_interval(j, 2) = static_position(i, 2);
                                  
            % 提取静态加速度数据存入 static_acc
            if j>=2
                start_idx_static = static_interval(j, 1);
                end_idx_static = static_interval(j, 2);
    
                new_data_static = raw_data(start_idx_static:end_idx_static, 2:4);
                static_acc = [static_acc; new_data_static];
           end
           j = j + 1;  % 计数器自增
        end
    end


    %% 可视化静态区间
    if plot_flag
        figure;
        hold on;
        
        % 绘制加速度计三轴数据
        plot(1:num_samples, raw_data(:, 2), 'color', [192 42 59] / 255, 'LineWidth', 1.3, 'DisplayName', 'Accel X'); % X轴
        plot(1:num_samples, raw_data(:, 3), 'color', [63 169 84] / 255, 'LineWidth', 1.3, 'DisplayName', 'Accel Y'); % Y轴
        plot(1:num_samples, raw_data(:, 4), 'color', [53 81 156] / 255, 'LineWidth', 1.3, 'DisplayName', 'Accel Z'); % Z轴
        
        % 设置图形标题和坐标轴标签
        title('Accelerometer Data with Static Intervals');
        xlabel('Sample Index');
        ylabel('Accelerometer');
        
        % 静态区间高低电平
        static_indicator = zeros(num_samples, 1); % 初始化为低电平（0）
        
        % 将静态区间设为高电平
        for j = 1:size(static_interval, 1)
            if static_interval(j, 1) > 0 && static_interval(j, 2) > 0 && static_interval(j, 2) <= num_samples
                static_indicator(static_interval(j, 1):static_interval(j, 2)) = max(max(raw_data(:, 2:4))) / 3; % 高电平为窗口默认高度的1/2
            end
        end
        
        % 绘制高低电平作为静态区间的标识
        plot(1:num_samples, static_indicator, 'k', 'LineWidth', 1.5, 'DisplayName', 'Static Interval');
        
        % 添加图例
        legend;
        hold off;
    end

end
