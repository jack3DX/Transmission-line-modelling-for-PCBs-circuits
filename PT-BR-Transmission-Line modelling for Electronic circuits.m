%Desenvolvido para Matlab
%Você precisa entender o básico da Teoria de Linhas de Transmissão e eletromagnetismo avançado para entender esse código
%Também é necessário ler sobre irradiação de energia e a teoria de antenas
%O código processa coordenadas espaciais e temporais, fique atento

%CONTATE-ME PARA MAIS INFORMAÇÕES
%Se quiser mais referências cientificas, procure por Christopoulos and Faccioni Filho

clc
clear all

%Dados do problema

l = 8e-2; %comprimento da linha
nt = 3; %numero de nos
kt = 50; %número de iterações
RL = 4.7; %Resistencia da carga (neste caso, a resistência de gate)
Rs = 50; %Resistencia da fonte (considerando um padrão encontrado comercialmente)

%No instante K=1, todas as tensoes incidentes são nulas

for n=1:1:nt
    VID(n,1)=0;
    VIE(n,1)=0;
    VIC(1)=0;
end

%Calculo de parametros da linha
Dx = l/(nt-1); %Incremento espacial em relação ao número de nós
L = 377e-6; %L é um numero generalizado de acordo com dados de placa
C = 88.48e-12; %C é um numero generalizado de acordo com dados de placa
R = 0; %Resistencia é baixissima comparada a L e C, considerou-se zero
Z0 = 90; %Através do calculo da impedancia caracteristica
Dt = sqrt(L*C); %Incremento do vetor de tempo de acordo com a ressonancia de L e C
f=500e3; %Frequencia de 500KHz


t=0:Dt:Dt*(kt-1) %Vetor de tempo
Excitacao = 6+6*square(2*pi*t*f,50) %Onda quadrada com duty cicle de 50%

 for k=1:1:kt
     Vs(k)=Excitacao(k)
 end


%Inicio da iteração no tempo

for k=1:1:kt
    
    %Cálculo da capacitância e impedância do capacitor
        Csw = 5.4e-9
        ZC = Dt/(2*pi*f*Csw)
   
    %CÁLCULO DAS INCIDÊNCIAS
    
    %Primeiro nó, junto à fonte
    for n = 1
        if Rs == 0
            V(n,k)=Vs(k);
        else
            V(n,k)=((Vs(k)/Rs)+(2*VID(n,k)/(R+Z0)))/(1/Rs+1/(R+Z0))
        end
        I(n,k)=(V(n,k)-2*VID(n,k))/(R+Z0)
        VD(n,k)=2*VID(n,k)+I(n,k)*Z0
    end
    
    %Segundo ao penúltimo nó
    
    for n=2:1:(nt-1)
        V(n,k)= (2*VIE(n,k)/Z0 + 2*VID(n,k)/(R+Z0))/(1/Z0 + 1/(R+Z0))
        I(n,k)= (V(n,k)-(2*VID(n,k)))/(R+Z0)
        VE(n,k)= V(n,k)
        VD(n,k)= 2*VID(n,k)+I(n,k)*Z0
    end
    
    %Para o último nó
    
    for n = nt
        V(n,k)= (2*VIE(n,k)/Z0 + 2*VIC(k)/(RL+ZC))/(1/Z0 + 1/(RL+ZC))
        IC(k)= (V(n,k)-2*VIC(k))/(RL+ZC)
        VC(k)= 2*VIC(k)+IC(k)*ZC
    end
    
    %CÁLCULO DAS REFLEXÕES
    
    %Primeiro nó
    
    for n=1
        VRD(n,k)=VD(n,k)-VID(n,k)
    end
    
    %Segundo ao penúltimo nó
    for n=2:1:(nt-1)
        VRD(n,k)=VD(n,k)-VID(n,k)
        VRE(n,k)=VE(n,k)-VIE(n,k)
    end
    
    %Último nó
    for n= nt
        VRE(n,k)=V(n,k)-VIE(n,k)
        VRC(k)=VC(k)-VIC(k)
    end
    
    %CONEXÃO COM O MOMENTO SEGUINTE
    
    %Primeiro nó
    for n = 1
        VID(n,k+1)=VRE(n+1,k)
    end
    
    %Segundo ao penúltimo nó
    for n = 2:1:(nt-1)
        VIE(n,k+1)=VRD(n-1,k)
        VID(n,k+1)=VRE(n+1,k)
    end
    
    %Último nó
    for n=nt
        VIE(n,k+1)=VRD(n-1,k)
        VIC(k+1)= -VRC(k)
    end
end

%Plot dos resultados
plot(t,V(nt,1:kt))
title('Tensão no último nó em relação ao tempo')
xlabel('Tempo [s]')
ylabel('Tensão [V]')

figure
plot(t,VRC)
title('Tensao refletida pelo capacitor')
xlabel('Tempo [s]')
ylabel('Tensão [V]')
