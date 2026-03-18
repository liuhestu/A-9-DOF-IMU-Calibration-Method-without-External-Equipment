function [Dm, Bm] = Cal_mag(raw_data, H)
   
    % 初始值
    c0 = [0.98, 0, 0, ...
          0, 1.01, 0, ...
          0, 0, 0.99, ...
          0.001, 0.001, -0.001];
    


    % 设置优化选项
    options = optimset('TolX', 1e-6, 'TolFun', 1e-6, 'Algorithm', ...
        'Levenberg-Marquardt', 'Display', 'iter', 'MaxIter', 300);
    

    % 进行最小二乘优化
    [c, resnorm] = lsqnonlin(@(c) optimal_mag(c,raw_data, H), c0, [], [], options);
    
    
    % 使用优化结果计算 Ta, Ka, Ba

    Dm = reshape(c(1:9),3,3);
    
    Bm = c(10:12)';
    

end

function E = optimal_mag(c, raw_data, H)
    % 提取 Ta, Ka, Ba
    Dm = reshape(c(1:9),3,3);
    Bm = c(10:12)';
    
    % 计算每个加速度数据的误差
    for i = 1:size(raw_data, 1)
        E(i, 1) = (H^2 - norm(Dm* raw_data(i,8:10)'+ Bm)^2)^2;
    end
end
