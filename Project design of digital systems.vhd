--************************************************************************************************************************************
--************************************************************************************************************************************
--Projet V5: Conception et implémentation matériel d’une MSA dédiée à la construction d’un système intelligent de navigation urbaine
--************************************************************************************************************************************
--************************************************************************************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.Construire_Vehicule.ALL;
use WORK.Congestion_traveaux.all;

--**************************************************************************************************
--**************************************************************************************************
--** DÉCLARATION DES VARIABLES D'ENTRÉE DU SYSTEME

--** CLOCK :   Horloge
--** START : PERMET DE SYNCHRONISER LE DEPLACEMENT DES VÉHICULES
--** HSYNC, VSYNC, SYNC, BLANK, BLEU, GREEN, RED, DISPLAY, X,Y: NÉCESSAIRE À L'AFFICHAGE
--**
--***************************************************************************************************
--***************************************************************************************************

ENTITY VGA IS
PORT(
     CLOCK   ,start              : IN    std_logic;
     HSYNC, VSYNC                 : OUT    std_logic;
     SYNC, BLANK                  : OUT    std_logic := '1';
     RED, GREEN, BLUE             : OUT    std_logic_vector(7 DOWNTO 0);
     DISPLAY                      : OUT    std_logic;
     X                            : OUT integer RANGE 0 TO 1280    := 0;
     Y                            : OUT integer RANGE 0 TO 1024    := 0;
     congestion, travaux, back    : IN    std_logic;
     
     -------VARIABLE DE MODIFICTAION DU COMPTEUR 6*7SEGMENTS
     
     rst: in std_logic;
     segment_0: out STD_LOGIC_VECTOR (6 downto 0);
     segment_1: out STD_LOGIC_VECTOR (6 downto 0);
     segment_2: out STD_LOGIC_VECTOR (6 downto 0);
     segment_3: out STD_LOGIC_VECTOR (6 downto 0);
     segment_4: out STD_LOGIC_VECTOR (6 downto 0);
     segment_5: out STD_LOGIC_VECTOR (6 downto 0)
     
     );
END VGA;



ARCHITECTURE MAIN OF VGA IS

------ SIGNAUX INTERNES POUR UTILISATION INTERNE
------ SIGNAUX POUR LA DIVISION DE L'HORLOGE

SIGNAL count_10hz: integer RANGE 0 TO 2499999 := 0;
SIGNAL clock_10hz_int: STD_LOGIC;
SIGNAL clock_police : STD_LOGIC;
SIGNAL clock_urgence: STD_LOGIC;
SIGNAL clock_laitier: STD_LOGIC;
SIGNAL clock_usager: STD_LOGIC;

--------SIGNAUX DONNÉS AU LABORATOIRE 4

SIGNAL    HPOS          : integer RANGE 0 TO 1688   := 0;
SIGNAL    VPOS          : integer RANGE 0 TO 1066   := 0;
SIGNAL    GRAY          : integer RANGE 0 TO 255    := 0;
SIGNAL    GRAYV         : std_logic_vector(7 DOWNTO 0);


----Déclaration des véhicules


----Définition de la position du premier véhicule de Police de couleur bleue

SIGNAL    XPos_1       : integer range 0 TO 1688 :=  490;
SIGNAL    YPos_1        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Police_1      : std_logic;

-----  definition de la position du second Véhicule de police de couleur bleue

SIGNAL    XPos_2        : integer range 0 TO 1688 := 520;
SIGNAL    YPos_2        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Police_2     : std_logic;

----- definition de la position du vehicule d'urgence de couleur rouge

SIGNAL    XPos_3       : integer range 0 TO 1688 := 710;
SIGNAL    YPos_3        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Urgence_1    : std_logic;


----- definition de la position du premier véhicule du laitier de couleur verte

SIGNAL    XPos_4        : integer range 0 TO 1688 := 900 ;
SIGNAL    YPos_4        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Laitier_1       : std_logic;

---- definition de la position du second véhicule du laitier de couleur verte

SIGNAL    XPos_5        : integer range 0 TO 1688 := 930 ;
SIGNAL    YPos_5        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Laitier_2     : std_logic;

----- definition de la position du premier véhicule d'usager de couleur jaune

SIGNAL    XPos_6        : integer range 0 TO 1688 := 1130;
SIGNAL    YPos_6        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Vehicule_1    : std_logic;

---- definition de la position du deuxieme véhicule d'usager de couleur jaune

SIGNAL    XPos_7        : integer range 0 TO 1688 := 1160;
SIGNAL    YPos_7        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Vehicule_2    : std_logic;


----- definition de la position du troisieme Véhicule d'usager de couleur jaune

SIGNAL    XPos_8        : integer range 0 TO 1688 := 1220;
SIGNAL    YPos_8        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Vehicule_3    : std_logic;

----- definition de la position du quatrieme Véhicule d'usager de couleur jaune

SIGNAL    XPos_9        : integer range 0 TO 1688 := 1190;
SIGNAL    YPos_9        : integer RANGE 0 TO 1688 := 995;
SIGNAL    Vehicule_4    : std_logic;


---- DEFINITION DES ACCIDENTS

SIGNAL   XPos_10        : integer range 0 TO 1688 := 1250;
SIGNAL   YPos_10        : integer range 0 TO 1688 := 764;
SIGNAL   Accidents      : STD_LOGIC;

---- DEFINITION DES BOUCHONS

SIGNAL   XPos_11        : integer range 0 TO 1688 := 1250;
SIGNAL   YPos_11        : integer range 0 TO 1688 := 120;
SIGNAL   Bouchons       : STD_LOGIC;


----État: ÉTATS DES MACHINES

TYPE s_etat is(a, b , c, d, e, f, g, h , i, j) ;---états utilsés
SIGNAL     etat, next_etat : s_etat ; --2 signaux : états courant et suivant

TYPE s_etat2 is(a2, b2 , c2, d2, e2, f2, g2, h2, i2, j2, k2, l2, m2, n2, o2) ;---états utilsés
SIGNAL     etat2, next_etat2 : s_etat2 ; --2 signaux : états courant et suivant

TYPE s_etat3 is( a3, b3, c3, d3, e3, f3, g3, h3, i3, j3 ,K3);---etats utilsés
SIGNAL     etat3, next_etat3 : s_etat3 ; --2 signaux : états courant et suivant

TYPE s_etat4 is( a4, b4, c4, d4, e4, f4, g4, h4, i4, j4);---états utilsés
SIGNAL     etat4, next_etat4 : s_etat4 ; --2 signaux : états courant et suivant

TYPE s_etat5 is( a5, b5, c5, d5, e5, f5,g5, h5, i5, j5);---états utilsés
SIGNAL     etat5, next_etat5 : s_etat5 ; --2 signaux :etats courant et suivant

TYPE s_etat6 is( a6, b6, c6, d6, e6, f6, g6, h6, i6, j6, k6, l6);---etats utilsés
SIGNAL     etat6, next_etat6 : s_etat6 ; --2 signaux : états courant et suivant

TYPE s_etat7 is( a7, b7, c7, d7, e7, f7, g7, h7, i7, j7 ,k7);---états utilsés
SIGNAL     etat7, next_etat7 : s_etat7 ; --2 signaux : états courant et suivant

TYPE s_etat8 is( a8, b8, c8, d8, e8, f8, g8, h8, i8, j8, k8, l8);---etats utilsés
SIGNAL     etat8, next_etat8 : s_etat8 ; --2 signaux : états courant et suivant

TYPE s_etat9 is( a9, b9, c9, d9, e9, f9, G9, h9, i9, j9, k9, l9);---etats utilsés
SIGNAL     etat9, next_etat9 : s_etat9 ; --2 signaux : états courant et suivant

---SIGNAUX POUR LE COMPTEUR 6*7SEGMENTS. LES VALEURS SONT PAR DEFAUT À 0
signal s1,s2,s3,s4,s5,s6 : integer range 0 to 10 :=0;

------ CONSTANTES FOURNI PAR LE CODE DU LABORATOIRE 4

CONSTANT HZ_SYNC                : integer    := 112;
CONSTANT HZ_BACK_PORCH          : integer    := 248;
CONSTANT HZ_DISP                : integer    := 1280;
CONSTANT HZ_FRONT_PORCH         : integer    := 48;
CONSTANT HZ_SCAN_WIDTH          : integer    := 1688;
CONSTANT HS_POLARITY            : std_logic := '0';

CONSTANT VT_SYNC                : integer     := 3;
CONSTANT VT_BACK_PORCH          : integer     := 38;
CONSTANT VT_DISP                : integer     := 1024;
CONSTANT VT_FRONT_PORCH         : integer     := 1;
CONSTANT VT_SCAN_WIDTH          : integer     := 1066;
CONSTANT VT_POLARITY            : std_logic := '0';

------- DEBUT DE L'ARCHITECTURE

BEGIN



Vehicule( HPOS, VPOS, XPos_1,YPos_1, Police_1);

Vehicule( HPOS, VPOS, XPos_2,YPos_2, Police_2);

Vehicule( HPOS, VPOS, XPos_3,YPos_3, Urgence_1);

