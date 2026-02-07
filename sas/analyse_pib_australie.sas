/* Application 1: test de racine unitaire et outliers */

/*  1) Importation des données et création de variables */

/* Importation et spécification des variables temporelle et country */

data GDP ;
infile 'C:\Users\didom\M1 MBFA UPEC\introduction à SAS\GDP.csv' dlm=';' truncover firstobs=2;
length time_var 6. country $9. ;
input time_var YYQ6. country $ GDP ;
format time_var YYQ6. ;
if country ^= 'AUS' then delete ;
run ; 

data deflator ;
infile 'C:\Users\didom\M1 MBFA UPEC\introduction à SAS\Deflator.csv' dlm=';' truncover firstobs=2;
length time_var 6. country $9. ;
input time_var YYQ6. country $ deflator ;
format time_var YYQ6. ;
if country ^= 'AUS' then delete ;
run ; 

/* Merge, PIB réel Yt,  PIB réel en logarithme (ln(Yt)),  le taux de croissance trimestriel
 du PIB comme delta_Yt */

data App1base ;
merge GDP deflator ;
by time_var country ;
Yt = (GDP/deflator)*100 ;
ln_Yt = log(Yt) ;
delta_Yt = (ln_Yt - lag(ln_Yt))*100;
run;

/* 2) Test de racine unitaire */

proc gplot data = App1base ;
title "Evolution de la serie des logs des PIB en volume Australien au cours du temps" ;
plot (ln_Yt)* time_var ;
symbol1 i = join c = black ;
run ; quit ;

title ;
/* hyper paramètre = nb de retard pour le test ADF */

data critere_de_Schertz;
p = int(12*(175/100)**0.25); /*on dispose de 175 observations*/
run ;

/* test adf */

proc arima data = App1base ;
identify var = ln_Yt stationarity = (adf=(13));
run;quit;

/* test ERS */

proc autoreg 
data = App1base ;
model ln_Yt = / stationarity=(np) ;
run ;


/* test PP pour la serie delta_ln_Yt on conserve le meme nombre de retard */

proc gplot data = App1base ;
title "Evolution de la serie des taux de croissances des PIB en volume Australien au cours du temps" ;
plot (delta_Yt)* time_var ;
symbol1 i = join c = black ;
run ; quit ;

title ;
proc autoreg data =  App1base ;
model delta_Yt = / stationarity=(phillips);
run; quit ;

/* 3) Graphique et statistique descriptives */

/* Le graphique du taux de croissance du PIB réel à dejà été généré à la question 2 */

/* statistique descriptive et test de la normalité de la série du taux de croissance des PIB réel */

proc univariate data = App1base normal ;
var delta_Yt ;
run ;

/* 4) Identification des valeurs extrêmes */

/* z-score */

proc standard data = App1base mean = 0 std = 1 out = table_zscore ;
var delta_Yt ;
run ;


/* moyenne et ecart-type du z-score */

proc univariate data = table_zscore ;
var delta_Yt ;
run ;

/*identification des valeurs extrèmes */

data table_zscore ;
set table_zscore ;
if -3 <= delta_Yt <= 3 & not missing(delta_Yt) then outliers=0 ;
else if  missing(delta_Yt) then outliers=. ;
else outliers=1 ;
run ;

/* table comprenant seulement les valeurs extrèmes */

data valeur_extreme ;
set table_zscore ;
if outliers ^= 1 then delete ;
run ;

proc print data = valeur_extreme ;
run ;

/* Méthode de la MAD */

/* calcul de la MAD */

/* la mediane de la serie delta_Yt est 0.717696 */

data table_mad ;
set App1base ;
M = 0.717696 ; /* M pour la mediane de la serie delta_Yt */
abs_dev = abs(delta_Yt - 0.717696);
run;

proc univariate data = table_mad ;
var abs_dev ; /*abs dev pour absolute deviation */
run ; /* la mediane de la variable abs_dev est 0.3396329 */

data table_mad ;
set table_mad ;
abs_dev_med = 0.3396329 ;
MAD = 1.4826*0.3396329 ;
run ;

proc print data = table_mad (obs=5) ;
run ;

/* identification des valeurs extrèmes avec la MAD */

