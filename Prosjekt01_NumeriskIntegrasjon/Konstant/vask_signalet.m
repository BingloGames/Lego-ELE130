filename = 'P01_NumeriskIntegrasjonKonstant.mat'; 
load(filename)
%elementer_vaskes_start = 1;
%elementer_vaskes_slutt = 93;

%element_tid_start = Tid(1);

%for i = 1:154
%    Tid(i) = Tid(i) - element_tid_start;
%end
    
%Tid = [Tid(elementer_vaskes_start:elementer_vaskes_slutt)];
%Lys = [Lys(elementer_vaskes_start:elementer_vaskes_slutt)];
likevekst_verdi = mean(Lys, "omitnan");

Lys = Lys - likevekst_verdi;
%Tid = Tid - Tid(1);

%for i = 1:76 
%    Lys(i) = Lys(i) - likevekst_verdi;
%end


plot(Tid, Lys)
save('P01_NumeriskIntegrasjonKonstant_ny.mat','Tid','Lys')