Vehicule( HPOS, VPOS, XPos_4,YPos_4, Laitier_1);

Vehicule( HPOS, VPOS, XPos_5,YPos_5, Laitier_2);

Vehicule( HPOS, VPOS, XPos_6,YPos_6, Vehicule_1);

Vehicule( HPOS, VPOS, XPos_7,YPos_7, Vehicule_2);

Vehicule( HPOS, VPOS, XPos_8,YPos_8, Vehicule_3);

Vehicule( HPOS, VPOS, XPos_9,YPos_9, Vehicule_4);


---- diviser l'horloge de 25Mhz à 10Hz
---- nous allons utiliser une valeur 'count' pour ralentir l'horloge grâce
---- à un compteur intégré


PROCESS
BEGIN

-- Division de l'horloge de 25Mhz à 10hz
WAIT UNTIL CLOCK'EVENT and CLOCK = '1' ;
IF count_10hz < 250000 THEN
count_10hz <= count_10hz + 1;
ELSE
count_10hz <= 0 ;
END IF;
IF count_10hz < 100 THEN
clock_10hz_int <= '0';
ELSE
clock_10hz_int <= '1';
END IF;

clock_police <= clock_10hz_int;

END PROCESS;

-- Division de 10hz a 5hz
-- l'hologe du véhicule de police
PROCESS (clock_police)    

 variable Count: Integer:= 0;
 variable Temp: std_logic:='0';
 
BEGIN
   if rising_edge(clock_police) then
Count:=Count+1;
 if Count=1 then
 Temp:=Not Temp;
 Count:=0;
 end if;
end if;
clock_urgence <= Temp;
END PROCESS;

-- l'horloge du véhicule d'urgence
PROCESS (clock_urgence)

 variable Count1: Integer:= 0;
 variable Temp1: std_logic:='0';
 
BEGIN
   if rising_edge(clock_urgence) then
Count1:=Count1+1;
 if Count1=1 then
 Temp1:=Not Temp1;
 Count1:=0;
 end if;
end if;
clock_laitier <= Temp1;
END PROCESS;

-- l'horloge du véhicule de laitier
PROCESS (clock_laitier)

 variable Count2: Integer:= 0;
 variable Temp2: std_logic:='0';
 
BEGIN
   if rising_edge(clock_laitier) then
Count2:=Count2+1;
 if Count2=1 then
 Temp2:=Not Temp2;
 Count2:=0;
 end if;
end if;
clock_usager <= Temp2;
END PROCESS;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---- Nous avons implementer 9 machines à état ----
---- dans ces 9 machines à état, 2 comprennent des restrictions liées aux ----
---- congestions et aux travaux. précisement les machine à état 2 et 8    ----                                  
---------------------------------------------------------------------------
---------------------------------------------------------------------------

--- Déplacement du premier véhicule de police


PROCESS(clock_police, etat, XPos_1 ,YPos_1)

BEGIN

------ Le départ et le retour sont synchronisés sur l'horloge de 10 hZ-------

IF (rising_edge(clock_police)) THEN

------ départ du véhicule  ---------

        IF (start = '1' and back ='0') THEN
            CASE etat IS
----Déplacement vers la gauche

                WHEN a =>   IF( XPos_1 > 455 ) THEN

                                    etat <= a ;
                                    next_etat <= b ;
                                    XPos_1 <= XPos_1 - 1 ;

                            ELSIF (XPos_1 = 455) THEN

                                    XPos_1 <= XPos_1 ;
                                    etat <= b;
                                    next_etat <= b;

                            END IF;

----Déplacement vers le Haut

                WHEN b =>   IF ( YPos_1 > 400) THEN
                                    etat <= b;
                                    next_etat <= c ;
                                    YPos_1 <= YPos_1 - 1;
                            ELSIF (YPos_1 = 400) THEN
                                    etat <= c;
                                    next_etat <= c;
                                    YPos_1 <= YPos_1 ;
                            END IF;
----Déplacement vers la droite

                WHEN c =>   IF ( XPos_1 < 1415 ) THEN
                                    etat <= c ;
                                    next_etat <= d ;
                                    XPos_1 <= XPos_1 + 1 ;

                            ELSIF (XPos_1 = 1415) THEN

                                    etat <= d;
                                    next_etat <= d ;
                                    XPos_1 <= XPos_1;
                            END IF;
----Déplacement vers le bas

                WHEN d =>   IF(YPos_1 < 421) THEN
                                    etat <= d ;
                                    next_etat <= e;
                                    YPos_1 <= YPos_1 + 1 ;
                            ELSIF (YPos_1 = 421) THEN
                                    etat <= e;
                                    next_etat <= e ;
                                    YPos_1 <= YPos_1;
                            END IF;

                WHEN e =>   IF (YPos_1 = 421) THEN

                                    etat <= e;
                                    next_etat <= e ;
                                    YPos_1 <= YPos_1;
                            END IF;

                WHEN OTHERS =>      etat <= a;
                                    next_etat <= a;

            END CASE;

        END IF;

---------------- retour du véhicule -------------

        IF (back = '1' and start = '0' ) THEN

            CASE etat IS

                WHEN f =>   IF (XPos_1 < 1650) THEN
                                    etat <= f ;
                                    next_etat <= g ;
                                    XPos_1 <= XPos_1 + 1 ;

                            ELSIF (XPos_1 = 1650) THEN
                                    etat <= g ;
                                    next_etat <= g ;
                                    XPos_1 <= XPos_1 ;
                            END IF;

                WHEN g =>   IF (YPos_1 < 1005) THEN
                                    etat <= g ;
                                    next_etat <= h ;
                                    YPos_1 <= YPos_1 + 1 ;

                            ELSIF (YPos_1 = 1005) THEN
                                    etat <= h ;
                                    next_etat <= h ;
                                    YPos_1 <= YPos_1 ;

                            END IF;

                WHEN h =>   IF (XPos_1 > 520) THEN
                                    etat <= h ;
                                    next_etat <= i ;
                                    XPos_1 <= XPos_1 - 1 ;

                            ELSIF (XPos_1 = 520) THEN
                                    etat <= i ;
                                    next_etat <= i ;
                                    XPos_1 <= XPos_1 ;
                            END IF;

                WHEN i =>   IF (YPos_1 > 980) THEN
                                    etat <= i ;
                                    next_etat <= j ;
                                    YPos_1 <= YPos_1 - 1 ;

                            ELSIF (YPos_1 = 980) THEN
                                    etat <= j ;
                                    next_etat <= j ;
                                    XPos_1 <= XPos_1 ;
                            END IF;

                WHEN j =>   IF (YPos_1 = 980) THEN
                                    etat <= j ;
                                    next_etat <= j ;
                                    XPos_1 <= XPos_1 ;

                            END IF;
                WHEN OTHERS =>      etat <= f;
                                    next_etat <= f;
            END CASE;
        END IF;
END IF;

END PROCESS;

---- Déplacement du second véhicule de police

PROCESS(clock_police, etat2, XPos_2 , YPos_2, travaux)

BEGIN

------ Le départ et le retour sont synchroniser sur l'horloge de 10 hZ-------

IF (rising_edge(clock_police)) THEN

------ départ du véhicule---------

        IF (start = '1' and back = '0') THEN

            IF(travaux ='0') THEN
