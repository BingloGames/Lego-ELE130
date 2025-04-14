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
filename = 'hassan_ny.mat';  % Data ved offline

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
    % myTouchSensor = touchSensor(mylego);
    mySonicSensor = sonicSensor(mylego);
    myGyroSensor  = gyroSensor(mylego);
    % resetRotationAngle(myGyroSensor);

    % motorer
    % motorA = motor(mylego,'A');
    % motorA.resetRotation;
    motorB = motor(mylego,'B');
    motorB.resetRotation;
    motorC = motor(mylego,'C');
    motorC.resetRotation;
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
        % LysDirekte(k) = double(readLightIntensity(myColorSensor));
        % Bryter(k)  = double(readTouch(myTouchSensor));
        Avstand(k) = double(readDistance(mySonicSensor));
        % 
        % Bruk ikke GyroAngle(k) og GyroRate(k) samtidig
        GyroAngle(k) = double(readRotationAngle(myGyroSensor));
        % GyroRate(k)  = double(readRotationRate(myGyroSensor));
        %
        % VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);
        VinkelPosMotorC(k) = double(motorC.readRotation);
        % VinkelPosMotorD(k) = double(motorC.readRotation);

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoySide(k) = JoyAxes(1); % side
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
    y(k) = Lys(k);
    r(k) = Lys(1);
    e(k) = r(k)- y(k);

    if k==1
        % Spesifisering av initialverdier og parametere
        T_s(1) = 0.05;  % nominell verdi
        iae(1) = abs(e(1));
        mae(1) = abs(e(1));

        a = 0.5; 
        b = 0.5;% eksempelparameter
        c = 0.5;
        d = -0.5;
    else
        % Beregninger av T_s(k) og andre variable
        T_s(k) = Tid(k) - Tid(k-1);
        

        iae(k) = iae(k-1) + T_s(k)*(1/2)*(abs(e(k-1))+abs(e(k)));
        

        absolut_sum = 0;
        for i = 1:k
            absolut_sum = absolut_sum + abs(e(i));
        end
        mae(k) = absolut_sum/k;
        
    end

    
    


    % Andre beregninger som ikke avhenger av initialverdi


    
    


    % Pådragsberegninger
    

    if online
        if y(k) > 50
           %stop(motorA);
           stop(motorB);
           stop(motorC);
           %stop(motorD);
           %error("for lyst")
           return
        end
        % Setter pådragsdata mot EV3
        % (slett de motorene du ikke bruker)
        %motorA.Speed = u_A(k);
        %u_A(k) = a*JoyForover(k);
        u_B(k) = b*JoyForover(k)+a*JoySide(k);
        u_C(k) = c*JoyForover(k)+d*JoySide(k);
        %u_D(k) = d*JoySide(k);



        motorB.Speed = u_B(k);
        motorC.Speed = u_C(k);
       % motorD.Speed = u_D(k);

        %start(motorA)
        start(motorB)
        start(motorC)
       % start(motorD)
    end
    %--------------------------------------------------------------

    
    padrag_c_sum = 0;
    padrag_b_sum = 0;
    for i = 2:k
        padrag_b_sum = padrag_b_sum + abs(u_B(i)-u_B(i-1));
        padrag_c_sum = padrag_c_sum + abs(u_C(i)-u_C(i-1));
    end
    
    tvb(k) = padrag_b_sum;
    tvc(k) = padrag_c_sum;


    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    %
    % Husk at syntaksen plot(Tid(1:k),måling(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % alle målingene (1:end) eksisterer i den lagrede .mat fila

    % Plotter enten i sann tid eller når forsøk avsluttes 
    if plotting || JoyMainSwitch  
        figure(fig1)

        subplot(3,2,1)
        plot(Tid(1:k),Lys(1:k));
        hold on
        plot(Tid(1:k), r(1:k));
        title('Lys reflektert og referanse')
        xlabel('Tid [sek]')
        legend(['$y_k$'], ['$r_k$'])
        hold off


        subplot(3,2,2)
        plot(Tid(1:k),e(1:k));
        hold on
        title('Reguleringsavvik')
        xlabel('Tid [sek]')
        legend('$e_k$')
        hold off


        subplot(3,2,3)
        plot(Tid(1:k),mae(1:k));
        hold on
        title('MAE')
        xlabel('Tid [sek]')
        legend('$MAE_k$')
        hold off


        subplot(3,2,4)
        plot(Tid(1:k),iae(1:k));
        hold on
        title('IAE')
        xlabel('Tid [sek]')
        legend('$IAE_k$')
        hold off


        subplot(3,2,5)
        plot(Tid(1:k),u_B(1:k));
        hold on
        plot(Tid(1:k),u_C(1:k));
        title('P{\aa}drag motor B og motor C')
        xlabel('Tid [sek]')
        legend(['$u_{B,k}$'], ['$u_{C,k}$'])
        hold off
        


        subplot(3,2,6)
        plot(Tid(1:k),tvb(1:k));
        hold on
        plot(Tid(1:k),tvc(1:k));
        title('Total Variation')
        xlabel('Tid [sek]')
        legend(['$TV_{B,k}$'], ['$TV_{C,k}$'])
        hold off
        

        % tegn nå (viktig kommando)
        drawnow
    end
    %--------------------------------------------------------------
end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS
if online
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.
    %stop(motorA);
    stop(motorB);
    stop(motorC);
    %stop(motorD);

end

middel_ts = mean(T_s)
return
%------------------------------------------------------------------
%subplot(2,2,1)
%legend('$\{u_k\}$')
fil_navn = cell(3,1);
fil_navn{1} = "sebastian_ny.mat";
fil_navn{2} = "frederik_ny.mat";
fil_navn{3} = "hassan_ny.mat";

for i = 1:3
    load(string(fil_navn(i)));
    y = Lys;

    middel_y = mean(y);
    standardavvik_y = std(y);
    
    
    subplot(3,1,i)
    x_prop = histogram(y, length(y));
    axis([0, 60, 0, inf])
    hold on
    
    
    xline(middel_y, 'r', 'LineWidth', 3)
    plot([middel_y, middel_y+standardavvik_y], [3, 3], 'g', LineWidth=3)
    
    
    legend('Lys {$y_k$}', ['Middelverdi $\bar{y}$ = ', num2str(middel_y)], ['Standardavvik $\sigma$ = ', num2str(standardavvik_y)])
    if i == 1
        title(['Sebastian'])
    elseif i == 2
        title(['Fredrik'])
    elseif i == 3
        title(['Hassan'])
    end
    hold off

end
