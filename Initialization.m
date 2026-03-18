function  [threshold, Bg] = Initialization(raw_data, sampling_rate, initial_duration)
    
    plot_flag = false;   %绘制Allan方差图

    num_sample = sampling_rate * initial_duration;
       
    initial_data = raw_data(1:num_sample, 5:7);
    
    %% 计算 Allan 方差，选择最小点作为最佳静置点
    [allan_var, tau] = allanvar(initial_data, 'octave', sampling_rate);
    [min_value, min_idx] = min(allan_var);  % 找到最小 Allan 方差的值和索引
    T_init = tau(min_idx);  % 最小 Allan 方差对应的最佳静置时间


    disp('T_init:')
    disp(T_init)


    
    %% 计算阈值和陀螺仪偏差
    %最佳静置时间内的阈值
    initial_acc = raw_data(1:T_init*sampling_rate,2:4);
    threshold = sqrt(sum(var(initial_acc, 0, 1).^2));
    
    % 最佳静置时间内的陀螺仪偏差
    initial_gyro = raw_data(1:T_init*sampling_rate,5:7);
    Bg = - (mean(initial_gyro, 1))';  % 计算陀螺仪数据的平均值
   

    %% 绘制 Allan 方差图
    if plot_flag
        figure;
        plot(tau, allan_var, 'LineWidth', 1.2); 
        xlabel('Averaging Time (\tau)', 'FontSize', 12);
        ylabel('Allan Variance', 'FontSize', 12);
        title('Allan Variance of Gyroscope Data', 'FontSize', 14);
        grid on;
        grid minor;  % 添加次级网格
        
        % 在图中标出最小 Allan 方差对应的点
        hold on;
        loglog(T_init, min_value, 'ro', 'MarkerSize', 8, 'LineWidth', 2);  % 用红色圆点标记最小值
        text(T_init, min_value, sprintf('  \\leftarrow Min Allan Var (\\tau=%.2f)', T_init), 'FontSize', 10);
        
        % 保持图像
        hold off;
    end
    
end