---Absence de travaux


                CASE etat2 IS

                    WHEN a2 =>  IF( XPos_2 > 455 ) THEN
                                    etat2 <= a2 ;
                                    next_etat2 <= b2 ;
                                    XPos_2 <= XPos_2 - 1 ;

                                ELSIF (XPos_2 = 455) THEN
                                    etat2 <= b2;
                                    next_etat2 <= b2;
                                    XPos_2 <= XPos_2 ;
                                END IF;
                    WHEN b2 =>  IF ( YPos_2 > 400) THEN
                                    etat2 <= b2;
                                    next_etat2 <= c2 ;
                                    YPos_2 <= YPos_2 - 1;
                                ELSIF (YPos_2 = 400) THEN
                                    etat2 <= c2;
                                    next_etat2 <= c2;
                                    YPos_2 <= YPos_2 ;
                                END IF;
                    WHEN c2 =>  IF ( XPos_2 < 1280 ) THEN
                                    etat2 <= c2 ;
                                    next_etat2 <= d2 ;
                                    XPos_2 <= XPos_2 + 1 ;
                                ELSIF (XPos_2 = 1280) THEN
                                    etat2 <= d2;
                                    next_etat2 <= d2 ;
                                    XPos_2 <= XPos_2;
                                END IF;

                    WHEN d2 =>  IF(YPos_2 > 78) THEN
                                    etat2 <= d2 ;
                                    next_etat2 <= e2;
                                    YPos_2 <= YPos_2 - 1 ;
                                ELSIF (YPos_2 = 78) THEN
                                    etat2 <= e2 ;
                                    next_etat2 <= e2 ;
                                    YPos_2 <= YPos_2;
                                END IF;
                    WHEN e2 =>  IF(XPos_2 < 1415) THEN
                                    etat2 <= e2 ;
                                    next_etat2 <= f2;
                                    XPos_2 <= XPos_2 + 1 ;
                                ELSIF (XPos_2 = 1415) THEN
                                    etat2 <= f2 ;
                                    next_etat2 <= f2 ;
                                    XPos_2 <= XPos_2;
                                END IF;

                    WHEN f2 =>  IF(YPos_2 < 100) THEN
                                    etat2 <= f2;
                                    next_etat2 <= g2 ;
                                    YPos_2 <= YPos_2 + 1 ;
                                END IF;
                    WHEN g2 =>  IF (YPos_1 = 100) THEN
                                    etat2 <= g2;
                                    next_etat2 <= g2 ;
                                    YPos_2 <= YPos_2 ;

            END IF;

                    WHEN OTHERS =>  etat2 <= a2;
                                    next_etat2 <= a2;

                END CASE;

        ELSIF(travaux = '1') THEN
 
 --- présence des travaux


            CASE etat2 IS

                WHEN a2 =>  IF( XPos_2 > 455 ) THEN
                                    etat2 <= a2 ;
                                    next_etat2 <= b2 ;
                                    XPos_2 <= XPos_2 - 1 ;

                            ELSIF (XPos_2 = 455) THEN
                                    etat2 <= b2;
                                    next_etat2 <= b2;
                                    XPos_2 <= XPos_2 ;
                            END IF;

                WHEN b2 =>  IF ( YPos_2 > 400) THEN
                                    etat2 <= b2;
                                    next_etat2 <= c2 ;
                                    YPos_2 <= YPos_2 - 1;
                            ELSIF (YPos_2 = 400) THEN
                                    etat2 <= c2;
                                    next_etat2 <= c2;
                                    YPos_2 <= YPos_2 ;
                            END IF;
                WHEN c2 =>  IF ( XPos_2 < 1280 ) THEN
                                    etat2 <= c2 ;
                                    next_etat2 <= d2 ;
                                    XPos_2 <= XPos_2 + 1 ;
                            ELSIF (XPos_2 = 1280) THEN
                                    etat2 <= d2;
                                    next_etat2 <= d2 ;
                                    XPos_2 <= XPos_2;
                            END IF;

                WHEN d2 =>  IF(YPos_2 > 360) THEN
                                    etat2 <= d2 ;
                                    next_etat2 <= e2;
                                    YPos_2 <= YPos_2 - 1 ;
                            ELSIF (YPos_2 = 360) THEN
                                    etat2 <= e2 ;
                                    next_etat2 <= e2 ;
                                    YPos_2 <= YPos_2;
                            END IF;
                WHEN e2 =>  IF(XPos_2 > 455) THEN
                                    etat2 <= e2 ;
                                    next_etat2 <= f2;
                                    XPos_2 <= XPos_2 - 1 ;
                            ELSIF (XPos_2 = 455) THEN
                                    etat2 <= f2 ;
                                    next_etat2 <= f2 ;
                                    XPos_2 <= XPos_2;
                            END IF;
                WHEN f2 =>  IF(YPos_2 > 78) THEN
                                    etat2 <= f2;
                                    next_etat2 <= g2 ;
                                    YPos_2 <= YPos_2 - 1 ;
                            ELSIF (YPos_2 = 78) THEN
                                    etat2 <= g2;
                                    next_etat2 <= g2 ;
                                    YPos_2 <= YPos_2 ;
                            END IF;

                WHEN g2 =>  IF (XPos_2 < 1410) THEN
                                    etat2 <= g2;
                                    next_etat2 <= h2 ;
                                    XPos_2 <= XPos_2 + 1 ;
                            ELSIF (XPos_2 = 1410) THEN
                                    etat2 <= h2;
                                    next_etat2 <= h2 ;
                                    YPos_2 <= YPos_2 ;
                            END IF;
                WHEN h2 =>  IF(YPos_2 < 100) THEN
                                    etat2 <= h2;
                                    next_etat2 <= i2 ;
                                    YPos_2 <= YPos_2 + 1 ;
                            ELSIF (YPos_1 = 100) THEN
                                    etat2 <= i2;
                                    next_etat2 <= i2 ;
                                    YPos_2 <= YPos_2 ;
                            END IF;
                WHEN OTHERS =>      etat2 <= i2;
                                    next_etat2 <= i2;
            END CASE;
        END IF;

END IF;

--- retour du véhicule  -------------


IF (back = '1' and start = '0') THEN

            CASE etat2 IS

                WHEN j2 =>  IF (XPos_2 < 1650) THEN
                                    etat2 <= j2 ;
                                    next_etat2 <= k2 ;
                                    XPos_2 <= XPos_2 + 1 ;
                            ELSIF (XPos_2 = 1650) THEN
                                    etat2 <= k2 ;
                                    next_etat2 <= k2 ;
                                    XPos_2 <= XPos_2 ;
                            END IF;
                WHEN k2 =>  IF (YPos_2 < 1005) THEN
                                    etat2 <= k2 ;
                                    next_etat2 <= l2 ;
                                    YPos_2 <= YPos_2 + 1 ;
                            ELSIF (YPos_2 = 1005) THEN
                                    etat2 <= l2 ;
                                    next_etat2 <= l2 ;
                                    YPos_2 <= YPos_2 ;

                            END IF;

                WHEN l2 =>  IF (XPos_2 > 490) THEN
                                    etat2 <= l2 ;
                                    next_etat2 <= m2 ;
                                    XPos_2 <= XPos_2 - 1 ;
                            ELSIF (XPos_2 = 490) THEN
                                    etat2 <= m2 ;
                                    next_etat2 <= m2 ;
                                    XPos_2 <= XPos_2 ;
                            END IF;



                WHEN m2 =>  IF (YPos_2 < 1005) THEN
                                    etat2 <= m2 ;
                                    next_etat2 <= n2 ;
                                    YPos_2 <= YPos_2 + 1 ;

                            ELSIF (YPos_2 = 1005) THEN
                                    etat2 <= n2 ;
                                    next_etat2 <= n2 ;
                                    YPos_2 <= YPos_2 ;

                            END IF;
WHEN n2 =>   IF (XPos_2 > 490 ) THEN
etat2 <= n2;
next_etat2 <= o2;
XPos_2 <= XPos_2 - 1 ;
ELSIF (XPos_2 = 490) THEN
                                    etat2 <= O2 ;
                                    next_etat2 <= o2 ;
                                    XPos_2 <= XPos_2 ;
                            END IF;
WHEN O2 =>  IF (YPos_2 > 980) THEN
                                    etat2 <= O2 ;
                                    next_etat2 <= O2 ;
                                    YPos_2 <= YPos_2 - 1 ;

                            ELSIF (YPos_2 = 980) THEN
                                    etat2 <= O2 ;
                                    --next_etat2 <= O2 ;
                                    XPos_2 <= XPos_2 ;
END IF;
IF (YPos_2 = 980) THEN
                                    etat2 <= n2 ;
                                    next_etat2 <= n2 ;
                                    XPos_2 <= XPos_2 ;

                            END IF;

                WHEN OTHERS =>      etat2 <= j2;
                                    next_etat2 <= j2;

            END CASE;

        END IF;

END IF;

END PROCESS;


---- Déplacement du véhicule d'urgence

PROCESS(clock_urgence, etat3, XPos_3 ,YPos_3)

BEGIN

------ Le départ et le retour son synchroniser sur l'horloge de 10 hZ-------

IF (rising_edge(clock_urgence)) THEN


------ départ du véhicule---------

        IF (start = '1' and back = '0') THEN

            CASE etat3 IS

                WHEN a3 =>  IF( XPos_3 > 455 ) THEN
                                    etat3 <= a3 ;
                                    next_etat3 <= b3 ;
                                    XPos_3 <= XPos_3 - 1 ;
                            ELSIF (XPos_3 = 455) THEN
                                    etat3 <= b3;
                                    next_etat3 <= b3;
                                    XPos_3 <= XPos_3 ;
                            END IF;

                WHEN b3 =>  IF ( YPos_3 > 715) THEN
                                    etat3 <= b3;
                                    next_etat3 <= c3 ;
                                    YPos_3<= YPos_3 - 1;

                            ELSIF (YPos_3 = 715) THEN
                                    etat3 <= c3;
                                    next_etat3 <= c3;
                                    YPos_3 <= YPos_3 ;
                            END IF;
                WHEN c3 =>  IF ( XPos_3 < 1035 ) THEN
                                    etat3 <= c3 ;
                                    next_etat3 <= d3 ;
                                    XPos_3 <= XPos_3 + 1 ;
                            ELSIF (XPos_3 = 1035) THEN
                                    etat3 <= d3;
                                    next_etat3 <= d3 ;
                                    XPos_3 <= XPos_3;
                            END IF;

                WHEN d3 =>  IF(YPos_3 < 740) THEN
                                    etat3 <= d3;
                                    next_etat3 <= e3 ;
                                    YPos_3 <= YPos_3 + 1 ;
                            END IF;

                WHEN e3 =>  IF (YPos_3 = 740) THEN
                                    etat3 <= e3;
                                    next_etat3 <= e3 ;
                                    YPos_3 <= YPos_3 ;
                            END IF;

                WHEN OTHERS =>      etat3 <= a3;
                                    next_etat3 <= a3;
            END CASE;
        END IF;

