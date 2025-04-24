%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt0X_.....
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor
% - ...
% - ...
%
% Følgende motorer brukes:
% - motor A
% - ...
% - ...
%
%--------------------------------------------------------------------------



%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres 
filename = 'P06.mat';  % Data ved offline

if online
    % Initialiser styrestikke, sensorer og motorer. Dersom du bruker 
    % 2 like sensorer, må du initialisere med portnummer som argument som:
    % mySonicSensor_1 = sonicSensor(mylego,3);
    % mySonicSensor_2 = sonicSensor(mylego,4);
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);    
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

    k=k+1;      % oppdater tellevariabel

    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end

        % Sensorer, bruk ikke Lys(k) og LysDirekte(k) samtidig
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
    else
        % Når k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==length(Tid)
            JoyMainSwitch=1;
        end

        if plotting
            % Simulerer tiden som EV3-Matlab bruker på kommunikasjon 
            % når du har valgt "plotting=true" i offline
            pause(0.03)
        end
    end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger.
    

    % Tilordne målinger til variabler
    u(k) = Lys(k);

    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;  % nominell verdi
        a(1) = u(1);
        x(1) = u(1);

        v_1(1) = a(1);
        v_2(1) = x(1);
    else
        % Beregninger av T_s(k) og andre variable
        T_s(k) = Tid(k) - Tid(k-1);
        a(k) = (u(k)-u(k-1))/T_s(k);
        x(k) = x(k-1) + T_s(k)*(1/2)*(u(k-1)+u(k));


        v_1(k) = v_1(k-1) + T_s(k)*(1/2)*(a(k-1)+a(k));
        v_2(k) = (x(k)-x(k-1))/T_s(k);
    end


    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),måling(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % alle målingene (1:end) eksisterer i den lagrede .mat fila

    % Plotter enten i sann tid eller når forsøk avsluttes 
    if plotting || JoyMainSwitch  
        figure(fig1)

        subplot(4,1,1)
        plot(Tid(1:k), u(1:k), 'r');
        title('Original fart')
        hold on
        legend(['$v_k$'])
        hold off
        

        subplot(4,1,2)
        plot(Tid(1:k),a(1:k), 'r');
        hold on
        plot(Tid(1:k),v_1(1:k), 'b');
        title('Derivert og s{\aa} integrert')
        legend(['$a_k$'],['$v_{1,k}$'])
        hold off


        subplot(4,1,3)
        plot(Tid(1:k),x(1:k), 'r');
        hold on
        plot(Tid(1:k),v_2(1:k), 'g');
        title('Integrert og s{\aa} derivert')
        legend(['$x_k$'],['$v_{2,k}$'])
        hold off


        subplot(4,1,4)
        plot(Tid(1:k), u(1:k), 'r');
        title('Fart derivert/integrert frem og tilbake')
        hold on
        plot(Tid(1:k),v_1(1:k), 'b--');
        plot(Tid(1:k),v_2(1:k), 'g--');
        legend(['$v_k$'],['$v_{1,k}$'], ['$v_{2,k}$'])
        xlabel('Tid [sek]')
        hold off
        drawnow
    end
    %--------------------------------------------------------------
end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS
% if online
%     % For ryddig og oversiktlig kode, kan det være lurt å slette
%     % de sensorene og motoren som ikke brukes.
%     stop(motorA);
%     stop(motorB);
%     stop(motorC);
%     stop(motorD);
% 
% end
%------------------------------------------------------------------

%subplot(2,2,1)
%legend('$\{u_k\}$')


