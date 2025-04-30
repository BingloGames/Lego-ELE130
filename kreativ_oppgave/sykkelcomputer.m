%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt07
%
% Hensikten med programmet er å simulere en sykkelcomputer som måler
% fart og avstand ved hjelp av en sensor og en styrestikke.
% Følgende sensorer brukes:
% - Lyssensor
% - Styrestikke
%
% Følgende motorer brukes:
% - N/A
%
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = false;     % Online mot EV3 eller mot lagrede data?
plotting = true;  % Skal det plottes mens forsøket kjøres 
filename = 'P03_sinus.mat';  % Data ved offline

if online
    % Initialiser styrestikke, sensorer og motorer

    
    % LEGO EV3 og styrestikke
    % mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    % myColorSensor = colorSensor(mylego);    
    % myTouchSensor = touchSensor(mylego);
    % mySonicSensor = sonicSensor(mylego);
    % myGyroSensor  = gyroSensor(mylego);
    % resetRotationAngle(myGyroSensor);
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


%initialisering av variabler
runde = []; %teller for knappetrykk
TidPassering = []; %tidsvektor for tidspunkter når knappen trykkes
% distance_traveled = 0; %total avstand tilbakelagt
% finishing_distance = input('Tast inn total distanse i cm: ') %bruker taster inn total distanse
% speed = 0; %nåværende hastighet

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

       
    else
        %simuler offline
        if k == length(Tid)
            JoyMainSwitch = 1;
        end

        if plotting
            pause(0.03);
        end
    end
  
    % else
    %     % Når k er like stor som antall elementer i datavektoren Tid,
    %     % simuleres det at bryter på styrestikke trykkes inn.
    %     if k==length(Tid)
    %         JoyMainSwitch=1;
    %     end

    %     if plotting
    %         % Simulerer tiden som EV3-Matlab bruker på kommunikasjon 
    %         % når du har valgt "plotting=true" i offline
    %         pause(0.03)
    %     end
    % end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger.
    

    % Tilordne målinger til variabler
    % u(k) = Lys(k);

    % if k==1
    %     % Spesifisering av initialverdier og parametere
    %     T_s(1) = 0.05;  % nominell verdi
    %     a = 1;          % eksempelparameter
    % else
    %     % Beregninger av T_s(k) og andre variable

    % end

    % Sensorer, bruk ikke Lys(k) og LysDirekte(k) samtidig
    % Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
    % distance_traveled = distance_traveled + 1; %oppdaterer total avstand
    % speed = 1 /Tid(k); %beregner hastighet i cm/s (1 cm per tick)

    % if distance_traveled >= finishing_distance %sjekker om total avstand er nådd
    %     disp('Mål oppnådd!')
    %     break
    % end

    %estimere ETA
    % remaining_distance = finishing_distance - distance_traveled; %gjenværende avstand
    % if speed > 0
    %     eta = remaining_distance / speed; %gjenstående tid i sekunder
    % else
    %     eta = Inf; %hvis hastighet er 0, sett eta til uendelig
    % end

    % %display ETA
    % fprintf('Estimert tid til mål: %.2f sekunder\n', eta);

    % beregner tidsskritt
    T_s(k) = Tid(k) - Tid(k-1);

    %u_f(k) = (1-alfa)*u_f(k-1) + alfa*u(k);
    
    %hastighetsberegning
    v(k) = (u(k)-u(k-1))/T_s(k);
    v_f(k) = (u_f(k)-u_f(k-1))/T_s(k);

    if JoyButtons(1)
        runde = runde + 1; %teller opp antall trykk
        TidPassering(runde) = Tid(k); %lagrer tid for hvert trykk
        fart(runde);
    end

    % %--------------------------------------------------------------


    phi = pi/2;
    omega = 2;
    v_f2 = V*sin(omega*Tid+phi);

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),måling(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % alle målingene (1:end) eksisterer i den lagrede .mat fila

    % Plotter enten i sann tid eller når forsøk avsluttes
    if plotting || JoyMainSwitch
        % subplot(2,1,1)
        % plot(Tid(1:k),u_f(1:k),'b-');
        % hold on
        % plot(Tid(1:k),u_f2(1:k),'r-');
        % hold off
        % grid

        % title('Avstandsm\aa ling', 'Interpreter', 'latex')
        % ylabel('[$m$]')
        % legend('$\{u_f\}$', legend_uf2, 'Interpreter', 'latex')

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
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS
if online
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.
    % stop(motorA);
    % stop(motorB);
    % stop(motorC);
    % stop(motorD);

end
%------------------------------------------------------------------

subplot(2,2,1)
legend('$\{u_k\}$')