---------------- retour du véhicule -------------


        IF (back = '1' and start = '0') THEN
            CASE etat3 IS

                WHEN f3 =>  IF (XPos_3 < 1080) THEN
                                    etat3 <= f3 ;
                                    next_etat3 <= g3 ;
                                    XPos_3 <= XPos_3 + 1 ;
                            ELSIF (XPos_3 = 1080) THEN
                                    etat3 <= g3 ;
                                    next_etat3 <= g3 ;
                                    XPos_3 <= XPos_3 ;
                            END IF;
                WHEN g3 =>  IF (YPos_3 < 995) THEN
                                    etat3 <= g3 ;
                                    next_etat3 <= h3 ;
                                    YPos_3 <= YPos_3 + 1 ;
                            ELSIF (YPos_3 = 995) THEN
                                    etat3 <= h3 ;
                                    next_etat3 <= h3 ;
                                    YPos_3 <= YPos_3 ;
                            END IF;
WHEN h3 =>  IF (XPos_3 > 710) THEN
                                    etat3 <= h3 ;
                                    next_etat3 <= i3 ;
                                    XPos_3 <= XPos_3 - 1 ;
                            ELSIF (XPos_3 = 710) THEN
                                    etat3 <= i3 ;
                                    next_etat3 <= i3 ;
                                    XPos_3 <= XPos_3 ;
                            END IF;

                WHEN i3 =>  IF (YPos_3 > 980) THEN
                                    etat3 <= i3 ;
                                    next_etat3 <= i3 ;
                                    YPos_3 <= YPos_3 - 1 ;
                            ELSIF (YPos_3 = 980) THEN
                                    etat3 <= i3 ;
                                    next_etat3 <= i3 ;
                                    YPos_3 <= YPos_3 ;
                            END IF;

               

                WHEN OTHERS =>      etat3 <= f3;
                                    next_etat3 <= f3;
            END CASE;

        END IF;

END IF;

END PROCESS;

--- Déplacement du premier véhicule laitier
PROCESS(clock_laitier, etat4, XPos_4 ,YPos_4)

BEGIN

------ Le départ et le retour son synchroniser sur l'horloge de 10 hZ-------

        IF (rising_edge(clock_laitier)) THEN

------ Départ du véhicule---------

            IF (start = '1' and back = '0') THEN

                CASE etat4 IS

                    WHEN a4 =>  IF( XPos_4 > 455 ) THEN
                                    etat4 <= a4 ;
                                    next_etat4 <= b4 ;
                                    XPos_4 <= XPos_4 - 1 ;
                                ELSIF (XPos_4 = 455) THEN
                                    etat4 <= b4;
                                    next_etat4 <= b4;
                                    XPos_4 <= XPos_4 ;
                                END IF;
                    WHEN b4 =>  IF ( YPos_4 > 400) THEN
                                    etat4 <= b4;
                                    next_etat4 <= c4 ;
                                    YPos_4 <= YPos_4 - 1;
                                ELSIF (YPos_4 = 400) THEN
                                    etat4 <= c4;
                                    next_etat4 <= c4;
                                    YPos_4 <= YPos_4 ;
                                END IF;
                    WHEN c4 =>  IF ( XPos_4 < 785 ) THEN
                                    etat4 <= c4 ;
                                    next_etat4 <= d4 ;
                                    XPos_4 <= XPos_4 + 1 ;
                                ELSIF (XPos_4 = 785) THEN
                                    etat4 <= d4;
                                    next_etat4 <= d4 ;
                                    XPos_4 <= XPos_4;
                                END IF;
                    WHEN d4 =>  IF(YPos_4 < 421) THEN
                                    etat4 <= d4;
                                    next_etat4 <= e4 ;
                                    YPos_4 <= YPos_4 + 1 ;
                                END IF;
 
                    WHEN e4 =>  IF (YPos_4 = 421) THEN
                                    etat4 <= e4;
                                    next_etat4 <= e4 ;
                                    YPos_4 <= YPos_4 ;
                                END IF;
                                    WHEN OTHERS =>  etat4 <= a4;
                                    next_etat4 <= a4;
                END CASE;
            END IF;

---------------- retour du véhicule -------------

            IF (back = '1' and start = '0') THEN

                CASE etat4 IS

                    WHEN f4 =>  IF (XPos_4 < 1080) THEN
                                    etat4 <= f4 ;
                                    next_etat4 <= g4 ;
                                    XPos_4 <= XPos_4 + 1 ;
                                ELSIF (XPos_4 = 1080) THEN
                                    etat4 <= g4 ;
                                    next_etat4 <= g4 ;
                                    XPos_4 <= XPos_4 ;
                                END IF;
                    WHEN g4 =>  IF (YPos_4 < 995) THEN
                                    etat4 <= g4 ;
                                    next_etat4 <= h4 ;
                                    YPos_4 <= YPos_4 + 1 ;
                                ELSIF (YPos_4 = 995) THEN
                                    etat4 <= h4 ;
                                    next_etat4 <= h4 ;
                                    YPos_4 <= YPos_4 ;
                                END IF;
                    WHEN h4 =>  IF (XPos_4 > 900) THEN
                                    etat4 <= h4 ;
                                    next_etat4 <= i4 ;
                                    XPos_4 <= XPos_4 - 1 ;
                                ELSIF (XPos_4 = 900) THEN
                                    etat4 <= i4 ;
                                    next_etat4 <= i4 ;
                                    XPos_4 <= XPos_4 ;
                                END IF;
                    WHEN i4 =>  IF (YPos_4 > 980) THEN
                                    etat4 <= i4 ;
                                    next_etat4 <= j4 ;
                                    YPos_4 <= YPos_4 - 1 ;
                                ELSIF (YPos_4 = 980) THEN
                                    etat4 <= j4 ;
                                    next_etat4 <= j4 ;
                                    XPos_4 <= XPos_4 ;
                                END IF;
                    WHEN j4 =>  IF (YPos_4 = 980) THEN
                                    etat4 <= j4 ;
                                    next_etat4 <= j4 ;
                                    XPos_4 <= XPos_4 ;
                                END IF;
                    WHEN OTHERS =>  etat4 <= f4;
                                    next_etat4 <= f4;
                        END CASE;
            END IF;
        END IF;
END PROCESS;

--- Déplacement du second véhicule laitier
PROCESS(clock_laitier, etat5, XPos_5 ,YPos_5)

BEGIN

------ Le départ et le retour son synchroniser sur l'horloge de 10 hZ-------

        IF (rising_edge(clock_laitier)) THEN

------ Départ du véhicule---------

           
            IF (start = '1' and back = '0') THEN
                CASE etat5 IS
                    WHEN a5 =>  IF( XPos_5 > 455 ) THEN
                                    etat5 <= a5 ;
                                    next_etat5 <= b5 ;
                                    XPos_5 <= XPos_5 - 1 ;
                                ELSIF (XPos_5 = 455) THEN
                                    etat5 <= b5;
                                    next_etat5 <= b5;
                                    XPos_5 <= XPos_5 ;
                                END IF;
                    WHEN b5 =>  IF ( YPos_5 > 400) THEN
                                    etat5 <= b5;
                                    next_etat5 <= c5 ;
                                    YPos_5 <= YPos_5 - 1;
                                ELSIF (YPos_5 = 400) THEN
                                    etat5 <= c5;
                                    next_etat5 <= c5;
                                    YPos_5 <= YPos_5 ;
                                END IF;
                    WHEN c5 =>  IF ( XPos_5 < 815 ) THEN
                                    etat5 <= c5 ;
                                    next_etat5 <= d5 ;
                                    XPos_5 <= XPos_5 + 1 ;
                                ELSIF (XPos_5 = 815) THEN
                                    etat5 <= d5;
                                    next_etat5 <= d5 ;
                                    XPos_5 <= XPos_5;
                                END IF;
                    WHEN d5 =>  IF(YPos_5 < 421) THEN
                                    etat5 <= d5;
                                    next_etat5 <= e5 ;
                                    YPos_5 <= YPos_5 + 1 ;
                                END IF;
                   WHEN e5 =>  IF (YPos_5 = 421) THEN
                                    etat5 <= e5;
                                    next_etat5 <= e5 ;
                                    YPos_5 <= YPos_5 ;
                                END IF;
                    WHEN OTHERS =>  etat5 <= a5;
                                    next_etat5 <= a5;
                END CASE;
            END IF;

