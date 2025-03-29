filename = 'P02_LysTid_Stoy_filtrert.mat'; 
load(filename)


for i = 1:length(Lys)
    Lys(i) = Lys(i) + randn*2;
end
%Lys = Lys + randn;


plot(Tid, Lys)
save('P02_LysTid_Stoy_filtrert_med_stoy.mat','Tid','Lys')