# Grain Growth Cellular Automata Model

This is an advanced 2D Cellular Automata (CA) model for the simulation of microstructural evolution during grain growth in polycrystalline materials. The model is built on physical principles and it can directly work with experimental EBSD data. It is written in Dyalog APL.

## Features

This model incorporates a sophisticated set of features to achieve a balance between physical realism and computational efficiency:

* **Crystallography:** Crystallographic orientations are represented as Euler angles (Bunge convention) to the user, and internally as quaternions. Misorientations are calculated considering cubic crystal symmetry

* **Moore Neighborhood:** Boundary energy densities are calculated from the contribution of 8 neighbours

    $$\gamma_o=\gamma_{NW}+\gamma_N+\gamma_{NE}+\gamma_E+\gamma_{SE}+\gamma_S+\gamma_{SW}+\gamma_W$$

* **Robust Simulation Mechanics:** The model calculates the transformation rate ($r_k$) for a cell to flip to the orientation of neighbour $k$ based on the equation

    $$r_k = \left(\frac{k_r}{\Delta x^2 N}\right) M_k \mathcal{K} |\Delta\gamma_k|$$

    The rate is scaled by cell size $\Delta x$ and number of neighbours $N$ to ensure physical kinetics are independent of grid resolution, and by an heuristic factor $\mathcal{K}$ (expained below). The $k_r$ parameter, configurable by the user, works as an overall scaling factor for the model.
    
    Each time step, an accumulator of transformation into each neighbor is updated such that $a_k{t+\Delta t}=a_k(t) + r_k \Delta t$. The cell is then transformed or not interpreting this accumulator as a probability (scaled by the user configurable factor $\xi_f$, such that a higher $\xi_f$ implies higher randomness). Therefore, the condition to transform into neighbor $k$ is
    
    $$\xi(0,1)<a_k(t)^{\frac{1}{\xi_f}}$$
    
* **Physically-Based Kinetics:**

    * *Grain boundary energy* is calculated using the Read-Shockley equation, dependent on the misorientation angle with the neighbor $k$, given by $\theta_k$
    
    $$\gamma_k=\gamma_0 \frac{\theta_k}{\theta_H}\left(1 - \log\left(\frac{\theta_k}{\theta_H}\right)\right)$$


    * *Grain boundary mobility* is a function of both temperature and misorientation, according to Humphrey's equation
    
    $$M_k=M_0 \exp\left(\frac{-Q}{R T}\right) \left(1-\exp\left(-A\left(\frac{\theta_k}{\theta_H}\right)^n\right)\right)$$
    
* **Flexible Local Factors:** The driving force can be modified by any number of user-provided local property maps. The following factors are already predefined:

    * *Thermal Energy:* Adds a deterministic driving force for recrystallization
    
    $$\Delta\gamma_T=w_T\frac{k T}{\Delta x^2} \xi(-1,1)$$

    
    * *Image Quality:* Higher energy push at cells with more deffects (more image quality, also related with stored energy)
    
    $$\Delta\gamma_{IQ}=w_{IQ}\gamma_0 \left(1 - \frac{IQ_o}{IQ_{max}}\right)$$
    
    * *Confidence Index:* Higher energy fluctuations at cells with a more uncertain orientation (a lower confidence index)
    
    $$\Delta\gamma_{CI}=w_{CI}(1 - CI_o) \xi(-1,1)$$

    The total transformation energy for each neighbor is then calculated as:
    
    $$\Delta\gamma_k=(\gamma_k - \gamma_0)+\Delta\gamma_T+\Delta\gamma_{IQ}+\Delta\gamma_{CI}$$

