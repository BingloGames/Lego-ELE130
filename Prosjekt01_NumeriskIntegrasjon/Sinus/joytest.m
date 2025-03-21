clear all
close all


% Setter figurenhetene
set(groot, 'defaultFigureUnits','normalized')

figure(1);
set(1,'position',[0.1 0.1 0.7 0.5])

% Lager håndtak (handles) til hvert plot
subplot(1,2,1)
p1=plot(0,0,'b'); hold on;
p2=plot(0,0,'r');
p3=plot(0,0,'g');
p4=plot(0,0,'k');
legend('axes(1)','axes(2)','axes(3)','axes(4)','Location','Northwest')
title(['Alle aksene'])
xlabel('sekund')

subplot(1,2,2)
b1=bar(zeros(1,8));
title(['Knapp nummer:   ' ]);
set(gca,'xlim',[1 12],'ylim',[0 1]); axis square
xlabel('Knapp 1 til 12')

k=1;
tid(k)=0;
tic

joystick = vrjoystick(1);
axes(1:4,k)=0;
buttons = zeros(1,12);

while ~buttons(1)
    tid(k)=toc;
    
    
    % joystick buttons
    for i=1:12
        buttons(i) = button(joystick, i);
    end

    % joystick movement
    axes(1,k) = 100 * axis(joystick, 1); % side
    axes(2,k) = -100 * axis(joystick, 2); % forward

    % endre paa dette til aa passe mac/pc
    % maa finne korrekt fortegn
    axes(3,k) = 100 * axis(joystick, 3); % potensimeter
    axes(4,k) = 100 * axis(joystick, 4); % twist
    

    set(p1,'Xdata',tid,'Ydata',axes(1,:));
    set(p2,'Xdata',tid,'Ydata',axes(2,:));
    set(p3,'Xdata',tid,'Ydata',axes(3,:));
    set(p4,'Xdata',tid,'Ydata',axes(4,:));


    set(b1,'Ydata',buttons);
    if any(buttons)
        title(['Knapp nummer: ' num2str(find(buttons))]);
    else
        title(['Knapp nummer:   ' ]);
    end

    

    drawnow
    k=k+1;
   
    
end



