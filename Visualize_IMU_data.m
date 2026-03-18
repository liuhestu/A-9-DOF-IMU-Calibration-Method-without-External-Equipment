function Visualize_IMU_data(IMU_data)
    % 可视化 IMU 数据：加速度计、陀螺仪和磁力计
    % 用于简单判断一下采集的数据是否合适

    % 检查数据格式是否正确
    if size(IMU_data, 2) < 10
        error('IMU_data 应该至少包含 10 列数据（时间、加速度计、陀螺仪、磁力计的三轴数据）。');
    end

    % 提取时间、加速度计、陀螺仪和磁力计数据
    time = IMU_data(:, 1);
    acc_data = IMU_data(:, 2:4);
    gyro_data = IMU_data(:, 5:7);
    mag_data = IMU_data(:, 8:10);

    % 1. 加速度计三轴幅值图
    figure('Name', 'Accelerometer Data', 'NumberTitle', 'off');
    plot(time, acc_data);
    title('Accelerometer Data');
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');
    legend('X', 'Y', 'Z');
    grid on;

    % 2. 加速度计数据的立体散点图
    figure('Name', 'Accelerometer 3D Scatter Plot', 'NumberTitle', 'off');
    scatter3(acc_data(:, 1), acc_data(:, 2), acc_data(:, 3), 5, 'filled');
    title('Accelerometer 3D Scatter Plot');
    xlabel('X (m/s^2)');
    ylabel('Y (m/s^2)');
    zlabel('Z (m/s^2)');
    grid on;

    % 3. 陀螺仪三轴幅值图
    figure('Name', 'Gyroscope Data', 'NumberTitle', 'off');
    plot(time, gyro_data);
    title('Gyroscope Data');
    xlabel('Time (s)');
    ylabel('Angular Velocity (rad/s)');
    legend('X', 'Y', 'Z');
    grid on;

    % 4. 磁力计三轴幅值图
    figure('Name', 'Magnetometer Data', 'NumberTitle', 'off');
    plot(time, mag_data);
    title('Magnetometer Data');
    xlabel('Time (s)');
    ylabel('Magnetic Field (\muT)');
    legend('X', 'Y', 'Z');
    grid on;

    % 5. 磁力计数据的立体散点图
    figure('Name', 'Magnetometer 3D Scatter Plot', 'NumberTitle', 'off');
    scatter3(mag_data(:, 1), mag_data(:, 2), mag_data(:, 3), 5, 'filled');
    title('Magnetometer 3D Scatter Plot');
    xlabel('X (\muT)');
    ylabel('Y (\muT)');
    zlabel('Z (\muT)');
    grid on;
end
