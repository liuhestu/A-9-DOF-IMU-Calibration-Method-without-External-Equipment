# A-9-DOF-IMU-Calibration-Method-without-External-Equipment

## Static Detector

\begin{equation}
    \delta(k)=\sqrt{[var_k^{t_w}(a_x)]^2+[var_k^{t_w}( a_y)]^2+[var_k^{t_w}( a_z)]^2}
\end{equation}

## The Accelerometer Component
$$\begin{equation}
a^{\mathcal O}=T_aK_a(a^{\mathcal A}+b_a)+v_a	
\end{equation}$$

$$\begin{equation}
    \min\limits_{\phi_a} \sum\limits_{k=1}^M(\|g\|^2-\|\Phi(a_k^{\mathcal A},\phi_a)\|^2)^2
\end{equation}$$

## The Gyroscope Component

$$\begin{equation}
\omega^{\mathcal O}=T_gK_g(\omega^{\mathcal G}+b_g)+v_g
\end{equation}$$

$$\begin{equation}
  \min\limits_{\phi_g} \sum\limits_{k=2}^N \parallel \hat{a}_k - a_k^{cal} \parallel^2  
\end{equation}$$

## The Magnetometer Component

$$\begin{equation}
    m^{\mathcal O}=\Phi(m^{\mathcal M},\phi_m)=D_mm^{\mathcal M}+b_m   
\end{equation}$$

$$\begin{equation}
    \min\limits_{\phi_m} \sum\limits_{i=1}^N(\parallel h \parallel^2-\parallel\Phi(m_i^{\mathcal M},\phi_m)\parallel^2)^2    
\end{equation}$$
