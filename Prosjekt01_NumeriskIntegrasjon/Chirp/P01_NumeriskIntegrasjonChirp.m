%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% P01_NumeriskIntegrasjonKonstant
%
% Hensikten med programmet er å numerisk integrere målesignal u_k som
% representere strømning [cl/s] til å beregne y_k som volum [cl]
% 
% Følgende sensorer brukes:
% - Lyssensor
%--------------------------------------------------------------------------

%110
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = false;  % Skal det plottes mens forsøket kjøres
filename = 'P01_chirp_justert.mat';


padrag_start = 20;
padrag = padrag_start;


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
            if Tid(k) > 2
                padrag = padrag + (100/13)*(Tid(k)-Tid(k-1));
            end
        end

        % sensorer
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        VinkelPosMotorA(k) = double(motorA.readRotation);

        % Data fra styrestikke. 
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
    LysInit = 21;
    u(k) = Lys(k);

    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;  % nominell verdi
        y(1) = u(1);
    else
        % Beregninger av T_s(k) og andre variable
        T_s(k) = Tid(k)-Tid(k-1);
        y(k) = y(k-1) + T_s(k)*(1/2)*(u(k-1)+u(k));

    end

    % beregning av pådrag fra styrestikken
    %u_A(k) = JoyForover(k);

    if online
        % Setter pådragsdata mot EV3
        % (slett de motorene du ikke bruker)
        motorA.Speed = padrag;%u_A(k);
        start(motorA)
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
        subplot(2,1,1)
        plot(Tid(1:k),u(1:k));
        title('Vann str{\o}m in/ut av ballongen')
        ylabel('Vann [cl/s]')

        subplot(2,1,2)
        plot(Tid(1:k),y(1:k));
        title('Ballong volum')
        xlabel('Tid [sek]')
        ylabel('Vann [cl]')

        % tegn nå (viktig kommando)
        drawnow
    end
    %--------------------------------------------------------------

end


if online
    % For ryddig og oversiktlig kode, er det lurt aa slette
    % de sensorene og motoren som ikke brukes.
    stop(motorA);
end
