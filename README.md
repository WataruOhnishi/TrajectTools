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

## Step trajectory
See [example](https://github.com/WataruOhnishi/TrajectTools/blob/master/docs/ex1_step.m)

![ex1](https://github.com/WataruOhnishi/TrajectTools/blob/master/docs/plot/png/ex1.png?raw=true)

## Back and forth motion with position constraints
See [example](https://github.com/WataruOhnishi/TrajectTools/blob/master/docs/ex2_backandforth_pos.m)

![ex2](https://github.com/WataruOhnishi/TrajectTools/blob/master/docs/plot/png/ex2.png?raw=true)

## Back and forth motion with velocity constraints
See [example](https://github.com/WataruOhnishi/TrajectTools/blob/master/docs/ex3_backandforth_vel.m)

![ex3](https://github.com/WataruOhnishi/TrajectTools/blob/master/docs/plot/png/ex3.png?raw=true)

## Back and forth motion with acceleration constraints
See [example](https://github.com/WataruOhnishi/TrajectTools/blob/master/docs/ex4_backandforth_acc.m)

![ex4](https://github.com/WataruOhnishi/TrajectTools/blob/master/docs/plot/png/ex4.png?raw=true)

## 3rd order time-optimal trajectory 
See [example](docs/ex5_backandforth_minTime_3rd.m)

![ex5](docs/plot/png/ex5.png)

## 4rd order time-optimal trajectory 
See [example](docs/ex6_backandforth_minTime_4th.m)

![ex6](docs/plot/png/ex6.png)
