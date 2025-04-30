%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt07 - Sykkelcomputer
%
% Hensikten med programmet er å simulere en sykkelcomputer som måler
% fart og avstand ved hjelp av en sensor og en styrestikke.
% Følgende sensorer brukes:
% - Styrestikke
%
% Følgende motorer brukes:
% - N/A
%
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%         EXPERIMENT SETUP, FILENAME AND FIGURE

clear; close all   % Alltid lurt å rydde workspace opp først
online = true;     % Online mot EV3 eller mot lagrede data?
plotting = true;  % Skal det plottes mens forsøket kjøres 
filename = 'xx';  % Data ved offline

if online
    % Initialiser styrestikke, sensorer og motorer. Dersom du bruker 
    % 2 like sensorer, må du initialisere med portnummer som argument som:
    % mySonicSensor_1 = sonicSensor(mylego,3);
    % mySonicSensor_2 = sonicSensor(mylego,4);
    
    % LEGO EV3 og styrestikke
    %mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    % myColorSensor = colorSensor(mylego);    
    % myTouchSensor = touchSensor(mylego);
    % mySonicSensor = sonicSensor(mylego);
    % myGyroSensor  = gyroSensor(mylego);
    % resetRotationAngle(myGyroSensor);

    % motorer
    % motorA = motor(mylego,'A');
    % motorA.resetRotation;
    % motorB = motor(mylego,'B');
    % motorB.resetRotation;
    % motorC = motor(mylego,'C');
    % motorC.resetRotation;
    % motorD = motor(mylego,'D');
    % motorD.resetRotation;
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
runde = 0;
fart = []; % Vektor for hastighet (passeringer per sekund)
TidPassering = []; %tidsvektor for tidspunkter når knappen trykkes
momentanhastighet = []; % Vektor for momentanhastighet
lavpass_hastighet = 0; % Lavpassfiltrert hastighet
gjennomsnitt_hastighet = 0; % Gjennomsnittshastighet
tilbakelagt_strekning = 0; % Total tilbakelagt strekning (i meter)
akselerasjon = 0; % Akselerasjon
forrigeJoyButton = 0; % Forrige verdi av JoyButtons(1)
hjulOmkrets = 2.1; % Omkretsen av hjulet i meter - tall fra Garmin tabell sitert i oppgaven
tidskonstant = 1.5; % Tidskonstant for lavpassfilter

% Initialisering av historikkvektorer
% disse benyttes for å lagre histiorikken for hveer beregning over tid (runde), og brukes for å
% holde oversikt over utviklen i variablene.
lavpass_hastighet_historisk = zeros(1, 1000); % Historikk for lavpassfiltrert hastighet
gjennomsnitt_hastighet_historisk = zeros(1, 1000); % Historikk for gjennomsnittshastighet
tilbakelagt_strekning_historisk = zeros(1, 1000); % Historikk for tilbakelagt strekning
akselerasjon_historisk = zeros(1, 1000); % Historikk for akselerasjon
eta_historisk = zeros(1, 1000); % Historikk for ETA


%----------------------------------------------------------------------

