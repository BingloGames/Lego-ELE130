filename = 'P01_NumeriskIntegrasjonSinus.mat'; 
load(filename)
elementer_vaskes_start = 110;
elementer_vaskes_slutt = 263;

%element_tid_start = Tid(1);

%for i = 1:154 
%    Tid(i) = Tid(i) - element_tid_start;
%end
    
%Tid = [Tid(elementer_vaskes_start:elementer_vaskes_slutt)];
%Lys = [Lys(elementer_vaskes_start:elementer_vaskes_slutt)];
likevekst_verdi = mean(Lys, "omitnan");


for i = 1:154 
    Lys(i) = Lys(i) - likevekst_verdi;
end


plot(Tid, Lys)