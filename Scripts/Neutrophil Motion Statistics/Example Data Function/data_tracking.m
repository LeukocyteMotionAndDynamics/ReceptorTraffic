% Function that receives the experiment index and returns all parameters
% associated with this experiment
% Wound points (wound_x, wound_y) are given in um, pixel size (pixel) is 
% given in um/pixel, experiment starting time (exp_start) is given in minutes


% Last Update:  18 Apr 2019


%% Beginning of function

function [name, pixel, exp_start, wound_x, wound_y] = data_tracking(experiment)

if experiment == 1
    name = 'samplecelltracks';
    pixel = 0.5725026;
    exp_start = 5;
    wound_x = [531;498;472;449;441;439;440;441;449;466;488;528;553;574;579;...
        567;555]*pixel;
    wound_y = [614;635;634;607;579;551;522;490;461;438;426;434;442;472;516;...
        551;584]*pixel;
elseif experiment == 2
    name = 'file 2';
    pixel = 0.5725026;
    exp_start = 15;
    wound_x = [536;517;489;456;441;439;435;436;439;443;449;456;478;500;534;...
        563;595;609;603;591;579;566]*pixel;
    wound_y = [707;735;735;731;705;683;663;642;599;567;519;502;493;497;499;...
        501;498;510;535;581;627;664]*pixel;
elseif experiment == 3
    name = 'file 3';
    pixel = 0.5725026;
    exp_start = 15;
    wound_x = [653;635;589;553;515;496;481;481;478;484;488;491;491;517;557;...
        628;653;661;668]*pixel;
    wound_y = [475;454;436;429;429;441;466;503;538;574;607;641;676;719;734;...
        692;617;580;539]*pixel;
elseif experiment == 4
    name = 'file 4';
    pixel = 0.5725026;
    exp_start = 15;
    wound_x = [472;498;536;542;538;535;537;535;510;489;478;454;426;421;420;...
        423;434;448]*pixel;
    wound_y = [475;468;472;494;523;575;621;653;656;656;670;670;666;631;595;...
        552;513;490]*pixel;
elseif experiment == 5
    name = 'file 5';
    pixel = 0.5725026;
    exp_start = 15;
    wound_x = [472;463;459;480;499;516;540;565;576;595;597;598;601;601;585;...
        559;540;511;492]*pixel;
    wound_y = [688;718;748;773;791;805;808;799;785;751;728;709;685;668;655;...
        659;673;679;677]*pixel;
end

