%%####!/bin/octave -qf
%%%#!/cygdrive/c/Program Files/MATLAB/R2013b/bin/matlab

%%%###pkg load io
sst=importdata('sst_semanal.prn');
climad=importdata('clima_sst_diario.prn');
climam=importdata('clima_sst_mensal.prn'); 

xlswrite('SST.xlsx',sst,'SST','a2');
xlswrite('SST.xlsx',climad,'CLIMA_DIARIO','a2');
xlswrite('SST.xlsx',climam,'CLIMA_MENSAL','a2');


%%%pi=write(arqout,'ano' 'mesx' 'dia' 'tsm1' 'tsm2' 'tsm12' 'tsm3' 'tsm4' 'tsm3.4' 'tsmcbm) 


header={'ANO','MES','DIA','JUL','NINO1','NINO2','NINO1+2','NINO3','NINO4','NINO3+4','CBM'} ;

xlswrite('SST.xlsx',header,'SST','a1');
xlswrite('SST.xlsx',header,'CLIMA_DIARIO','a1');
xlswrite('SST.xlsx',header,'CLIMA_MENSAL','a1');

quit