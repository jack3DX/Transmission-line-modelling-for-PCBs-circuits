% Programa feito como parte do Trabalho de Conclus�o de Curso submetido ao
% departamento de Engenharia El�trica do Centro de Ci�ncias Tecnol�gicas
% da Universidade do Estado de Santa Catarina.

clc
clear all

%Dados do problema

l = 8e-2; %comprimento da linha
nt = 3; %numero de nos
kt = 50; %n�mero de itera��es
RL = 4.7; %Resistencia da carga (neste caso, a resist�ncia de gate)
Rs = 50; %Resistencia da fonte (considerando um padr�o encontrado durante o curso)

%No instante K=1, todas as tensoes incidentes s�o nulas

for n=1:1:nt
    VID(n,1)=0;
    VIE(n,1)=0;
    VIC(1)=0;
end

%Calculo de parametros da linha
Dx = l/(nt-1); %Incremento espacial em rela��o ao n�mero de n�s
L = 377e-6; %L e C foram obtidos atrav�s dos c�lculos apresentados 
C = 88.48e-12; 
R = 0; %Utilizou-se a resist�ncia medida na trilha
Z0 = 90; %Encontrada atrav�s dos c�lculos
Dt = sqrt(L*C);
f=500e3; %Frequencia de 500KHz


t=0:Dt:Dt*(kt-1) %Vetor de tempo
Excitacao = 6+6*square(2*pi*t*f,50) %Onda quadrada com duty cicle de 50%

 for k=1:1:kt
     Vs(k)=Excitacao(k)
 end


%Inicio da itera��o no tempo

for k=1:1:kt
    
    %C�lculo da capacit�ncia e imped�ncia do capacitor
        Csw = 5.4e-9
        ZC = Dt/(2*pi*f*Csw)
   
    %C�LCULO DAS INCID�NCIAS
    
    %Primeiro n�, junto � fonte
    for n = 1
        if Rs == 0
            V(n,k)=Vs(k);
        else
            V(n,k)=((Vs(k)/Rs)+(2*VID(n,k)/(R+Z0)))/(1/Rs+1/(R+Z0))
        end
        I(n,k)=(V(n,k)-2*VID(n,k))/(R+Z0)
        VD(n,k)=2*VID(n,k)+I(n,k)*Z0
    end
    
    %Segundo ao pen�ltimo n�
    
    for n=2:1:(nt-1)
        V(n,k)= (2*VIE(n,k)/Z0 + 2*VID(n,k)/(R+Z0))/(1/Z0 + 1/(R+Z0))
        I(n,k)= (V(n,k)-(2*VID(n,k)))/(R+Z0)
        VE(n,k)= V(n,k)
        VD(n,k)= 2*VID(n,k)+I(n,k)*Z0
    end
    
    %Para o �ltimo n�
    
    for n = nt
        V(n,k)= (2*VIE(n,k)/Z0 + 2*VIC(k)/(RL+ZC))/(1/Z0 + 1/(RL+ZC))
        IC(k)= (V(n,k)-2*VIC(k))/(RL+ZC)
        VC(k)= 2*VIC(k)+IC(k)*ZC
    end
    
    %C�LCULO DAS REFLEX�ES
    
    %Primeiro n�
    
    for n=1
        VRD(n,k)=VD(n,k)-VID(n,k)
    end
    
    %Segundo ao pen�ltimo n�
    for n=2:1:(nt-1)
        VRD(n,k)=VD(n,k)-VID(n,k)
        VRE(n,k)=VE(n,k)-VIE(n,k)
    end
    
    %�ltimo n�
    for n= nt
        VRE(n,k)=V(n,k)-VIE(n,k)
        VRC(k)=VC(k)-VIC(k)
    end
    
    %CONEX�O COM O MOMENTO SEGUINTE
    
    %Primeiro n�
    for n = 1
        VID(n,k+1)=VRE(n+1,k)
    end
    
    %Segundo ao pen�ltimo n�
    for n = 2:1:(nt-1)
        VIE(n,k+1)=VRD(n-1,k)
        VID(n,k+1)=VRE(n+1,k)
    end
    
    %�ltimo n�
    for n=nt
        VIE(n,k+1)=VRD(n-1,k)
        VIC(k+1)= -VRC(k)
    end
end

plot(t,V(nt,1:kt))
title('Tens�o no �ltimo n� em rela��o ao tempo')
xlabel('Tempo [s]')
ylabel('Tens�o [V]')

figure
plot(t,VRC)
title('Tensao refletida pelo capacitor')
xlabel('Tempo[s]')
ylabel('Tens�o[V]')