data table_mad ;
set table_mad ;
if M - 2.5*MAD  <= delta_Yt <= M + 2.5*MAD & not missing(delta_Yt) then outliers=0 ;
else if  missing(delta_Yt) then outliers=. ;
else outliers=1 ;
run ;

data valeur_extreme_MAD ;
set table_mad ;
if outliers ^= 1 then delete ;
run ;

proc print data = valeur_extreme_MAD ;
run ;

data App1base ;
set table_MAD ;
if outliers ^= 0 then delete ;
drop M abs_dev abs_dev_med MAD outliers ;
run ;

/* Application 2 : Modèle Econométrique */

/* Création de la variable delta_Yt_1 */

data App1base ;
set App1base ;
lag_delta_Yt = lag(delta_Yt);
run ;

/* Génération de delta_Yt_USA et lag_delta_Yt_USA */

data GDP_USA ;
infile 'C:\Users\didom\M1 MBFA UPEC\introduction à SAS\GDP.csv' dlm=';' truncover firstobs=2;
length time_var 6. country $9. ;
input time_var YYQ6. country $ GDP ;
format time_var YYQ6. ;
if country ^= 'USA' then delete ;
run ; 

data deflator_USA ;
infile 'C:\Users\didom\M1 MBFA UPEC\introduction à SAS\Deflator.csv' dlm=';' truncover firstobs=2;
length time_var 6. country $9. ;
input time_var YYQ6. country $ deflator ;
format time_var YYQ6. ;
if country ^= 'USA' then delete ;
run ; 

data PIB_USA ;
merge GDP_USA deflator_USA ;
by time_var country ;
run ;

data PIB_USA ;
set PIB_USA ;
rename country = country_2 ;
rename GDP = GDP_USA ;
rename deflator = deflator_USA ;
Yt_USA = (GDP/deflator)*100 ;
ln_Yt_USA = log(Yt_USA) ;
delta_Yt_USA = (ln_Yt_USA - lag(ln_Yt_USA))*100;
lag_delta_Yt_USA = lag(delta_Yt_USA);
run;

data App2base ;
merge App1base PIB_USA ;
by time_var ;
drop Yt_USA ln_Yt_USA ;

/* statistiques descriptives sur lag_Yt_delta_USA) */

proc gplot data = App2base ;
plot (lag_delta_Yt_USA)* time_var ;
symbol1 i = join c = black ;
run ; quit ;

/* Nuage de point */
 
proc sgplot data = App2base ; 
scatter X = lag_delta_Yt_USA Y = delta_Yt ; 
title 'Evolution du taux de croissance du PIB Australien en fonction du taux de croissance du PIB US en periode précédente' ; 
run ;

proc univariate data = App2base ;
var lag_delta_Yt_USA ;
run ;

proc corr data = App2base ;
var  delta_Yt lag_delta_Yt_USA ;
run;

/*2)*/

/* modèle (méthode MCO) */


proc reg data =  App2base ;
model delta_Yt = lag_delta_Yt lag_delta_Yt_USA ;
output out=estim p=pred r=res;
run;quit;

/*3)*/

/* test de white (homoscédaticité) */

proc reg data = App2base  ;
model delta_Yt = lag_delta_Yt lag_delta_Yt_USA / spec  ;
run;quit;

 /* test de Breush Godfrey (absence d'autocorrélation) */

proc autoreg data = App2base ;
model delta_Yt = lag_delta_Yt lag_delta_Yt_USA / godfrey=1 ;
run; quit;

/* test de normalité des résidus */

proc autoreg data = App2base ;
model delta_Yt = lag_delta_Yt lag_delta_Yt_USA / NORMAL;
run; quit;

/* 4) */

/* estimation approprié du modèle */

/* étant donné les résultats obtenus à la question précédente utliser un modèle qui corrige 
les problèmes liées à la violation des hypothèses sur le terme d'erreur est inutile cependant voila la facon 
dont on aurait procédé */

/* Cette proc à l'objectif de régler ces problèmes en utilisant l'estimateur robuste de newey_west */

proc model data = App2base ;
endo delta_Yt ;
exog lag_delta_Yt lag_delta_Yt_USA ;
instruments _exog_ ;
parms b0 b1 b2 ;
delta_Yt = b0 + b1*lag_delta_Yt + b2*lag_delta_Yt_USA ;
fit delta_Yt / gmm kernel=(bart, 4.54 ,0) vardef=n ;
run;
