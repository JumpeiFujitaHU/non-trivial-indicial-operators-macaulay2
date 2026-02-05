# non-trivial-indicial-operators-macaulay2

## nonTrivialIndicialOperators -- attempt to compute non-trivial indicial operators of the GKZ-hypergeometric system $H_A(b)$ with respect to the weight vector $w$.

### Usage:

nonTrivialIndicialOperators(A,b,w,thetaRing)

### Inputs:

- A, a $d \times n$ homogeneous integer matrix,
- b, a list, parameter vector,
- w, a list, weight vector
- thetaRing, a polynomial ring, a stand-in for the subring $QQ[\theta_1..\theta_n]$ where $\theta_i$ denotes the Euler operator $x_i\partial_i$, in which the indicial operators are represented.

### Output:

- a list of non-trivial indicial operators (elements of thetaRing) of the GKZ-hypergeometric system $H_A(b)$ with respect to the weight vector $w$.

### Assumptions:

This function is designed for $(A,b,w)$ satisfying the following conditions:
1. All entries of the weight vector $w$ are non-negative integers, and $w$ is generic.
2. The indicial ideal of $H_A(b)$ with respect to $w$ is different from the fake indicial ideal of $H_A(b)$ with respect to $w$.
3. There exists a standard pair of the monomial ideal $\mathrm{in}_w(I_A)$ that is associated to $b$. Here $I_A$ is the toric ideal of $A$, and $\mathrm{in}_w(I_A)$ is the initial ideal of $I_A$ with respect to $w$.

### Notes

In several examples, I verified that the indicial operators computed by this function are non-fake.
On the other hand, I also found examples where some computed operators are fake.

The computation algorithm implemented in `nonTrivialIndicialOperators` follows the PDF document "Description of nonTrivialIndicialOperators".


## fakeIndicialIdeal -- get the fake indicial ideal of the GKZ-hypergeometric system $H_A(b)$ with respect to the weight vector $w$.

### Usage:

fakeIndicialIdeal(A,b,w,thetaRing)

### Inputs:

- A, a $d \times n$ homogeneous integer matrix,
- b, a list, parameter vector,
- w, a list, weight vector
- thetaRing, a polynomial ring, a stand-in for the subring $QQ[\theta_1..\theta_n]$ where $\theta_i$ denotes the Euler operator $x_i\partial_i$, in which the fake indicial ideal is represented.

### Output:

- the fake indicial ideal of the GKZ-hypergeometric system $H_A(b)$ with respect to the weight vector $w$.

### Assumption:

This function is designed for $(A,b,w)$ satisfying the following conditions:
1. All entries of the weight vector $w$ are non-negative integers, and $w$ is generic.


## Examples

### Loading the file

If you start Macaulay2 outside the repository directory, the command

`load "nonTrivialIndicialOperators.m2"`

may fail with the error "file not found on path". In that case, either move to the repository directory, or locate the file and load it by path:

`load first select(findFiles ".", f -> baseFilename f == "nonTrivialIndicialOperators.m2")`

### (1)

i1 : load"nonTrivialIndicialOperators.m2"

i2 : A = matrix{{1,1,1,1},{0,1,3,4}}

o2 = |1 1 1 1|

$\hspace{8.7mm}$ |0 1 3 4|

o2 :  Matrix $ZZ^2$ ⟵ $ZZ^4$
  
i3 : b = {2,6}

o3 =  {2,6} 

o3 :  List 

i4 : w = {0,0,2,1}

o4 =  {0,0,2,1} 

o4 :  List 

i5 : thetaRing = $QQ[\theta_1..\theta_4]$

o5 = thetaRing

o5 :  PolynomialRing

i6 : I = nonTrivialIndicialOperators(A,b,w,thetaRing)

o6 = { $9\theta_1^2\theta_4^2-9\theta_1^2\theta_4-9\theta_1\theta_4^2+9\theta_1\theta_4$ } 

o6 :  List

i7 : F = fakeIndicialIdeal(A,b,w,thetaRing)

o7 = ideal($\theta_2\theta_3, \theta_1^2\theta_3-\theta_1\theta_3, \theta_1\theta_3^2-\theta_1\theta_3, \theta_3^3-3\theta_3^2+2\theta_3, \theta_1^3\theta_4-3\theta_1^2\theta_4+2\theta_1\theta_4, \theta_1+\theta_2+\theta_3+\theta_4-2, \theta_2+3\theta_3+4\theta_4-6$)

o7 :  Ideal of thetaRing

i8 : isMember(I#0,F)

o8 =  false


### (2)

i1 : load"nonTrivialIndicialOperators.m2"

i2 : A = matrix{{1,1,1,1,1,1},{0,1,1,0,-1,-1},{-1,-1,0,1,1,0}}

o2 = |1 1 1 1 1 1|

$\hspace{8.7mm}$ |0 1 1 0 -1 -1|

$\hspace{8.7mm}$ |-1 -1 0 1 1 0|

o2 :  Matrix $ZZ^3$ ⟵ $ZZ^6$
  
i3 : b = {2,0,1}

o3 =  {2,0,1} 

o3 :  List 

i4 : w = {0,0,3,0,5,1}

o4 =  {0,0,3,0,5,1} 

o4 :  List 

i5 : thetaRing = $QQ[\theta_1..\theta_6]$

o5 = thetaRing

i6 : I = nonTrivialIndicialOperators(A,b,w,thetaRing)

o6 =  { $-2\theta_2\theta_6^2+2\theta_2\theta_6, -2\theta_2^2\theta_6+2\theta_2\theta_6, -4\theta_1\theta_4\theta_5, -3\theta_1\theta_3\theta_4$ } 

o6 :  List

i7 : F = fakeIndicialIdeal(A,b,w,thetaRing)

o7 =  ideal($\theta_3\theta_6, \theta_2\theta_5, \theta_1^2\theta_3-\theta_1\theta_3, \theta_1^2\theta_5-\theta_1\theta_5, \theta_1\theta_3^2-\theta_1\theta_3, \theta_1\theta_3\theta_5, \theta_1\theta_5^2-\theta_1\theta_5, \theta_3^2\theta_5-\theta_3\theta_5, \theta_3\theta_5^2-\theta_3\theta_5, \theta_2^2\theta_6^2-\theta_2^2\theta_6-\theta_2\theta_6^2+\theta_2\theta_6, \theta_1+\theta_2+\theta_3+\theta_4+\theta_5+\theta_6-2, \theta_2+\theta_3-\theta_5-\theta_6, -\theta_1-\theta_2+\theta_4+\theta_5-1$) 

o7 :  Ideal of thetaRing

i8 : for i from 0 to #I-1 list isMember(I#i,F)

o8 =  {false,false,false,false} 

o8 :  List
