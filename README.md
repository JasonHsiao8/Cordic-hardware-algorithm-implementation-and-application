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

$$
\begin{aligned}
x' &= x \cdot \cos(\theta) - y \cdot \sin(\theta) \\
y' &= x \cdot \sin(\theta) + y \cdot \cos(\theta)
\end{aligned}
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
\end{bmatrix} 
$$  

and choose appropriate angle values $\theta_i$, such that:

$$
\tan(\theta_i) = 2^{-i} \quad  i = 0, 1, 2, \ldots, n
$$

In this way, the multiplication with $\tan(\theta_i)$ can be transformed into shift operations, which can not only reduce hardware area but also lower power consumption and significantly accelerate the computation speed.

## Multiple Iterations
CORDIC is an iterative algorithm that can gradually approach the target angle through continuous vector rotations, with each rotation angle becoming smaller and smaller. The more iterations are performed, the higher the final accuracy. For example, the first rotation is ±45°, the second is ±22.5°, the third is ±11.25°, and so on — each rotation angle is half of the previous one. Through this method, the target angle can be closely approximated.
Each rotation in the CORDIC algorithm involves the following steps:
1. **Compute the rotation angle** corresponding to the current iteration step, typically using $\arctan(2^{-i})$, where $i$ is the iteration index.
2. **Determine the rotation direction** (clockwise or counterclockwise) based on the current angle $z$, in order to approach the target angle.
3. **Update the vector’s $x$ and $y$ values**, and compute the new $z$ , which represents the accumulated angle deviation value, by adding or subtracting the rotation angle.

In each rotation, the CORDIC algorithm updates the vector (𝑥,𝑦) by using the following formulas:  

- **For clockwise rotation**:

$$
\begin{aligned}
x' &= x - y \cdot 2^{-i} \\
y' &= y + x \cdot 2^{-i} \\
z' &= z - \arctan(2^{-i})
\end{aligned}
$$
- **For counterclockwise rotation:**

$$
\begin{aligned}
x' &= x + y \cdot 2^{-i} \\
y' &= y - x \cdot 2^{-i} \\
z' &= z + \arctan(2^{-i})
\end{aligned}
$$






