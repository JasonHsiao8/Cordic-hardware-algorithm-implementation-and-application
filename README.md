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
x' &= \quad x \cdot \cos(\theta) - y \cdot \sin(\theta) \\
y' &= \quad x \cdot \sin(\theta) + y \cdot \cos(\theta)
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
CORDIC is an iterative algorithm that can gradually approach the target angle through continuous vector rotations, with each rotation angle becoming smaller and smaller. The more iterations are performed, the higher the final accuracy. For example, the first rotation is ±45°, the second is ±26.56°, the third is ±14.03°, and so on — each rotation angle is half of the previous one. Through this method, the target angle can be closely approximated.
Each rotation in the CORDIC algorithm involves the following steps:
1. **Compute the rotation angle** corresponding to the current iteration step, typically using $\arctan(2^{-i})$, where $i$ is the iteration index.
2. **Determine the rotation direction** (clockwise or counterclockwise) based on the current angle $z$, in order to approach the target angle.
3. **Update the vector’s $x$ and $y$ values**, and compute the new $z$ , which represents the accumulated angle deviation value, by adding or subtracting the rotation angle.

In each rotation, the CORDIC algorithm updates the vector (𝑥,𝑦) by using the following formulas:  

- **For clockwise rotation**:

$$
\begin{aligned}
x' &= \quad x - y \cdot 2^{-i} \\
y' &= \quad y + x \cdot 2^{-i} \\
z' &= \quad z - \arctan(2^{-i})
\end{aligned}
$$
- **For counterclockwise rotation:**

$$
\begin{aligned}
x' &= \quad x + y \cdot 2^{-i} \\
y' &= \quad y - x \cdot 2^{-i} \\
z' &= \quad z + \arctan(2^{-i})
\end{aligned}
$$  

- ***(𝑥 ,𝑦 )*** are the coordinates of the current vector.  
- ***(𝑥′,𝑦′)*** are the updated coordinates after rotation.  
- ***𝑧*** is the accumulated angle (current approximate angle).  
- ***𝑧′*** is the updated angle (new approximate angle).  
- ***𝑖***  is the iteration index, and the rotation angle at each step is $\arctan(2^{-i})$.

## K value, Cordic gain  

$$
\cos(\theta_i) = \frac{1}{\sqrt{1 + \tan^2(\theta_i)}} = \frac{1}{\sqrt{1 + 2^{-2i}}} = K_i
$$  

$$
K(n) = \prod_{i=0}^{n-1} K_i = \prod_{i=0}^{\infty} \cos\left( \tan^{-1}(2^{-i}) \right) = \prod_{i=0}^{n-1} \frac{1}{\sqrt{1 + 2^{-2i}}}
$$

All the 𝐾𝑖 factors can be ignored during the iterative process, and the final rotated result can be multiplied once by the overall scaling factor 𝐾(𝑛). If the number of iterations is fixed, this value can be precomputed and stored in a register as a constant. This correction can even be performed in advance by multiplying the constant with (𝑥,𝑦), thereby saving one multiplication operation.  
As $\theta_i$ becomes smaller and smaller, $\cos(\theta_i)$ gradually approaches 1. When the number of iterations $n \to \infty$, the product of the scaling factors $K(n)$ converges to a finite limit :


$$
K = \lim_{n \to \infty} K(n) = \cos(45^\circ) \cos(26.565^\circ) \times \cdots \times \ \cos\left( \tan^{-1}(2^{-(n-1)}) \right) \approx 0.607252935
$$

## Simulation of ArcTan and K value
Before implementing the Verilog code, we first used MATLAB to examine the iterations of arctan(2⁻ᶦ) and the K value.

<img width="1226" height="624" alt="image" src="https://github.com/user-attachments/assets/beba64d3-fc8f-46aa-98bb-abe22380ccd6" />

In this project, since the input angle range is $[-π, π]$, I implemented a CORDIC in Q1.14 fixed point format (1 integer bit and 14 fractional bits). We observed that $\arctan(2^{-i})$ at the 15th iteration exactly affects the angle’s LSB, so subsequent computations adopt 15 iterations as the baseline; iterating beyond 15 has no effect on precision. As for the $K$ value, it has already **converged to 0.607253 by the 10th iteration**.  
Therefore, before implementing in HDL, we can precompute these values and store them in the registers. Retrieving them via a LUT if we needed instead of expending extra hardware resources to compute those values.

<img width="1328" height="576" alt="image" src="https://github.com/user-attachments/assets/d4e4166f-cf0f-485f-93c5-19939438904b" />

**Arctangent Look up table**

<img width="742" height="27" alt="image" src="https://github.com/user-attachments/assets/d2154174-8d8d-45e0-a1af-9f63b13e23af" />

**K(n) value**

## Cordic State Machine

<img width="490" height="336" alt="cordic state machine drawio" src="https://github.com/user-attachments/assets/64c22564-579f-428a-9132-189bc3348b02" />

## Test Results
We round the simulated values to the sixth decimal place and compare them with the floating-point computation to evaluate the error.
| test angle | cos(θ) (fixed) | sin(θ) (fixed) | cos(θ) (float) | sin(θ) (float) | error value (cos/sin) | error rate (cos/sin) |
|:---------:|:---------------:|:--------------:|:--------------:|:--------------:|:---------------------:|:--------------------:|
|  0°       |    0.999939     |   0.000244     |    1.000000    |    0.000000    |  0.000061 / 0.000244  | 0.006104% /--Infinity--|
|  45°      |    0.707153     |   0.707092     |    0.707107    |    0.707107    |  0.000047 / 0.000014  | 0.006582% / 0.002050%|
| -45°      |    0.707214     |  -0.707153     |    0.707107    |   -0.707107    |  0.000108 / 0.000047  | 0.015213% / 0.006582%|
| 90°       |    0.000122     |   0.999939     |    0.000000    |    1.000000    |  0.000122 / 0.000061  |--Infinity--/ 0.006104%|
| -90°      |   -0.000061     |  -1.000061     |    0.000000    |   -1.000000    |  0.000061 / 0.000061  |--Infinity--/ 0.006104%|
| 30°       |    0.866150     |   0.499817     |    0.866025    |    0.500000    |  0.000124 / 0.000183  | 0.014376% / 0.036621%|
| -60°      |    0.499817     |  -0.866150     |    0.500000    |   -0.866025    |  0.000183 / 0.000124  | 0.036621% / 0.014376%|
| 8.16°     |    0.989807    |    0.141907     |    0.989876    |    0.141938    |  0.000068 / 0.000031  | 0.006913% / 0.021958%|

<img width="1904" height="322" alt="image" src="https://github.com/user-attachments/assets/fe8785fd-417d-46a2-821d-923c7e5da986" />

It can be found that **the errors of the cosine and sine values** for the test angles are almost **not exceed 0.00025** while reducing hardware overhead. 

## Conclusion

CORDIC is an iterative algorithm based on additions/subtractions, shifts operation, and small lookup tables. It can generate trigonometric values, square roots, exponential and logarithms steadily without using any multipliers, making it especially useful on resource-limited hardware such as FPGAs. Actually, **it decomposes the target angle into a sum of small rotations ± arctan(2⁻ⁱ)**. Each iteration increases the precision by roughly one bit, so the iteration count can be adjusted according to the requirement. Therefore, when a hardware design is constrained by the area or power, CORDIC is an excellent choice.