---------------- retour du véhicule -------------


            IF (back = '1' and start = '0') THEN
                CASE etat5 IS
                    WHEN f5 =>  IF (XPos_5 < 1080) THEN
                                    etat5 <= f5 ;
                                    next_etat5 <= g5 ;
                                    XPos_5 <= XPos_5 + 1 ;
                                ELSIF (XPos_5 = 1080) THEN
                                    etat5 <= g5 ;
                                    next_etat5 <= g5 ;
                                    XPos_5 <= XPos_5 ;
                                END IF;
                     WHEN g5 =>  IF (YPos_5 < 995) THEN
                                    etat5 <= g5 ;
                                    next_etat5 <= h5 ;
                                    YPos_5 <= YPos_5 + 1 ;
            ELSIF (YPos_5 = 995) THEN
                                    etat5 <= h5 ;
                                    next_etat5 <= h5 ;
                                    YPos_5 <= YPos_5 ;
            END IF;
                    WHEN h5 =>IF (XPos_5 > 930) THEN
                                    etat5 <= h5 ;
                                    next_etat5 <= i5 ;
                                    XPos_5 <= XPos_5 - 1 ;
                                ELSIF (XPos_5 = 930) THEN
                                    etat5 <= i5 ;
                                    next_etat5 <= i5 ;
                                    XPos_5 <= XPos_5 ;
                                END IF;
                    WHEN i5 =>  IF (YPos_5 > 980 ) THEN
                                    etat5 <= i5 ;
                                    next_etat5 <= j5 ;
                                    YPos_5 <= YPos_5 - 1 ;
                                ELSIF (YPos_5 = 980) THEN
                                    etat5 <= j5 ;
                                    next_etat5 <= j5 ;
                                    YPos_5 <= YPos_5 ;
                                END IF;
                    WHEN j5 =>  IF (YPos_5 = 980) THEN
                                    etat5 <= j5 ;
                                    next_etat5 <= j5 ;
                                    XPos_5 <= XPos_5 ;
                                END IF;
                    WHEN OTHERS =>  etat5 <= f5;
                                    next_etat5 <= f5;
END CASE;
            END IF;
        END IF;
END PROCESS;




--- Déplacement du premier véhicule d'usager

PROCESS(clock_usager, etat6, XPos_6 ,YPos_6)

BEGIN

------ Le départ et le retour son synchroniser sur l'horloge de 10 hZ-------
    IF (rising_edge(clock_usager)) THEN
-- départ du véhicule---------

            IF (start = '1' and back = '0') THEN
                CASE etat6 IS
                    WHEN a6 =>  IF( XPos_6 > 455 ) THEN
                                    etat6 <= a6 ;
                                    next_etat6 <= b6 ;
                                    XPos_6 <= XPos_6 - 1 ;
                                ELSIF (XPos_6 = 455) THEN
                                    etat6 <= b6;
                                    next_etat6 <= b6;
                                    XPos_6 <= XPos_6 ;
                                END IF;
                    WHEN b6 =>  IF ( YPos_6 > 78)THEN
                                    etat6 <= b6;
                                    next_etat6 <= c6 ;
                                    YPos_6 <= YPos_6 - 1;
                                ELSIF (YPos_6 = 78)THEN
                                    etat6 <= c6;
                                    next_etat6 <= c6;
                                    YPos_6 <= YPos_6 ;
                                END IF;
                    WHEN c6 =>  IF ( XPos_6 < 810) THEN
                                    etat6 <= c6 ;
                                    next_etat6 <= d6 ;
                                    XPos_6 <= XPos_6 + 1 ;
                                ELSIF (XPos_6 = 810)THEN
                                    etat6 <= d6;
                                    next_etat6 <= d6 ;
                                    XPos_6 <= XPos_6;
                                END IF;
                    WHEN d6 =>  IF(YPos_6 < 100)THEN
                                    etat6 <= d6;
                                    next_etat6 <= e6 ;
                                    YPos_6 <= YPos_6 + 1 ;
                                END IF;
                    WHEN e6 =>  IF (YPos_6 = 100)THEN
                                    etat6 <= e6;
                                    next_etat6 <= e6 ;
                                    YPos_3 <= YPos_3 ;
                                END IF;
                    WHEN OTHERS =>  etat6 <= a6;
                                    next_etat6 <= a6;
                END CASE;
            END IF;

                                    ---------------- retour du véhicule -------------

            IF (back = '1' and start = '0') THEN
                CASE etat6 IS
                    WHEN f6 =>  IF (XPos_6 < 1080)THEN
                                    etat6 <= f6 ;
                                    next_etat6 <= g6 ;
                                    XPos_6 <= XPos_6 + 1 ;
                                ELSIF (XPos_6 = 1080)THEN
                                    etat6 <= g6 ;
                                    next_etat6 <= g6 ;
                                    XPos_6 <= XPos_6 ;
                                END IF;
                    WHEN g6 =>  IF (YPos_6 < 1030)THEN
                                    etat6 <= g6 ;
                                    next_etat6 <= h6 ;
                                    YPos_6 <= YPos_6 + 1 ;
                                ELSIF (YPos_6 = 1030)THEN
                                    etat6 <= h6 ;
                                    next_etat6 <= h6 ;
                                    YPos_6 <= YPos_6 ;
                                END IF;
                    WHEN h6 =>IF (XPos_6 < 1130)THEN
                                    etat6 <= h6 ;
                                    next_etat6 <= i6 ;
                                    XPos_6 <= XPos_6 + 1 ;
                                ELSIF (XPos_6 = 1130)THEN
                                    etat6 <= i6 ;
                                    next_etat6 <= i6 ;
                                    XPos_6 <= XPos_6 ;
                                END IF;
                    WHEN i6 =>  IF (YPos_6 > 980) THEN
                                    etat6 <= i6 ;
                                    next_etat6 <= i6 ;
                                    YPos_6 <= YPos_6 - 1 ;
                                ELSIF (YPos_6 = 980) THEN
                                    etat6 <= i6 ;
                                    next_etat6 <= i6 ;
                                    XPos_6 <= XPos_6 ;
                                END IF;
                   
 WHEN OTHERS =>  etat6 <= f6;
                                    next_etat6 <= f6;
                 
                END CASE;
            END IF;
    END IF;
END PROCESS;

--- Déplacement du deuxieme véhicule d'usager

PROCESS(clock_usager, etat7, XPos_7 ,YPos_7)

BEGIN

------ Le départ et le retour son synchronisé sur l'horloge de 5 hZ-------

    IF (rising_edge(clock_usager)) THEN

-- départ du véhicule---------
        IF (start = '1' and back = '0') THEN
            CASE etat7 IS
                    WHEN a7 =>  IF( XPos_7 > 455 ) THEN
                                    etat7 <= a7 ;
                                    next_etat7 <= b7 ;
                                    XPos_7 <= XPos_7 - 1 ;
                                ELSIF (XPos_7 = 455) THEN
                                    etat7 <= b7;
                                    next_etat7 <= b7;
                                    XPos_7 <= XPos_7;
                                END IF;
                    WHEN b7 =>  IF ( YPos_7 > 400) THEN
                                    etat7 <= b7;
                                    next_etat7 <= c7 ;
                                    YPos_7 <= YPos_7 - 1;
                                ELSIF (YPos_7 = 400) THEN
                                    etat7 <= c7;
                                    next_etat7 <= c7;
                                    YPos_7 <= YPos_7 ;
                                END IF;
                    WHEN c7 =>  IF ( XPos_7 < 590 ) THEN
                                    etat7 <= c7 ;
                                    next_etat7 <= d7 ;
                                    XPos_7 <= XPos_7 + 1 ;
                                ELSIF (XPos_7 = 590) THEN
                                    etat7 <= d7;
                                    next_etat7 <= d7 ;
                                    XPos_7 <= XPos_7;
                                END IF;
                    WHEN d7 =>  IF(YPos_7 < 421) THEN
                                    etat7 <= d7;
                                    next_etat7 <= e7 ;
                                    YPos_7 <= YPos_7 + 1 ;
                                END IF;
                    WHEN e7 =>  IF (YPos_7 = 421) THEN
                                    etat7 <= e7;
                                    next_etat7 <= e7 ;
                                    YPos_7 <= YPos_7 ;
                                END IF;
                                    WHEN OTHERS =>
                                    etat7 <= a7;
                                    next_etat7 <= a7;
            END CASE;
        END IF;

-- retour du véhicule -------------
        IF (back = '1' and start = '0') THEN
            CASE etat7 IS
                    WHEN f7 =>  IF (XPos_7 < 640) THEN
                                    etat7 <= f7 ;
                                    next_etat7 <= g7 ;
                                    XPos_7 <= XPos_7 + 1 ;
                                ELSIF (XPos_7 = 640) THEN
                                    etat7 <= g7 ;
                                    next_etat7 <= g7 ;
                                    XPos_7 <= XPos_7 ;
                                END IF;
                    WHEN g7 =>  IF (YPos_7 < 715) THEN
                                    etat7 <= g7 ;
                                    next_etat7 <= h7 ;
                                    YPos_7 <= YPos_7 + 1 ;
                                ELSIF (YPos_7 = 715) THEN
                                    etat7 <= h7 ;
                                    next_etat7 <= h7 ;
                                    YPos_7 <= YPos_7 ;
                                END IF;
                    WHEN h7 =>  IF (XPos_7 < 1080) THEN
                                    etat7 <= h7 ;
                                    next_etat7 <= i7 ;
                                    XPos_7 <= XPos_7 + 1 ;
                                ELSIF (XPos_7 = 1080) THEN
                                    etat7 <= i7 ;
                                    next_etat7 <= i7 ;
                                    XPos_7 <= XPos_7 ;
                                END IF;
                    WHEN i7 =>  IF (YPos_7 < 1030) THEN
                                    etat7 <= i7 ;
                                    next_etat7 <= j7 ;
                                    YPos_7 <= YPos_7 + 1 ;
                                ELSIF (YPos_7 = 1030) THEN
                                    etat7 <= j7 ;
                                    next_etat7 <= j7 ;
                                    XPos_7 <= XPos_7 ;
                                END IF;
 WHEN j7 =>  IF (XPos_7 < 1160) THEN
                                    etat7 <= j7 ;
                                    next_etat7 <= k7 ;
                                    XPos_7 <= XPos_7 + 1 ;
                                ELSIF (XPos_7 = 1160) THEN
                                    etat7 <= k7 ;
                                    next_etat7 <= k7 ;
                                    XPos_7 <= XPos_7 ;
                                END IF;
                    WHEN k7 =>  IF (YPos_7 > 980) THEN
                                    etat7 <= k7 ;
                                    next_etat7 <= k7 ;
                                    YPos_7 <= YPos_7 - 1 ;
                                ELSIF (YPos_7 = 980) THEN
                                    etat7 <= k7 ;
                                    next_etat7 <= k7 ;
                                    XPos_7 <= XPos_7 ;
                                END IF;
                   
                    WHEN OTHERS =>  etat7 <= f7;
                                    next_etat7 <= f7;
            END CASE;
        END IF;
    END IF;
