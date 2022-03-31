% To be executed on Matlab
%You need to know the basics of TLM and advanced electromagnetism theories to understand this code
%Also be sure to read about energy irradiation and anthenas theory
%This code processes time and spacial coordinates, be sure to pay attention

%IF YOU WANT MORE INFORMATION, I HAVE A PAPER ABOUT IT, MESSAGE ME
%If you want anymore scientific references, look for Christopoulos and Faccioni Filho

clc
clear all

%Parameters
%The default parameters are based on general values that may be found
%for gate driver circuits of energy converters

l = 8e-2; %strip lenght
nt = 3; %number of nodes for the simulation
kt = 50; %number of iterations
RL = 4.7; %Load resistance (in this case, gate resistance of a MOSFET)
Rs = 50; %Source resistance (standard value for power sources)

%On instant K=1, all incident voltages are null
%VID: Incident right voltage
%VIE: Incident left voltage

for n=1:1:nt
    VID(n,1)=0;
    VIE(n,1)=0;
    VIC(1)=0;
end

%Applying transformations in the parameters
Dx = l/(nt-1); %Spacial increment related to the nodes number
L = 377e-6; %Inductance depends on your case (this value is general)
C = 88.48e-12; %Capacitance also depends on your case (this value is general)
R = 0; %Usually, resistance have a pretty low value compared to L and C, so we consider it as zero
Z0 = 90; %This number is obtained by calculating the Characteristic Impedance of a normal PCB, single layer
Dt = sqrt(L*C); %time step is also calculated with L and C parameters
f=500e3; %500KHz frequency


t=0:Dt:Dt*(kt-1) %Time array
SourceWave = 6+6*square(2*pi*t*f,50) %Square wave with 50% duty cicle

#Applying the source voltage wave at the Source node
 for k=1:1:kt
     Vs(k)=SourceWave(k)
 end


%Beginning time iteration

for k=1:1:kt
    
    %Calculating capacitance and impedance of the capacitor
        Csw = 5.4e-9
        ZC = Dt/(2*pi*f*Csw)
   
    %CALCULATING INCIDENCES
    
    %First node, connected to the source
    for n = 1
        if Rs == 0
            V(n,k)=Vs(k);
        else
            V(n,k)=((Vs(k)/Rs)+(2*VID(n,k)/(R+Z0)))/(1/Rs+1/(R+Z0))
        end
        I(n,k)=(V(n,k)-2*VID(n,k))/(R+Z0)
        VD(n,k)=2*VID(n,k)+I(n,k)*Z0
    end
    
    %Second to penultimate node
    
    for n=2:1:(nt-1)
        V(n,k)= (2*VIE(n,k)/Z0 + 2*VID(n,k)/(R+Z0))/(1/Z0 + 1/(R+Z0))
        I(n,k)= (V(n,k)-(2*VID(n,k)))/(R+Z0)
        VE(n,k)= V(n,k)
        VD(n,k)= 2*VID(n,k)+I(n,k)*Z0
    end
    
    %For the last node
    
    for n = nt
        V(n,k)= (2*VIE(n,k)/Z0 + 2*VIC(k)/(RL+ZC))/(1/Z0 + 1/(RL+ZC))
        IC(k)= (V(n,k)-2*VIC(k))/(RL+ZC)
        VC(k)= 2*VIC(k)+IC(k)*ZC
    end
    
    %CALCULATING THE REFLECTIONS
    
    %First node
    
    for n=1
        VRD(n,k)=VD(n,k)-VID(n,k)
    end
    
    %Second to penultimate node
    for n=2:1:(nt-1)
        VRD(n,k)=VD(n,k)-VID(n,k)
        VRE(n,k)=VE(n,k)-VIE(n,k)
    end
    
    %Last node
    for n= nt
        VRE(n,k)=V(n,k)-VIE(n,k)
        VRC(k)=VC(k)-VIC(k)
    end
    
    %CONNECTING THE VARIABLES TO THE NEXT TIME STEP
    
    %First node
    for n = 1
        VID(n,k+1)=VRE(n+1,k)
    end
    
    %Second to last node
    for n = 2:1:(nt-1)
        VIE(n,k+1)=VRD(n-1,k)
        VID(n,k+1)=VRE(n+1,k)
    end
    
    %Last node
    for n=nt
        VIE(n,k+1)=VRD(n-1,k)
        VIC(k+1)= -VRC(k)
    end
end

#Plotting the results
plot(t,V(nt,1:kt))
title('Last node voltage vs time')
xlabel('Time [s]')
ylabel('Voltage [V]')

figure
plot(t,VRC)
title('Reflected capacitor voltage')
xlabel('Time [s]')
ylabel('Voltage [V]')
