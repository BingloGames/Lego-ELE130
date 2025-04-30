%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P03_NumeriskDerivasjonStigningstall
%
% Hensikten med programmet er å numerisk derivere filtrert 
% målesignal u_{f,k} som representere avstandsmåling [m]
% til å beregne v_{f,k} som fart [km/t]
% 
% Følgende sensorer brukes:
% - Ultralydsensor
% - Bryter
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;    % Online mot EV3 eller mot lagrede data?
plotting = false;   % Skal det plottes mens forsøket kjøres 
filename = 'P03_sinus_filtrert.mat'; 

if online

    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
    
    % sensorer
    mySonicSensor = sonicSensor(mylego);
    myTouchSensor = touchSensor(mylego);
    
else
    % Dersom online=false lastes datafil. 
    load(filename)
end

fig1=figure;
%set(gcf,'Position',[.., .., .., ..])
drawnow

% setter skyteknapp til 0, og initialiserer tellevariabel k
JoyMainSwitch=0;
k=0;
%----------------------------------------------------------------------



while ~JoyMainSwitch

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick

    % oppdater tellevariabel
    k=k+1;
    
    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end
        
        % sensorer
        Avstand(k) = double(readDistance(mySonicSensor));
        Bryter(k)  = double(readTouch(myTouchSensor));
           
        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    else
        % online=false
        % Naar k er like stor som antall elementer i datavektpren Tid,
        % simuleres det at bryter paa styrestikke trykkes inn.
        if k==numel(Tid)
            JoyMainSwitch=1;
        end
       
        if plotting
            % Simulerer tiden som EV3-Matlab bruker på kommunikasjon 
            % når du har valgt "plotting=true" i offline
            pause(0.03)
        end

    end
    
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger.
   
    % Tilordne målinger til variabler
    u(k) = 100*Avstand(k);        
 
    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.01;  % nominell verdi
        u_f(1) = u(1);
        v(1) = 0;
        v_f(1) = 0;
        

    else
        % beregner tidsskritt
        T_s(k) = Tid(k) - Tid(k-1);
        knekkfrekvens = 0.32;
        tidskonstant = 1/(2*pi*knekkfrekvens);
        alfa = 1-exp(-T_s(k)/tidskonstant);

        % beregner u_f(k) og v_f(k)
        u_f(k) = (1-alfa)*u_f(k-1) + alfa*u(k);
        v_f(k) = (u_f(k)-u_f(k-1))/T_s(k);
        

    end

    U = 6.4;
    omega = 2*pi/3;
    V = U*omega;
    C = 10.5;
    phi = pi/2;

    u_f2 = U*sin(omega*Tid) + C;
    v_f2 = V*sin(omega*Tid+phi);
    
    
    %--------------------------------------------------------------


    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % for gir samme opplevelse i online=true og online=false siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    legend_uf2 = sprintf('$u_f(k) = %.2f \\sin(%.2f t)$', U, omega);
    
    % Plotter enten i sann tid eller når forsøk avsluttes
    if plotting || JoyMainSwitch
        subplot(2,1,1)
        plot(Tid(1:k),u_f(1:k),'b-');
        hold on
        plot(Tid(1:k),u_f2(1:k),'r-');
        hold off
        grid

        title('Avstandsm\aa ling', 'Interpreter', 'latex')
        ylabel('[$m$]')
        legend('$\{u_f\}$', legend_uf2, 'Interpreter', 'latex')

        legend_vf2 = sprintf('$v_f(k) = %.2f \\cdot \\sin(%.2f t + \\pi / 2)$', V, omega);

        subplot(2,1,2)
        plot(Tid(1:k),v_f(1:k),'b-');
        hold on
        plot(Tid(1:k),v_f2(1:k),'r-');
        hold off
        grid
        title('Hastighet')
        ylabel('[$m/s$]')
        legend('$\{v_f\}$', legend_vf2, 'Interpreter', 'latex')



        % tegn naa (viktig kommando)
        drawnow
        %--------------------------------------------------------------
    end        
end
FrekvensSpekterSignal(u_f, Tid, 'signal u_f')


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%           STOP MOTORS

if online

end
%------------------------------------------------------------------

%subplot(2,1,1)
%legend('$\{u_k\}$')
%subplot(2,1,2)
%legend('brytersignal')