END PROCESS;


--- Déplacement du troisieme véhicule d'usager

PROCESS(clock_usager, etat8, XPos_8 ,YPos_8, congestion)

BEGIN

------ Le départ et le retour son synchroniser sur l'horloge de 5 hZ-------

    IF (rising_edge(clock_usager)) THEN

-- Départ de la voiture---------
        IF (start = '1' and back = '0') THEN
            IF(congestion  ='0') THEN
                             ---- Absence de la congestion------
                CASE etat8 IS
                    WHEN a8 =>  IF( XPos_8 < 1275 ) THEN
                                  -- YPos_8 <= YPos_8 + 5;
etat8 <= a8 ;
                                    next_etat8 <= b8 ;
                                    XPos_8 <= XPos_8 + 1 ;
                                ELSIF (XPos_8 = 1275) THEN
                                    etat8 <= b8;
                                    next_etat8 <= b8;
                                    XPos_8 <= XPos_8;
                                END IF;
                    WHEN b8 =>  IF ( YPos_8 > 675) THEN
                                    etat8 <= b8;
                                    next_etat8 <= c8 ;
                                    YPos_8 <= YPos_8 - 1;
                                ELSIF (YPos_8 = 675) THEN
                                    etat8 <= c8;
                                    next_etat8 <= c8;
                                    YPos_8 <= YPos_8 ;
                                END IF;
                    WHEN c8 =>  IF ( XPos_8 >710 ) THEN
                                    etat8 <= c8 ;
                                    next_etat8 <= d8 ;
                                    XPos_8 <= XPos_8 - 1 ;
                                ELSIF (XPos_8 = 710) THEN
                                    etat8 <= d8;
                                    next_etat8 <= d8 ;
                                    XPos_8 <= XPos_8;
                                END IF;
                    WHEN d8 =>  IF(YPos_8 > 660) THEN
                                    etat8 <= d8;
                                    next_etat8 <= e8 ;
                                    YPos_8 <= YPos_8 - 1 ;
                                END IF;
                    WHEN e8 =>  IF (YPos_8 = 660) THEN
                                    etat8 <= e8;
                                    next_etat8 <= e8 ;
                                    YPos_8 <= YPos_8 ;
                                END IF;
                    WHEN OTHERS =>  etat8 <= a8;
                                    next_etat8 <= a8;
                                END CASE;
            ELSIF(congestion = '1') THEN
---- présence de la congestion ----
                CASE etat8 IS
                    WHEN a8 =>  IF( XPos_8 < 1275 ) THEN
                                    etat8 <= a8 ;
                                    next_etat8 <= b8 ;
                                    XPos_8 <= XPos_8 + 1 ;
                                ELSIF (XPos_8 = 1275) THEN
                                    etat8 <= b8;
                                    next_etat8 <= b8;
                                    XPos_8 <= XPos_8;
                                END IF;
                    WHEN b8 =>  IF ( YPos_8 > 995) THEN
                                    etat8 <= b8;
                                    next_etat8 <= c8 ;
                                    YPos_8 <= YPos_8 - 1;
                                ELSIF (YPos_8 = 995) THEN
                                    etat8 <= c8;
                                    next_etat8 <= c8;
                                    YPos_8 <= YPos_8 ;
                                END IF;
                    WHEN c8 =>  IF ( XPos_8 > 455 ) THEN
                                    etat8 <= c8 ;
                                    next_etat8 <= d8 ;
                                    XPos_8 <= XPos_8 - 1 ;
                                ELSIF (XPos_8 = 455) THEN
                                    etat8 <= d8;
                                    next_etat8 <= d8 ;
                                    XPos_8 <= XPos_8;
                                END IF;
                    WHEN d8 =>  IF ( YPos_8 > 715 ) THEN
                                    etat8 <= d8 ;
                                    next_etat8 <= e8 ;
                                    YPos_8 <= YPos_8 - 1 ;
                                ELSIF (YPos_8 = 715) THEN
                                    etat8 <= e8;
                                    next_etat8 <= e8 ;
                                    YPos_8 <= YPos_8;
                                END IF;
                    WHEN e8 =>  IF ( XPos_8 < 710) THEN
                                    etat8 <= e8 ;
                                    next_etat8 <= f8 ;
                                    XPos_8 <= XPos_8 + 1 ;
                                ELSIF (XPos_8 = 710) THEN
                                    etat8 <= f8;
                                    next_etat8 <= f8 ;
                                    XPos_8 <= XPos_8;
                                END IF;
                    WHEN f8 =>  IF(YPos_8 > 660) THEN
                                    etat8 <= f8;
                                    next_etat8 <= g8 ;
                                    YPos_8 <= YPos_8 - 1 ;
                                END IF;
                    WHEN g8 =>  IF (YPos_8 = 660) THEN
                                    etat8 <= g8;
                                    next_etat8 <= g8 ;
                                    YPos_8 <= YPos_8 ;
                                END IF;
                                    WHEN OTHERS =>  etat8 <= a8;
                                    next_etat8 <= a8;
                END CASE;
            END IF;
        END IF;

--- retour du véhicule -------------

                        IF (back = '1' and start = '0') THEN
 CASE etat8 IS
                                    WHEN h8 =>
IF (XPos_8 > 640) THEN
etat8 <= h8 ;
next_etat8 <= i8 ;
XPos_8 <= XPos_8 - 1;
ELSIF (XPos_8 = 640) THEN
etat8 <= i8 ;
next_etat8 <= i8 ;
XPos_8 <= XPos_8 ;
END IF;
                                    WHEN i8 =>  
IF (YPos_8 < 1030) THEN
etat8 <= i8 ;
next_etat8 <= j8 ;
YPos_8 <= YPos_8 + 1 ;
ELSIF (YPos_8 = 1030) THEN
etat8 <= j8 ;
next_etat8 <= j8 ;
YPos_8 <= YPos_8 ;
END IF;
                                    WHEN j8 =>  
IF (XPos_8 < 1220) THEN
etat8 <= j8 ;
next_etat8 <= k8;
XPos_8 <= XPos_8 + 1 ;
ELSIF (XPos_8 = 1220) THEN
etat8 <= k8 ;
next_etat8 <= k8 ;
XPos_8 <= XPos_8 ;
END IF;
                                    WHEN k8 =>  
IF (YPos_8 > 980) THEN
etat8 <= k8 ;
next_etat8 <= l8 ;
YPos_8 <= YPos_8 - 1 ;
ELSIF (YPos_8 = 980) THEN
etat8 <= l8 ;
next_etat8 <= l8 ;
XPos_8 <= XPos_8 ;
END IF;
                                    WHEN l8 =>  
IF (YPos_8 = 980) THEN
etat8 <= l8 ;
next_etat8 <= l8 ;
XPos_8 <= XPos_8 ;
END IF;
                                    WHEN OTHERS =>etat8 <= h8;
                                    next_etat8 <= h8;
            END CASE;
        END IF;
    END IF;
END PROCESS;

--- Déplacement du quatrieme véhicule d'usager

PROCESS(clock_usager, etat9, XPos_9 ,YPos_9)

BEGIN

------ Le départ et le retour son synchronisé sur l'horloge de 5 hZ-------

    IF (rising_edge(clock_usager)) THEN

