filename = 'sebastian.mat'; 
load(filename)

u_B(length(u_B)+1) = u_B(length(u_B));
u_C(length(u_C)+1) = u_C(length(u_C));


%save(filename,'Tid','Lys', 'u_B', 'u_C')