* **Advanced Heuristics:** The factor $\mathcal{K}$ is obtained as the product of three components

    $$\mathcal{K}=\mathcal{K}_c \mathcal{K}_n \mathcal{K}_g$$

    * *Cooperative factor:* For those neighbours for which there is a misorientation with respect to one of its neighbours of the same angle as the misorientation between the parent and transforming cell ($\delta_{ok}$ is 1), it is considered that the boundary energy after transition will be decreased by a factor $k_c$
    
    $$\mathcal{K}_c=1-\delta_{ok}\left(1 - k_c\right)$$
    
    * *Geometric factor:* This factor accounts for the influence of the boundary topology in the neighborhood, considering both coherent front advancement and the "squeeze" pressure on shrinking grains, adding the contribution of all moving boundaries
    
    $$\mathcal{K}_g=\sqrt{\left(\sum_k{|u_{kx}|}\right)^2+\left(\sum_k{|u_{ky}|}\right)^2}$$
    
    * *Multiple-joint factor:* The factor $\mathcal{K}_n$ takes different values depending if the cell is part of a simple boundary, triple point or quadriple point (the quadruple point factor is also used when more than four grains meet)
    
* **Boundary Conditions:** Supports both periodic and "mirror" (no-flux) boundary conditions for realistic simulation of finite samples

* **EBSD Integration:** Can directly read `.ctf` (HKL) and `.ang` (TSL) EBSD files, clean non-indexed points, and crop regions of interest

### Symbols

| Symbol | Description |
| :--- | :--- |
| **Grid** | |
| $\Delta x$ | Cell size (square grid) |
| $N$ | Number of interacting neighbors for a cell (8 for Moore) |
| **Process** | |
| $T$ | Temperature of the process |
| $\Delta t$ | Time increment |
| **Orienations and Misorientations**| |
| $q_o, q_k$ | Crystallographic orientation of transforming cell and neighbour $k$ |
| $\Delta\theta_k$ | Misorientation angle between cell and neighbour $k$ |
| $\Delta\theta_H$ | Misorientation angle at high angle grain boundaries |
| $\delta_{ok}$ | A boolean factor (1 or 0) indicating if the condition for the cooperative factor is met for neighbor $k$ |
| **Boundary Energy and Mobility**| |
| $\gamma_o$ | Initial grain boundary energy density of cell $o$ |
| $\gamma_k$ | Grain boundary energy density of cell $o$ if it transforms into $k$ |
| $\gamma_0$ | Energy density at HAGB |
| $M_k$ | Mobility of boundary with neighbour $k$ |
| $M_0$ | Reference boundary mobility |
| $Q$ | Activation energy |
| $A, n$ | Factor and exponent in Humphrey's law |
| **Transformation**| |
| $r_k$ | Rate of transformation of cell $o$ into neighbour $k$ |
| $a_k$ | Accumulated transformation of cell $o$ into neighbour $k$ |
| $k_r$ | Transformation rate overall scaling factor |
| $\xi_f$ | Randomness in transformation of cells |
| **Local Factors** | |
| $\Delta\gamma_T, \Delta\gamma_{IQ}, \Delta\gamma_{CI} $ | Contribution to driving force of temperature, image quality, and confidence index |
| $w_T, w_{IQ}, w_{CI}$ | Scaling factors |
| $IQ_o, IQ_{max}$ | Image quality of each cell and maximum image quality |
| $CI_o$ | Confidence index of each cell |
| **Heuristics** | |
| $\mathcal{K}$ | Total multiplicative factor |
| $\mathcal{K}_c, \mathcal{K}_n, \mathcal{K}_g$ | Multiplicative factors for cooperative movement, multiple joints and geometry |
| $k_c$ | Cooperative factor (contribution of similar boundaries) |
| $u_{kx}, u_{ky}$ | Components of unitary vector normal to boundary with neighbour $k$ |
| **Others** | |
| $k$ | Boltzman constant |
| $R$ | Universal gas constant |
| $\xi(a,b)$ | Random number between $a$ and $b$ |


## Usage

The model is provided as a `.apls` script. To run it, specify the `.json5` configuration file(s) as argument(s). If no file name is given, the default file `gg2.json5` is used. See this file for further details about configuration options.