% Setter en total distanse som skal tilbakelegges.
% Her er det også mulig å spørre bruker om å oppgi ønsket distanse.
% Et typisk eksempel er ved bruk av GPS og brukeren har et destinasjonsmål.
% Dette kan skrives ved å kommentere ut: 
% destinasjonsmaal = input('Tast inn total distanse i m: ')
total_distanse = 60; % Distanse i meter


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

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(2); % Bryter på styrestikke
    else
        % Når k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==length(Tid)
            JoyMainSwitch=2;
        end
        Tid(k) = k *0.05; % Simulerer tid for offline

        if plotting
            % Simulerer tiden som EV3-Matlab bruker på kommunikasjon 
            % når du har valgt "plotting=true" i offline
            pause(0.03)
        end
    end
    %--------------------------------------------------------------

    % Dersom man ønsker at computeren skal stoppe etter eksempelvis 10 sekunder
    % Sjekk om tiden har nådd 10 sekunder
    % if Tid(k) >= 10
    %     disp('Tidsgrensen på 10 sekunder er nådd. Stopper skriptet.');
    %     break;
    % end

    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger.
    

    naaJoyButton = JoyButtons(1); % Henter nåverdien av knappen

    % Kantdeteksjon benyttes for å registrere når JoyButtons går fra 0 til 1, slik at vi kan registrere en runde/passering
    if naaJoyButton == 1 && forrigeJoyButton == 0
        % Oppdater runde og lagrer tidspunktet for passering
        runde = runde + 1;
        TidPassering(runde) = Tid(k);
    
        % Beregner momentanhastighet, den lavpassfiltrerte hastigheten, tilbakelagt strekning og akselerasjon
        if runde > 1
            delta_t = TidPassering(runde) - TidPassering(runde - 1); % Tidsintervall
            fart(runde) = 1 / delta_t; % Hastighet i passeringer per sekund
            momentanhastighet(runde) = hjulOmkrets / delta_t; % Hastighet i m/s
            tilbakelagt_strekning = runde*hjulOmkrets; % Oppdater strekning
    
            % Lavpassfiltrert hastighet
            alfa = 1 - exp(-delta_t / tidskonstant);
            lavpass_hastighet = alfa * momentanhastighet(runde) + (1 - alfa) * lavpass_hastighet;
    
            % Sjekker om runde er større enn 2, ettersom vi behøver minst to tidligere målinger av hastigheten
            % for å kunne beregne akselerasjonen. I tillegg benytter vi den lavpassfiltrerte hastigheten for å
            % minmere støyen i akselerasjonsberegningen. En risiko er at dersom delta er svært liten, vil vi få problemer 
            % med beregning av akselerasjonen ettersom divisjon med 0 gir udefinert verdi...
            
            if runde > 2
                akselerasjon = (lavpass_hastighet - lavpass_hastighet_prev) / delta_t; % Beregn akselerasjon
            end
    
            % Lagre forrige lavpassfiltrerte hastighet
            lavpass_hastighet_prev = lavpass_hastighet;
        else
            fart(runde) = 0; % Første passering har ingen hastighet
        end
    
        % Beregn gjennomsnittshastighet
        if TidPassering(runde) > 0
            gjennomsnitt_hastighet = tilbakelagt_strekning / TidPassering(runde);
        end
    
        % Beregn ETA
        gjenstaende_distanse = total_distanse - tilbakelagt_strekning;
        if gjennomsnitt_hastighet > 0
            ETA = gjenstaende_distanse / gjennomsnitt_hastighet; % ETA i sekunder
        else
            ETA = Inf; % Dersom hastigheten er 0, vi ikke beregne ETA
        end

        % Oppdaterer historikkvektorer oer runde
        lavpass_hastighet_historisk(runde) = lavpass_hastighet; %lagrer hastigheten per runde og for å få en jevnere kurve
        gjennomsnitt_hastighet_historisk(runde) = gjennomsnitt_hastighet; %lagrer gjennomsnittshastigheten per runde og for å vise hvordan denne utvikler seg over tid
        tilbakelagt_strekning_historisk(runde) = tilbakelagt_strekning; %lagrer tilbakelagt strekning per runde og vise hvordan strekningen utvikler seg over tid
        akselerasjon_historisk(runde) = akselerasjon; %lagrer akselerasjonen per runde og vise hvordan akselerasjonen endres over tid
        eta_historisk(runde) = ETA; % lagrer den oppdaterte ETA per runde og vise hvordan ETA utvikles over tid

        % Sjekker om tilbakelagt strekning er større eller lik den total distansen
        % skriver ut melding til bruker og avslutter løkken dersom det stemmer.
        if tilbakelagt_strekning >= total_distanse
            disp('Du er fremme!');
            break; % Avslutt løkken
        end
    end

    % Oppdaterer forrige knappetrykk, brukes til kantdeteksjon
    forrigeJoyButton = naaJoyButton;   

    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),måling(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % alle målingene (1:end) eksisterer i den lagrede .mat fila

    % Plotter enten i sann tid eller når forsøk avsluttes 
    if plotting || JoyMainSwitch  

        figure(fig1);

        % Momentanhastighet og lavpassfiltrert hastighet, må ha en if-setning her for å unngå errormelding
        % dersom det ikke er registrert noen passeringer
        subplot(3, 2, 1);
        if length(momentanhastighet) >= runde
            plot(0:(runde-1), momentanhastighet(1:runde), 'r-', 'LineWidth', 1.5); % Momentanhastighet
            hold on;
            plot(0:(runde-1), lavpass_hastighet_historisk(1:runde), 'g--', 'LineWidth', 1.5); % Lavpassfiltrert hastighet
            hold off;
            title('Hastighet');
            xlabel('Passering');
            ylabel('Hastighet [m/s]');
            legend('v', 'v, lavpassfiltrert');
            grid on;
        end
      
        % Gjennomsnittshastighet
        subplot(3, 2, 2);
        plot(0:(runde-1), gjennomsnitt_hastighet_historisk(1:runde), 'b-', 'LineWidth', 1.5); % Gjennomsnittshastighet
        title('Gjennomsnittshastighet');
        xlabel('Passering');
        ylabel('Gjennomsnittshastighet [m/s]');
        grid on;

        % Tilbakelagt strekning
        subplot(3, 2, 3);
        plot(0:(runde-1), tilbakelagt_strekning_historisk(1:runde), 'm-', 'LineWidth', 1.5); % Tilbakelagt strekning
        title('Tilbakelagt strekning');
        xlabel('Passering');
        ylabel('Strekning [m]');
        grid on;

        % Akselerasjon
        subplot(3, 2, 4);
        plot(1:runde, akselerasjon_historisk(1:runde), 'k-', 'LineWidth', 1.5); % Akselerasjon
        title('Akselerasjon');
        xlabel('Passering');
        ylabel('Akselerasjon [m/s^2]', 'Interpreter', 'Latex');
        grid on;

        % ETA per runde
        subplot(3, 2, 5);
        plot(0:(runde-1), eta_historisk(1:runde), 'c-', 'LineWidth', 1.5); % ETA
        title('ETA - estimert tid til m{\aa}l');
        xlabel('Passering');
        ylabel('ETA [sek]');
        grid on;

        % tegn nå (viktig kommando)
        drawnow
    end
    %--------------------------------------------------------------
end