
--                     P L S Q L   Ü B U N G  -  R I T T                     --
-- =============================== 20.1.2025 =============================== --
                                                           set serveroutput on;
-- ‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗ Angabe : To do ‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗ --


/* Ⅱ.)  ▻  P L - S Q L   C u r s o r

  Schreiben Sie eine PLSQL-Funktion CALC_PLAYER_BONUS, welche als Ergebnis 
    die Bonuszahlung eines Tennis-Spielers berechnet (Parameter player_id)
  Wenn der Spieler bei einem Spiel um 3 Sätze mehr gewonnen als verloren hat, er einen Bonus von 100€
    
  Ansonsten bekommt er für jeden gewonnenen Satz 10€, für jeden verloreren werden ihm 5€ abgezogen.
  
  Rückgabewert: 
    Summe der Bonuszahlungen des Spielers, negative Beträge sollen als 0 ausgegeben werden.

  Rufen Sie die Funktion per SQL Select für alle Spieler auf.

‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/

/* ▻   U S E :  Ausgabe                    CALC_PLAYER_BONUS( playerno NUMBER )
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                             -- DROP FUNCTION CALC_PLAYER_BONUS;

-- ▻ NUR DER BONUS je Spieler:
SELECT CALC_PLAYER_BONUS( PLAYERNO ) FROM PLAYERS;

-- ▻ FORMATIERTE VOLLSTÄNDIGE Ausgabe:
SELECT                                      
    pl.PLAYERNO                            as "Spielernummer"
  , pl.NAME                                as "Familienname"
  , CALC_PLAYER_BONUS( p.PLAYERNO ) || '€' as "Bonuszahlungen"
  , CALC_PLAYER_MATCH_COUNT( m.PLAYERNO )  as "Matchanzahl"
  FROM PLAYERS p 
    JOIN PLAYERS pl ON( pl.PLAYERNO = p.PLAYERNO )
    JOIN MATCHES m ON( m.PLAYERNO = p.PLAYERNO )
      GROUP BY
          pl.PLAYERNO
        , pl.NAME
        , p.PLAYERNO
        , m.PLAYERNO
      ORDER BY "Matchanzahl" desc;
COMMIT;
--———————————————————————————————————————————————————————————————————————————--


/* ▻   C R E A T E   Function :       CALC_PLAYER_BONUS( player_Num in NUMBER )
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                             --DROP FUNCTION CALC_PLAYER_BONUS;
CREATE or REPLACE 
                FUNCTION 
                        CALC_PLAYER_BONUS( player_Num in NUMBER )
-------------------------------------------------------------------------------
RETURN VARCHAR 
  IS
      money   NUMBER := 0
    ; diff    NUMBER := 0
    ; sumWon  NUMBER := 0
    ; sumLose NUMBER := 0
  -- - - - - - - - - - - - --
    ; tempM   matches%ROWTYPE
    ; CURSOR  m is SELECT * FROM matches WHERE player_Num = PLAYERNO ORDER BY PLAYERNO 
  -- - - - - - - - - - - - --
    ; sol Varchar(90) 
    ;
  BEGIN
    OPEN m;
    LOOP FETCH m INTO tempM;
    -------------------------------------
      IF m%FOUND THEN
      -- - - - - - - --
        IF player_Num = tempM.playerno then
          diff := tempM.won - tempM.lost;
          -- - - - - - - --
          IF diff >= 3 THEN
            money := money + 100; 
          END IF;
          -- - - - - - - --
          IF diff < 0 THEN
            diff := 0;
          END IF;
          -- - - - - - - --
          money := money + ( tempM.won * 10 ) - (tempM.lost * 5);
          sumLose := sumLose + tempM.lost;
          sumWon := sumWon + tempM.won;
          -- - - - - - - --
          IF money < 0 THEN
            money := 0;
          END IF;
          -- - - - - - - --
        END IF;
        sol := ( 
                'Spieler-Nummer: ' || LPAD(player_Num,3,' ') ||
                '   | Bonus: '     || LPAD(money,     4,' ') ||
                '€  | Wins/Loses: '|| LPAD(sumWon,    2,' ') ||
                '/'                || LPAD(sumLose,   2,' ')
               );
      END IF;
    -- - - - - - - --
    EXIT WHEN m%NOTFOUND;
      diff := 0;
    END LOOP;
    -------------------------------------
    dbms_output.put_line( sol );
  RETURN money;
  CLOSE m;
END;
/
--———————————————————————————————————————————————————————————————————————————--
 



/* ▻    N  O  T  I  Z  E  N    zu    Ⅱ.                                      --

/* ▻   U S E :                     CALC_PLAYER_MATCH_COUNT ( playerno NUMBER );
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
--        Summe aller gespielten Matches eines Spielers 
--          IN       NUMBER   playerno
--          RETURN   NUMBER  
SELECT CALC_PLAYER_MATCH_COUNT(playerno) from PLAYERS;


/* ▻   C R E A T E   Function :      CALC_PLAYER_MATCH_COUNT ( pl_num NUMBER );
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                      -- DROP FUNCTION CALC_PLAYER_MATCH_COUNT;
CREATE or REPLACE 
                FUNCTION 
                        CALC_PLAYER_MATCH_COUNT ( pl_num NUMBER )
-------------------------------------------------------------------------------
RETURN NUMBER
  IS
    CURSOR t IS 
      SELECT 
          SUM( m.WON ) + SUM( m.LOST ) as summe
      --    , p.*
      --  , p.playerNo
      --  , p.name 
          FROM MATCHES m JOIN PLAYERS p 
            on ( p.PLAYERNO = m.PLAYERNO )
              WHERE p.PLAYERNO = pl_num
              GROUP by 
                  p.PLAYERNO
                , p.HOUSENO
                , p.INITIALS
                , p.LEAGNO
                , p.NAME 
                , p.PHONENO 
                , p.POSTCODE
                , p.SEX
                , p.STREET
                , p.TOWN
                , p.YEAR_JOINED
                , p.YEAR_OF_BIRTH
  ; temp NUMBER := 0
  ;
-------------------------------------
BEGIN
  open t;
    FETCH t into temp;
  -- - - - - - - - - - - - --
    RETURN temp;
  -- - - - - - - - - - - - --
  close t;
END;
/ 
--———————————————————————————————————————————————————————————————————————————--