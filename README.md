# Cordic-hardware-algorithm
**CORDIC**(**CO**ordinate **R**otation **DI**gital **C**ompute) is a digital algorithm used to compute trigonometric functions, square roots, logarithms, and other mathematical operations. Its main idea is to approximate the desired results through a series of vector rotations.  
**Basic concepts** : *1. Vector rotation* *2. Using addition and shift instead of multiplication* *3. Multiple iterations*  
# 
### Development Enviroment 
- *Vivado Edition 2025.1*
### Cordic Application
- [Cordic_Implementation](./cordic)
- [Cordic_decimal_multiplier](./cordic_decimal_multiplier)
 
## Vector Rotation  
For a vector (𝑥,𝑦) on the plane, when it rotated by an angle 𝜃, the new vector (𝑥′,𝑦′) can be calculated by using the following rotation matrix:  

$$
\begin{bmatrix}
    x'\\\
    y'
\end{bmatrix} 
\begin{matrix}
    =
\end{matrix}
\begin{bmatrix}
    \cos(\theta) & -\sin(\theta) \\
    \sin(\theta) & \cos(\theta)
\end{bmatrix}
\begin{bmatrix}
    x \\
    y
\end{bmatrix} 
$$  

We can avoid complex multiplication operations by using a finite time of rotation operations. We modify the matrix equation by factoring out cos(𝜃) term. The modified formula can be written as:  

$$
\begin{bmatrix}
    x'\\\
    y'
\end{bmatrix} 
\begin{matrix}
    =
\end{matrix}
\cos(\theta)
\begin{bmatrix}
    1 & -\tan(\theta) \\
    \tan(\theta) & 1
\end{bmatrix}
\begin{bmatrix}
    x \\
    y
\end{bmatrix} \tag{2}
$$  









