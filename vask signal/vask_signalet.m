filename = 'P03_sinus.mat'; 
load(filename)
elementer_vaskes_start = 100;
elementer_vaskes_slutt = 253;

%element_tid_start = Tid(1);

%for i = 1:154
%    Tid(i) = Tid(i) - element_tid_start;
%end
    
Tid = [Tid(elementer_vaskes_start:elementer_vaskes_slutt)];
Avstand = [Avstand(elementer_vaskes_start:elementer_vaskes_slutt)];
%likevekst_verdi = mean(Lys, "omitnan");

%Lys = Lys - likevekst_verdi;
Tid = Tid - Tid(1);

%for i = 1:76 
%    Lys(i) = Lys(i) - likevekst_verdi;
%end


plot(Tid, Avstand)
save('P03_sinus_filtrert.mat','Tid','Avstand')