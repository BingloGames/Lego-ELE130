function [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick)
    
    JoyAxes(1) =   100 * axis(joystick, 1); % sideveis
    JoyAxes(2) = - 100 * axis(joystick, 2); % forover
    JoyAxes(3) =   100 * axis(joystick, 3); % twist
    JoyAxes(4) = - 100 * axis(joystick, 4); % potensiometer
    
    for i=1:12
        JoyButtons(i) = button(joystick, i);
    end
end

