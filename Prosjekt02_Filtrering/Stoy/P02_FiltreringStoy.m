%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P02_FiltreringStoy
%
% Hensikten med programmet er å lavpassfiltrere målesignalet u_k som
% representere temperaturmåling [C]
% 
% Følgende sensorer brukes:
% - Lyssensor
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres
filename = 'P02_LysTid_Stoy_filtrert_med_stoy.mat'; 

if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);
    
    % motorer

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

        % Data fra styrestikke. 
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        
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
        y_lav(1) = u(1);
        y_hoy(1) = 0;
    else
        % Beregninger av T_s(k) og andre variable
        T_s(k) = Tid(k)-Tid(k-1);


        %knekk_frekvense = 1; %endre til riktig verdi

        %hoypass filter -------------------------
        knekkfrekvens = 0.6;
        tidskonstant = 1/(2*pi*knekkfrekvens);


        alfa_hoy = exp(-T_s(k)/tidskonstant);
        y_hoy(k) = (alfa_hoy*y_hoy(k-1))+alfa_hoy*(u(k)-u(k-1));

        %lavpass filter --------------------
        alfa_lav = 1-exp(-T_s(k)/tidskonstant);


        y_lav(k) = (1-alfa_lav)*y_lav(k-1)+alfa_lav*u(k);
    end


    %--------------------------------------------------------------


    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    % Plotter enten i sann tid eller når forsøk avsluttes
    if plotting || JoyMainSwitch
        %subplot(2,1,1)
        plot(Tid(1:k),u(1:k),'b-');
        hold on
        plot(Tid(1:k),y_hoy(1:k),'r-');
        plot(Tid(1:k),y_lav(1:k),'k-');
        title('Lavpass og h{\o}ypass filter')
        legend(['u(k)'], ['$y_{h{\o}y}$ h{\o}ypassfiltrert, $f_c =', num2str(knekkfrekvens),'$'], ['$y_{lav}$ lavpassfiltrert, $f_c =', num2str(knekkfrekvens),'$'])
        hold off

        
        %legend('temperatur Vist')

        % tegn nå (viktig kommando)
        drawnow
    end
    %--------------------------------------------------------------

end


%legend('$\{u_k\}

%subplot(2,1,2)

%[frekvens, spekter] = FrekvensSpekterSignal(u,Tid);


%plot(frekvens, spekter)