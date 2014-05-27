Contributed by:
	Favoreel
	KULeuven
	Departement Electrotechniek ESAT/SISTA
	Kardinaal Mercierlaan 94
	B-3001 Leuven
	Belgium
	wouter.favoreel@esat.kuleuven.ac.be

Description:

The process is a test setup of an industrial winding process.
The main part of the plant is composed of a plastic web that 
is unwinded from first reel (unwinding reel), goes over the 
traction reel and is finally rewinded on the the rewinding reel.
Reel 1 and 3 are coupled with a DC-motor that is controlled with 
input setpoint currents I1* and I3*. The angular speed of 
each reel (S1, S2 and S3) and the tensions in the web between
reel 1 and 2 (T1) and between reel 2 and 3 (T3) are measured
by dynamo tachometers and tension meters. 
We thank Th. Bastogne from the University of Nancy for 
providing us with these data.

We are grateful to Thierry Bastogne of the Universite Henri Point Care, who
provided us with these data.
   

Sampling: 0.1 Sec

Number: 2500

Inputs:  u1: The angular speed of reel 1 (S1)
	 u2: The angular speed of reel 2 (S2)
	 u3: The angular speed of reel 3 (S3)
	 u4: The setpoint current at motor 1 (I1*)
	 u5: The setpoint current at motor 2 (I3*)

Outputs: y1: Tension in the web between reel 1 and 2 (T1)
	 y2: Tension in the web between reel 2 and 3 (T3)

References:

	- Bastogne T., Identification des systemes multivariables par 
	les methodes des sous-espaces. Application a un systeme 
	d'entrainement de bande. PhD thesis. These de doctorat
	de l'Universite Henri Poincare, Nancy 1.

	- Bastogne T., Noura H., Richard A., Hittinger J.M., 
	Application of subspace methods to the identification of a 
	winding process. In: Proc. of the 4th European Control 
	Conference, Vol. 5, Brussels.

Properties:

Columns:
	Column 1: input u1
	Column 2: input u2
	Column 3: input u3
	Column 4: input u4
	Column 5: input u5
	Column 6: output y1
	Column 7: output y2

Category:

	Industrial test setup