-- départ du véhicule---------
        IF (start = '1' and back = '0') THEN
            CASE etat9 IS
                    WHEN a9 =>  IF( XPos_9 > 455 ) THEN
                                    etat9 <= a9 ;
                                    next_etat9 <= b9 ;
                                    XPos_9 <= XPos_9 - 1 ;
                                ELSIF (XPos_9 = 455) THEN
                                    etat9 <= b9;
                                    next_etat9 <= b9;
                                    XPos_9 <= XPos_9;
                                END IF;
                    WHEN b9 =>  IF ( YPos_9 > 78) THEN
                                    etat9 <= b9;
                                    next_etat9 <= c9 ;
                                    YPos_9 <= YPos_9 - 1;
                                ELSIF (YPos_9 = 78) THEN
                                    etat9 <= c9;
                                    next_etat9 <= c9;
                                    YPos_9 <= YPos_9 ;
                                END IF;
                    WHEN c9 =>  IF ( XPos_9 < 590 ) THEN
                                    etat9 <= c9 ;
                                    next_etat9 <= d9 ;
                                    XPos_9 <= XPos_9 + 1 ;
                                ELSIF (XPos_9 = 590) THEN
                                    etat9 <= d9;
                                    next_etat9 <= d9 ;
                                    XPos_9 <= XPos_9;
                                END IF;
                    WHEN d9 =>  IF(YPos_9 < 100) THEN
                                    etat9 <= d9;
                                    next_etat9 <= e9 ;
                                    YPos_9 <= YPos_9 + 1 ;
                                END IF;
                    WHEN e9 =>  IF (YPos_9 = 100) THEN
                                    etat9 <= e9;
                                    next_etat9 <= e9 ;
                                    YPos_9 <= YPos_9 ;
                                END IF;
                                    WHEN OTHERS =>
                                    etat9 <= a9;
                                    next_etat9 <= a9;
            END CASE;
        END IF;

-- retour du véhicule -------------
        IF (back = '1' and start = '0') THEN
            CASE etat9 IS
                    WHEN f9 =>  IF (XPos_9 < 640) THEN
                                    etat9 <= f9 ;
                                    next_etat9 <= g9 ;
                                    XPos_9 <= XPos_9 + 1 ;
                                ELSIF (XPos_9 = 640) THEN
                                    etat9 <= g9 ;
                                    next_etat9 <= g9 ;
                                    XPos_9 <= XPos_9 ;
                                END IF;
                    WHEN g9 =>  IF (YPos_9 < 1030) THEN
                                    etat9 <= g9 ;
                                    next_etat9 <= h9 ;
                                    YPos_9 <= YPos_9 + 1 ;
                                ELSIF (YPos_9 = 1030) THEN
                                    etat9 <= h9 ;
                                    next_etat9<= h9 ;
                                    YPos_9 <= YPos_9 ;
                                END IF;
                    WHEN h9 =>  IF (XPos_9 < 1190) THEN
                                    etat9 <= h9 ;
                                    next_etat9 <= i9 ;
                                    XPos_9 <= XPos_9 + 1 ;
                                ELSIF (XPos_9 = 1190) THEN
                                    etat9 <= i9 ;
                                    next_etat9 <= i9 ;
                                    XPos_9 <= XPos_9 ;
                                END IF;
                                    WHEN i9 =>  IF (YPos_9 > 980) THEN
                                    etat9 <= i9 ;
                                    next_etat9 <= j9 ;
                                    YPos_9 <= YPos_9 - 1 ;
                                ELSIF (YPos_9= 980) THEN
                                    etat9 <= j9 ;
                                    next_etat9 <= j9 ;
                                    XPos_9 <= XPos_9 ;
                                END IF;
                    WHEN j9 =>  IF (YPos_9= 980) THEN
                                    etat9 <= j9 ;
                                    next_etat9 <= j9 ;
                                    XPos_9 <= XPos_9 ;
                                END IF;
                    WHEN OTHERS =>  etat9 <= f9;
                                    next_etat9 <= f9;
            END CASE;
        END IF;
    END IF;
END PROCESS;
--------------------------------------------------------------------------------------
----- POUR LA CONSTRUCTION -------
--------------------------------------------------------------------------------------

PROCESS(CLOCK)

BEGIN

    IF (rising_edge(CLOCK)) THEN
--------------------------------------------------------------
------- Présence ou absence de la congesion ------
--------------------------------------------------------------
                IF(congestion = '1') THEN
                            IF(Accidents ='1')THEN
                                    RED <= "11000000";
                                    GREEN <= "11000000";
                                    BLUE <= "11000000";
                            END IF;
                ELSE
                            IF(Accidents ='1')THEN
                                    RED <= (OTHERS => '1');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '1');
                            END IF;
                END IF;
--------------------------------------------------------------
------ Route barrée à cause des travaux ou pas --------------
--------------------------------------------------------------
                IF(travaux = '1') THEN
                            IF(Bouchons ='1')THEN
                                    RED <= "11000000";
                                    GREEN <= "11000000";
                                    BLUE <= "11000000";
                            END IF;
                ELSE

                            IF(Bouchons ='1')THEN

                                    RED <= (OTHERS => '1');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '1');
                            END IF;
                END IF;

-----------------------------------------------------------------------------------------
---------- Réalisation de la section ville de Gatineau --------------
-----------------------------------------------------------------------------------------

IF(Bouchons='0' AND Accidents ='0' AND Police_2 = '0' AND
Vehicule_3 = '0' AND Vehicule_2 = '0' AND Vehicule_1 = '0' AND  Laitier_1 = '0'
   AND Urgence_1 = '0' AND  Laitier_2 = '0' AND  Police_1 = '0')    THEN

--- Nous nous sommes servit du TP4 pour le dessin de la ville---



----------------- PREMIERE RANGÉE DE BATIMENTS ET DE ROUTE--------------

                    IF (VPOS > 120 AND VPOS < 335) THEN

                            IF(HPOS > 490 AND HPOS < 610) THEN

                                 RED <= "00000000";
GREEN <= "00000000";
BLUE <= "11111111";

                            ELSIF(HPOS > 710  AND HPOS < 1050) THEN

                                    RED   <= "10101001";
                                    GREEN <= "10101001";
                                    BLUE  <= "10101001";

                            ELSIF(HPOS > 1130  AND HPOS < 1250) THEN

                                          RED <= "01011000";
                    GREEN <= "00101001";
BLUE <= "00000000";


                            ELSIF(HPOS > 1310  AND HPOS < 1430) THEN

                                          RED <= "01011000";
GREEN <= "00101001";
BLUE <= "00000000";


                            ELSIF(HPOS > 1510  AND HPOS < 1630) THEN

                                          RED <= "11111111";
GREEN <= "00000000";
BLUE <= "00000000";
                            ELSE

                                    RED   <= "11111111";
GREEN <= "11111111";
BLUE  <= "11111111";

                            END IF;


--------------------- DEUXIEME RANGÉE DE BATIMENTS ET ROUTES---------------


                    ELSIF(VPOS > 442 AND VPOS < 657) THEN

                            IF(HPOS > 490 AND HPOS < 610 ) THEN

                                     RED <= "01011000";
            GREEN <= "00101001";
            BLUE <= "00000000";

                            ELSIF(HPOS > 710  AND HPOS < 830) THEN

                                    RED <= "01011000";
            GREEN <= "00101001";
            BLUE <= "00000000";

                            ELSIF(HPOS > 930  AND HPOS < 1050) THEN

                                    RED <= "01011000";
            GREEN <= "00101001";
            BLUE <= "00000000";

                            ELSIF(HPOS > 1130  AND HPOS < 1430) THEN

                                    RED <= "00000000";
GREEN <= "10110000";
BLUE <= "10100000";


                            ELSIF(HPOS > 1510  AND HPOS < 1630) THEN

                                    RED <= "01011000";
            GREEN <= "00101001";
            BLUE <= "00000000";                          

                            ELSE

                                   RED <= "11111111";
                                    GREEN <= "11111111";
                                    BLUE <= "11111111";

                            END IF;

---------------------TROISIEME RANGÉE DE BATIMENTS ET DE ROUTE------------------

                    ELSIF(VPOS > 764 AND VPOS < 979) THEN

                            IF(HPOS > 490 AND HPOS < 610 ) THEN

                                  RED <= "01011000";
            GREEN <= "00101001";
            BLUE <= "00000000";

                            ELSIF(HPOS > 690  AND HPOS < 1050) THEN

                                    RED <= "11111111";
GREEN <= "11111111";
BLUE <= "00000000";


                            ELSIF(HPOS > 1130  AND HPOS < 1250) THEN

                                  RED <= "01011000";
            GREEN <= "00101001";
            BLUE <= "00000000";

                            ELSIF(HPOS > 1310  AND HPOS < 1430) THEN

                                  RED <= "01011000";
            GREEN <= "00101001";
            BLUE <= "00000000";

                            ELSIF(HPOS > 1510  AND HPOS < 1630) THEN

                                  RED <= "01011000";
            GREEN <= "00101001";
            BLUE <= "00000000";

                           

                            ELSE
RED <= "11111111";
                                    GREEN <= "11111111";
                                    BLUE <= "11111111";

                                   

                            END IF;
                            ELSE

                                    RED <= (OTHERS => '1');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '1');

                            END IF;

                    END IF;
 
