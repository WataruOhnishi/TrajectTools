# TrajectTools
Polynomial trajectory generation tools for MATLAB. Analytical differentiation is calculated. 

## Features
* Arbitrary order trajectory
* Analytical differentiation<br>
No numerical differentiation, no delay
* Symbolic coefficients as well as numerical coefficients

## Installation 
addpath `src` to MATLAB
### Requred toolbox
* Symbolic math toolbox
* Optional: [FigTools](https://github.com/ThomasBeauduin/FigTools)

## Position constrained step trajectory
See [example](docs/docs/ex1_pos_step.m)

![ex1](docs/plot/png/ex1.png)

## Position constrained back and forth trajectory
See [example](docs/ex2_pos_backandforth.m)

![ex2](docs/plot/png/ex2.png)

## Velocity constrained back and forth trajectory
See [example](docs/ex3_vel_backandforth.m)

![ex3](docs/plot/png/ex3.png)

## Acceleration constrained back and forth trajectory
See [example](docs/ex4_acc_backandforth.m)

![ex4](docs/plot/png/ex4.png)

## Time-optimal 3rd order trajectory 
See [example](docs/ex5_timeOpt_3rd_backandforth.m)

[Advanced Setpoints for Motion Systems](https://jp.mathworks.com/matlabcentral/fileexchange/16352-advanced-setpoints-for-motion-systems) is utilized.

![ex5](docs/plot/png/ex5.png)

## Time-optimal 4th order trajectory 
See [example](docs/ex6_timeOpt_4th_backandforth.m)

[Advanced Setpoints for Motion Systems](https://jp.mathworks.com/matlabcentral/fileexchange/16352-advanced-setpoints-for-motion-systems) is utilized.

![ex6](docs/plot/png/ex6.png)
