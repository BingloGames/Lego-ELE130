%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt00_TestOppkopling
%
% Hensikten med programmet er å teste at opplegget fungerer på PC/Mac
% Følgende sensorer brukes:
% - Lyssensor
%
% Følgende motorer brukes:
% - motor A
%
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = true;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres 
filename = 'P00_test.mat';

if online

    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);

    % motorer
    motorA = motor(mylego,'A');
    motorA.resetRotation;
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
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);

        % Data fra styrestikke. Utvid selv med andre knapper og akser
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
    x(k) = VinkelPosMotorA(k);

    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;  % nominell verdi
        r(1) = u(1);    % første lysmåling er referanse
    else
        % Beregninger av T_s(k) og andre variable
        T_s(k) = Tid(k) - Tid(k-1); 
        r(k) = r(1);    % fast referanse
    end

    % beregning av pådrag fra styrestikken
    u_A(k) = JoyForover(k);

    if online
        % Setter pådragsdata mot EV3
        % (slett de motorene du ikke bruker)
        motorA.Speed = u_A(k);
        start(motorA)
    end
    %--------------------------------------------------------------


    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),variabel(1:k))
    % gir samme opplevelse i online=false og online=true siden
    % alle målingene (1:end) eksisterer i den lagrede .mat fila

    % For å demonstrere effekten av plotting på tidsskrittet Ts
    TidStartPlotting = 6;  % sekunder
    if Tid(k) > TidStartPlotting
        plotting = true;
    end

    % Plotter enten i sann tid eller når forsøk avsluttes 
    if plotting || JoyMainSwitch  
        figure(fig1)
        subplot(2,2,1)
        plot(Tid(1:k),u_A(1:k));
        title('P{\aa}drag motor A')
        ylabel('$[-]$')

        subplot(2,2,2)
        plot(Tid(1:k),x(1:k));
        title('Vinkelposisjon motor A')
        ylabel('$[^{\circ}]$')

        subplot(2,2,3)
        plot(Tid(1:k),r(1:k),'r');
        hold on
        plot(Tid(1:k),u(1:k),'b');
        hold off   % viktig for å slippe figuren
        xlabel('Tid [sek]')
        ylabel('$[-]$')
        title('Referanse og lysm{\aa}ling')

        subplot(2,2,4)
        plot(Tid(1:k),T_s(1:k));
        xlabel('Tid [sek]')
        ylabel('[s]')
        title('Tidsskritt $T_s$')

        % tegn naa (viktig kommando)
        drawnow
    end
    %--------------------------------------------------------------
end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                STOP MOTORS

if online
    % For ryddig og oversiktlig kode, er det lurt aa slette
    % de sensorene og motoren som ikke brukes.
    stop(motorA);
end

subplot(2,2,4)
% plasserer en tekst ved tidspunkt hvor plotting starer
text(TidStartPlotting,max(T_s),'Plotting starter')
%------------------------------------------------------------------