---------------------------------------------------------------
--------- Conception et affichage des véhicules ------
--------- Nous allons dessiner et afficher les voitures sur le plan----            
---------------------------------------------------------------
----------------------------------------------------------------
--------- voiture de Police -----------------------------    
----------------------------------------------------------------  
 
 
 ---couleur des véhicules

                     
 IF(Urgence_1 = '1') THEN   -- Urgence
                                    RED <= (OTHERS => '1');
                                    GREEN <= (OTHERS => '0');
                                    BLUE <= (OTHERS => '0');
                    END IF;
 
                    IF(Police_2 = '1' ) then -- Police

                                    RED <= (OTHERS => '0');
                                    GREEN <= (OTHERS => '0');
                                    BLUE <= (OTHERS => '1');
                    END IF;
 
 
 IF(Police_1 = '1' ) then -- Police

                                    RED <= (OTHERS => '0');
                                    GREEN <= (OTHERS => '0');
                                    BLUE <= (OTHERS => '1');
                    END IF;
 
 IF(Laitier_1 = '1') THEN -- Laitier
                                    RED <= (OTHERS => '0');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '0');
END IF;
 
                    IF(Laitier_2 = '1') THEN  -- Laitier
                                    RED <= (OTHERS => '0');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '0');
                    END IF;
 
                 
                   
                    IF(Vehicule_1 = '1') THEN  -- Usager

                                    RED <= (OTHERS => '1');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '0');
                    END IF;
                    IF(Vehicule_2 = '1') THEN  -- Usager

                                    RED <= (OTHERS => '1');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '0');
                    END IF;

                    IF(Vehicule_3 = '1') THEN -- Usager

                                    RED <= (OTHERS => '1');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '0');
 END IF;

                    IF(Vehicule_4 = '1') THEN -- Usager

                                    RED <= (OTHERS => '1');
                                    GREEN <= (OTHERS => '1');
                                    BLUE <= (OTHERS => '0');
                    END IF;
                 
                   

Route_barree (HPOS, VPOS, XPos_10, YPos_10,Accidents);

Route_barree (HPOS, VPOS, XPos_11, YPos_11,Bouchons);


-----------------------------------------------------------------------------------
---------- Affichage des résultats      -----------------------
-----------------------------------------------------------------------------------


IF (HPOS < HZ_SCAN_WIDTH) THEN
HPOS <= HPOS + 1;
ELSE
HPOS <= 0;

IF (VPOS < VT_SCAN_WIDTH) THEN
VPOS <= VPOS + 1;
ELSE

VPOS <= 0;
END IF;

END IF;

IF (HPOS > HZ_FRONT_PORCH and HPOS < (HZ_FRONT_PORCH + HZ_SYNC)) THEN
HSYNC <= HS_POLARITY;
ELSE
HSYNC <= not HS_POLARITY;
END IF;

IF (VPOS > VT_FRONT_PORCH and VPOS < (VT_FRONT_PORCH + VT_SYNC)) THEN
VSYNC <= VT_POLARITY;
ELSE
VSYNC <= not VT_POLARITY;
END IF;

IF (HPOS > (HZ_FRONT_PORCH + HZ_SYNC + HZ_BACK_PORCH) and VPOS > (VT_FRONT_PORCH + VT_SYNC + VT_BACK_PORCH)) THEN
DISPLAY <= '1';

X <= HPOS - (HZ_FRONT_PORCH + HZ_SYNC + HZ_BACK_PORCH - 1);
Y <= VPOS - (VT_FRONT_PORCH + VT_SYNC + VT_BACK_PORCH - 1);

ELSE
DISPLAY <= '0';
X <= 0;
Y <= 0;
RED <= (OTHERS => '0');
GREEN <= (OTHERS => '0');
BLUE <= (OTHERS => '0');
END IF;
END IF;
END PROCESS;

--------------------------------------------------------------------------------------------------------------
------------ Création et incrémentation d'un compteur de  0 A 999.999  -------
------------ Le comptage se fait de la droite vers la gauche comme suit:   -------
------------ on compte de 0 à 9 les variables. Une la valeur 9 atteinte, on assigne la valeur 1 au segment suivant  -------
------------ et le compotage recommence ainsi pour tous les variables      --------
--------------------------------------------------------------------------------------------------------------

process(s1,s2,s3,s4,s5,s6,clock_police, rst)

begin

if(rising_edge(clock_police)) then
---------------------------------------------------------
-----Enclenchement du comptage ----
---------------------------------------------------------

if(start ='1' OR back = '1') then

if(s1 < 9) then

s1<=s1+1;

elsif(s1=9) then

s1 <= 0;

if(s2<9) then

s2<=s2+1;

elsif(s2=9) then

s2<=0;

if(s3<9) then

s3<=s3+1;

elsif(s3=9)then

s3<=0;


if(s4<9)then

s4<=s4+1;

elsif(s4=9)then

s4<=0;

if(s5<9)then

s5<=s5+1;

elsif(s5=9)then

s5<=0;

if(s6<9)then

s6<= s6+1;

elsif(s6=9)then

s6<=0;

end if;
end if;
end if;
end if;
end if;
end if;
end if;
------------------------------
---Remise à zéro du compteur ---
------------------------------

if(rst='1')then

s1<=0;
s2<=0;
s3<=0;
s4<=0;
s5<=0;
s6<=0;

end if;

end if;

end process;

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--------- Fonctionnement de l'afficheur 7 segments:  ----------
--------- l'afficheur doit afficher de 0 à 9 en fonction du signal ----------
---------- Chaque fois que le système s'enclenche, le comptage commence
--------------ce-ci est valable pour le retour des véhicules aussi -------------------
-------------------------------------------------------------------------------------

----Segment 1 -----
process(s1)

begin

if(rising_edge(clock_police))then

case s1 is

when 0 =>

segment_0<="1000000";

when 1=>

segment_0<="1111001";

when 2=>

segment_0<="0100100";

when 3=>

segment_0<="0110000";

when 4=>

segment_0<="0011001";

when 5=>

segment_0<="0010010";

when 6=>

segment_0<="0000010";

when 7=>

segment_0<="1111000";

when 8=>

segment_0<="0000000";

when 9=>                  

segment_0 <="0010000";

when 10=>

segment_0<="1000000";

when others =>

segment_0 <="0010000";

end case;

end if;

end process;
----Segment 2-----

process(s2,clock_police)

begin

if(rising_edge(clock_police)) then

case s2 is

when 0 =>

segment_1<="1000000";

when 1=>

segment_1<="1111001";

when 2=>

segment_1<="0100100";

when 3=>

segment_1<="0110000";

when 4=>

segment_1<="0011001";

when 5=>

segment_1<="0010010";

when 6=>

segment_1<="0000010";

when 7=>

segment_1<="1111000";

when 8=>

segment_1<="0000000";

when 9=>                  

segment_1 <="0010000";

when 10=>

segment_1<="1000000";
when others =>

segment_1 <="0010000";

end case;

end if;

end process;

----Segment 3 -----
process(s3,clock_police)

begin

if(rising_edge(clock_police)) then

case s3 is

when 0 =>

segment_2<="1000000";
when 1=>

segment_2<="1111001";

when 2=>

segment_2<="0100100";

when 3=>

segment_2<="0110000";
when 4=>

segment_2<="0011001";

when 5=>

segment_2<="0010010";

when 6=>

segment_2<="0000010";

when 7=>

segment_2<="1111000";

when 8=>

segment_2<="0000000";

when 9=>

segment_2 <="0010000";    

when 10=>

segment_2<="1000000";

when others =>

segment_2 <="0010000";

end case;

end if;

end process;

----Segment 4 -----
process(s4,clock_police)

begin

if(rising_edge(clock_police)) then

case s4 is

when 0 =>

segment_3<="1000000";

when 1=>

segment_3<="1111001";

when 2=>

segment_3<="0100100";

when 3=>

segment_3<="0110000";

when 4=>

segment_3<="0011001";

when 5=>

segment_3<="0010010";

when 6=>

segment_3<="0000010";

when 7=>

segment_3<="1111000";
when 8=>

segment_3<="0000000";

when 9=>                  

segment_3 <="0010000";

when 10=>

segment_3<="1000000";

when others =>

segment_3 <="0010000";

end case;

end if;

end process;

----Segment 5 -----
process(s5,clock_police)

begin

if(rising_edge(clock_police)) then

case s5 is

when 0 =>

segment_4<="1000000";
when 1=>

segment_4<="1111001";
when 2=>

segment_4<="0100100";

when 3=>

segment_4<="0110000";

when 4=>

segment_4<="0011001";

when 5=>

segment_4<="0010010";

when 6=>

segment_4<="0000010";

when 7=>

segment_4<="1111000";

when 8=>

segment_4<="0000000";

when 9=>                  

segment_4 <="0010000";

when 10=>

segment_4<="1000000";

when others =>

segment_4 <="0010000";

end case;

end if;

end process;

----Segment 6 -----
process(s6,clock_police)

begin

if(rising_edge(clock_police)) then

case s6 is

when 0 =>

segment_5<="1000000";

when 1=>

segment_5<="1111001";

when 2=>

segment_5<="0100100";

when 3=>

segment_5<="0110000";

when 4=>

segment_5<="0011001";

when 5=>

segment_5<="0010010";

when 6=>

segment_5<="0000010";

when 7=>

segment_5<="1111000";

when 8=>

segment_5<="0000000";

when 9=>

segment_5 <="0010000";

when 10=>

segment_5<="1000000";

when others =>

segment_5 <="0010000";

end case;

end if;
end process;
END MAIN;
