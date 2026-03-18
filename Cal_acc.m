function [Ta, Ka, Ba] = Cal_acc(static_acc, G)
    
    % 初始值
    a0 = [0, 0, 0,...
          0.98, 1.01, 1.02,...
          -0.01242, -0.1028, -0.2070];
    
    % 设置优化选项
    options = optimset('TolX', 1e-6, 'TolFun', 1e-6, 'Algorithm',...
        'Levenberg-Marquardt', 'Display', 'iter', 'MaxIter', 300);
    

    % 进行最小二乘优化
    [a, resnorm] = lsqnonlin(@(a) optimal_acc(a, static_acc(:,1:3), G), a0, [], [], options);
    
    

    % 使用优化结果计算 Ta, Ka, Ba
    Ta = [1, -a(1), a(2); 
          0, 1, -a(3); 
          0, 0, 1];
      
    Ka = [a(4), 0, 0; 
          0, a(5), 0; 
          0, 0, a(6)];
      
    Ba = [a(7); a(8); a(9)];
   
    
end

function E = optimal_acc(a, static_acc, G)
    % 提取 Ta, Ka, Ba
    Ta = [1, -a(1), a(2); 0, 1, -a(3); 0, 0, 1];
      
    Ka = [a(4), 0, 0; 0, a(5), 0; 0, 0, a(6)]; 
      
    Ba = [a(7); a(8); a(9)];
    
    % 计算每个加速度数据的误差
    for i = 1:size(static_acc, 1)
        E(i, 1) = (G^2 - norm(Ta * Ka * (static_acc(i, 1:3)' + Ba))^2)^2;
    end
end
