000100 IDENTIFICATION DIVISION.
000200
000300 PROGRAM-ID. FCRFAN1.
000400
000500*TITLE.      ANNUITY AN FUNDS CONFIGURATION UTILITY
000600
000700 AUTHOR.     CSC FINANCIAL SERVICES GROUP.
000800
000900 SECURITY.   THIS PROGRAM IS THE PROPERTY OF CSC FINANCIAL
001000             SERVICES GROUP. IT MAY NOT BE COPIED IN WHOLE OR IN
001100             PART WITHOUT THE EXPRESS WRITTEN CONSENT OF
001200             CSC FINANCIAL SERVICES GROUP.
001300
001400 DATE-WRITTEN.  MARCH, 2009.
001500
001600 DATE-COMPILED.
001700     EJECT
001800*REMARKS.
001900*=================================================================
002000*                  MODULE   MODIFICATIONS                        *
002100*=================================================================
002200* ENH #        ID     DATE     DESCRIPTION                       *
002300*-------- -------- -------- ------------------------------------ *
002400* T-0090  Z001801  03/2009  FUND CONFIGURATION FLEXIBILITY       *
002410* T-0138  Z001801  03/2010  FUNDS CONFIG CONVERSION CLEAN UP     *
002500*                                                                *
002600*=================================================================
002700*                                                                *
002800*  MODULE NARRATIVE                                              *
002900*   THIS IS PART OF THE WMA / V1 FUNDS CONFIGURATION UTILITY     *
003000*    PROCESS.  IT IS TO BE USED TO CONFIGURE / RECONFIGURE THE   *
003100*    NUMBER OF FUNDS FOR THE ANNUITY ANNUAL STATEMNT TRANSACTION.*
003200*                                                                *
003300*   THE ONLY DIFFERENCE BETWEEN THE OLD AND NEW VERSION OF THE   *
003400*    THE RECORDS BEING CONFIGURED MUST BE THE NUMBER OF          *
003500*    OCCURRENCES CONTAINED IN THE FUND ARRAYS IN THE             *
003600*    ANNUAL STATEMENT COPYBOOK - CIUAFAN1.                       *
003700*    ALL OTHER ASPECTS OF THE TWO TRANSACTIONS MUST BE THE SAME. *
003800*                                                                *
003900*   THE FIRST TIME INTO THE MODULE THERE IS A SET UP TO CALCULATE*
004000*    THE VARIOUS LENGTHS AND DISPLACEMENTS COMMON TO ALL OF THE  *
004100*    TRANSACTIONS THIS MODULE WILL 'CONVERT' OR CONFIGURE.  THE  *
004200*    CALCULATED VALUES WILL BE USED TO DO GENERIC MOVES OF BLOCKS*
004300*    OF DATA FROM THE OLD TRANSACTION FORMAT TO THE NEW ONE.     *
004400*    ONCE CALCULATED AND SAVED THERE IS NO NEED TO REDO THEM.    *
004500*                                                                *
004600*   FOR EACH ENTRY INTO THIS MODULE THE NEW TRANSACTION RECORD   *
004700*    WILL PROCESS THE FOLLOWING AREAS FROM THE OLD TRANSACTION   *
004800*    (NOTE THE HEADER DATA HAS ALREADY BEEN MOVED BY THE CONTROL *
004900*     PROCESS):                                                  *
005000*    1. LENGTH OF THE NEW COPYBOOK IS SET                        *
005100*    2. THE FIXED AREAS OF THE TRANSACTION                       *
005200*    3. ANY FUND ARRAY(S)                                        *
005300******************************************************************
005400     EJECT
005500 ENVIRONMENT DIVISION.
005600
005700 DATA DIVISION.
005800
005900 WORKING-STORAGE SECTION.
006000
006100 01  FILLER                            PIC X(48)  VALUE
006200     'XXXXX FCRFAN1 WORKING STORAGE STARTS HERE XXXXX'.
006300
006400 01  CONSTANTS.
006500     05  WS-FCRXDSP                  PIC X(8) VALUE 'FCRXDSP '.
006600     05  DISPLACEMENT-CONSTANT       PIC S9(8) COMP VALUE +1.
006700
006800 01  WORK-AREAS.
006900     05  FIRST-TIME-THRU-SW          PIC X     VALUE 'Y'.
007000         88  FIRST-TIME-THRU                   VALUE 'Y'.
007010     05  CONVERSION-REQUIRED-SW      PIC X     VALUE 'Y'.
007020         88  CONVERSION-NOT-REQUIRED           VALUE 'N'.
007100     05  FUND-AREA-CHANGE-DIRECTION  PIC X     VALUE 'U'.
007200         88  FUND-AREA-INCREASING              VALUE 'U'.
007300         88  FUND-AREA-DECREASING              VALUE 'D'.
007400
007500 01  LENGTHS-AND-DISPLACEMENTS.
007600     05  NEW-RDW-LENGTH              PIC S9(8) COMP.
007700     05  LENGTH-FIXED-1              PIC S9(8) COMP.
007800     05  LENGTH-FIXED-2B             PIC S9(8) COMP.
007900     05  LENGTH-FIXED-3E             PIC S9(8) COMP.
008000     05  DISP-TO-FIXED-1             PIC S9(8) COMP.
008100     05  INPUT-DISPLACEMENTS.
008200         10  IN-DISP-TO-FIXED-2B-1   PIC S9(8) COMP.
008300         10  IN-DISP-TO-FIXED-2B-2   PIC S9(8) COMP.
008400         10  IN-DISP-TO-FIXED-3E-1   PIC S9(8) COMP.
008500         10  IN-DISP-TO-FIXED-3E-2   PIC S9(8) COMP.
008600     05  OUTPUT-DISPLACEMENTS.
008700         10  OUT-DISP-TO-FIXED-2B-1  PIC S9(8) COMP.
008800         10  OUT-DISP-TO-FIXED-2B-2  PIC S9(8) COMP.
008900         10  OUT-DISP-TO-FIXED-3E-1  PIC S9(8) COMP.
009000         10  OUT-DISP-TO-FIXED-3E-2  PIC S9(8) COMP.
009100     05  OLD-ARRAY-LENGTHS.
009200         10  OLD-B-FUND-ARRAY-LENGTH PIC S9(8) COMP.
009300         10  OLD-E-FUND-ARRAY-LENGTH PIC S9(8) COMP.
009400     05  NEW-ARRAY-LENGTHS.
009500         10  NEW-B-FUND-ARRAY-LENGTH PIC S9(8) COMP.
009600         10  NEW-E-FUND-ARRAY-LENGTH PIC S9(8) COMP.
009700
009800**************************************************************
009900*                  C O P Y B O O K S                         *
010000**************************************************************
010100
010200 01  OLD-FUND-CONSTANTS.              COPY CFUAXMCD SUPPRESS.
010300
010400 01  NEW-FUND-CONSTANTS.              COPY CIUAXMCD SUPPRESS.
010500
010600 01  INIT-LENGTHS.                    COPY CVCSINIT SUPPRESS.
010700
010800 01  RELEASE-IDENTIFIER.
010900     05  WV0910-ID                   PIC X(6)  VALUE 'WV0910'.
010910     05  WV1001-ID                   PIC X(6)  VALUE 'WV1001'.
011000
011100 01  FILLER                          PIC X(48)  VALUE
011200     'XXXX FCRFAN1 WORKING STORAGE ENDS HERE XXXX'.
011300
011400     EJECT
011500**************************************************************
011600*             L I N K A G E    S E C T I O N                 *
011700**************************************************************
011800
011900 LINKAGE SECTION.
012000
012100 01  OLD-AN-TRX-REC.                 COPY CFUAFAN1 SUPPRESS.
012200
012300 01  NEW-AN-TRX-REC.                 COPY CIUAFAN1 SUPPRESS.
012400
012500 01  FUNDS-CONFIG-COMM-AREA.         COPY CFCRXCT1 SUPPRESS.
012600
012700 01  HEADER-LENGTH                   PIC S9(8) COMP.
012800     EJECT
012900 PROCEDURE DIVISION   USING   OLD-AN-TRX-REC
013000                              NEW-AN-TRX-REC
013100                              FUNDS-CONFIG-COMM-AREA
013200                              HEADER-LENGTH.
013300
013400 000000-MAINLINE.
013500
013600
013700     IF FIRST-TIME-THRU              IN WORK-AREAS
013800         PERFORM 100000-INITIALIZATION THRU 100000-EXIT.
013900
013910     IF CONVERSION-NOT-REQUIRED      IN WORK-AREAS
013920         SET NOT-CONVERTED           IN FUNDS-CONFIG-COMM-AREA
013930           TO TRUE
013940         GO TO 000000-EXIT
013950     END-IF.
013960
014000     PERFORM 200000-REFORMAT-AN-TRX    THRU 200000-EXIT.
014100
014200     PERFORM 300000-TERMINATION        THRU 300000-EXIT.
014300
014400
014500 000000-EXIT.
014600     GOBACK.
014700
014800
014900 100000-INITIALIZATION.
015000
015100     MOVE SPACES
015200       TO FIRST-TIME-THRU-SW         IN WORK-AREAS.
015300
015400     MOVE LENGTH OF NEW-AN-TRX-REC
015500       TO NEW-RDW-LENGTH             IN LENGTHS-AND-DISPLACEMENTS.
015600
015700     IF ANN-POLICY-MAX-FUNDS         IN NEW-FUND-CONSTANTS
015800       GREATER THAN
015900        ANN-POLICY-MAX-FUNDS         IN OLD-FUND-CONSTANTS
016000         SET FUND-AREA-INCREASING    IN WORK-AREAS
016100           TO TRUE
016200     ELSE
016300         SET FUND-AREA-DECREASING    IN WORK-AREAS
016400           TO TRUE
016500     END-IF.
016600
016700* LENGTH OF TRX INFO UP TO THE BALANCE AREA
016800     CALL WS-FCRXDSP   USING   TRX-INFO
016900                                     IN OLD-AN-TRX-REC
017000                               STATEMENT-SUMMARY-BALANCES
017100                                     IN OLD-AN-TRX-REC
017200                               LENGTH-FIXED-1.
017300
017400* LENGTH OF FIXED AREA IN THE BEGIN BALANCE AREA
017500     CALL WS-FCRXDSP   USING   BEGIN-BALANCES
017600                                     IN OLD-AN-TRX-REC (1)
017700                               FUND-INFO-ARRAY
017800                                     IN BEGIN-BALANCES
017900                                     IN OLD-AN-TRX-REC (1)
018000                               LENGTH-FIXED-2B.
018100
018200* LENGTH OF FIXED AREA IN THE END BALANCE AREA
018300     CALL WS-FCRXDSP   USING   END-BALANCES
018400                                     IN OLD-AN-TRX-REC (1)
018500                               FUND-INFO-ARRAY
018600                                     IN END-BALANCES
018700                                     IN OLD-AN-TRX-REC (1)
018800                               LENGTH-FIXED-3E.
018900
019000* LENGTH OF ARRAY IN THE BEGIN BALANCE AREA OF THE OLD TRX
019100     MOVE LENGTH OF FUND-INFO-ARRAY  IN BEGIN-BALANCES
019200                                     IN OLD-AN-TRX-REC (1)
019300       TO OLD-B-FUND-ARRAY-LENGTH    IN LENGTHS-AND-DISPLACEMENTS.
019400
019500* LENGTH OF ARRAY IN THE BEGIN BALANCE AREA OF THE NEW TRX
019600     MOVE LENGTH OF FUND-INFO-ARRAY  IN BEGIN-BALANCES
019700                                     IN NEW-AN-TRX-REC (1)
019800       TO NEW-B-FUND-ARRAY-LENGTH    IN LENGTHS-AND-DISPLACEMENTS.
019900
020000* LENGTH OF ARRAY IN THE END BALANCE AREA OF THE OLD TRX
020100     MOVE LENGTH OF FUND-INFO-ARRAY  IN END-BALANCES
020200                                     IN OLD-AN-TRX-REC (1)
020300       TO OLD-E-FUND-ARRAY-LENGTH    IN LENGTHS-AND-DISPLACEMENTS.
020400
020500* LENGTH OF ARRAY IN THE END BALANCE AREA OF THE NEW TRX
020600     MOVE LENGTH OF FUND-INFO-ARRAY  IN END-BALANCES
020700                                     IN NEW-AN-TRX-REC (1)
020800       TO NEW-E-FUND-ARRAY-LENGTH    IN LENGTHS-AND-DISPLACEMENTS.
020900
021000* DISPLACEMENT TO TRX-INFO
021100     MOVE HEADER-LENGTH
021200       TO DISP-TO-FIXED-1            IN LENGTHS-AND-DISPLACEMENTS.
021300     ADD DISPLACEMENT-CONSTANT       IN CONSTANTS
021400       TO DISP-TO-FIXED-1            IN LENGTHS-AND-DISPLACEMENTS.
021500
021600* DISPLACEMENT TO FIRST OCCURS OF FIXED DATA IN BEGIN BALANCES
021700     MOVE DISP-TO-FIXED-1            IN LENGTHS-AND-DISPLACEMENTS
021800       TO IN-DISP-TO-FIXED-2B-1      IN LENGTHS-AND-DISPLACEMENTS
021900          OUT-DISP-TO-FIXED-2B-1     IN LENGTHS-AND-DISPLACEMENTS.
022000     ADD LENGTH-FIXED-1              IN LENGTHS-AND-DISPLACEMENTS
022100       TO IN-DISP-TO-FIXED-2B-1      IN LENGTHS-AND-DISPLACEMENTS
022200          OUT-DISP-TO-FIXED-2B-1     IN LENGTHS-AND-DISPLACEMENTS.
022300
022400* DISPLACEMENT TO SECOND OCCURS OF FIXED DATA IN BEGIN BALANCES
022500     MOVE IN-DISP-TO-FIXED-2B-1      IN LENGTHS-AND-DISPLACEMENTS
022600       TO IN-DISP-TO-FIXED-2B-2      IN LENGTHS-AND-DISPLACEMENTS.
022700     MOVE OUT-DISP-TO-FIXED-2B-1     IN LENGTHS-AND-DISPLACEMENTS
022800       TO OUT-DISP-TO-FIXED-2B-2     IN LENGTHS-AND-DISPLACEMENTS.
022900
023000     ADD LENGTH-FIXED-2B             IN LENGTHS-AND-DISPLACEMENTS
023100       TO IN-DISP-TO-FIXED-2B-2      IN LENGTHS-AND-DISPLACEMENTS
023200          OUT-DISP-TO-FIXED-2B-2     IN LENGTHS-AND-DISPLACEMENTS.
023300
023400     ADD OLD-B-FUND-ARRAY-LENGTH     IN LENGTHS-AND-DISPLACEMENTS
023500       TO IN-DISP-TO-FIXED-2B-2      IN LENGTHS-AND-DISPLACEMENTS.
023600     ADD NEW-B-FUND-ARRAY-LENGTH     IN LENGTHS-AND-DISPLACEMENTS
023700       TO OUT-DISP-TO-FIXED-2B-2     IN LENGTHS-AND-DISPLACEMENTS.
023800
023900* DISPLACEMENT TO FIRST OCCURS OF FIXED DATA IN END BALANCES
024000     MOVE IN-DISP-TO-FIXED-2B-2      IN LENGTHS-AND-DISPLACEMENTS
024100       TO IN-DISP-TO-FIXED-3E-1      IN LENGTHS-AND-DISPLACEMENTS.
024200     MOVE OUT-DISP-TO-FIXED-2B-2     IN LENGTHS-AND-DISPLACEMENTS
024300       TO OUT-DISP-TO-FIXED-3E-1     IN LENGTHS-AND-DISPLACEMENTS.
024400
024500     ADD LENGTH-FIXED-2B             IN LENGTHS-AND-DISPLACEMENTS
024600       TO IN-DISP-TO-FIXED-3E-1      IN LENGTHS-AND-DISPLACEMENTS
024700          OUT-DISP-TO-FIXED-3E-1     IN LENGTHS-AND-DISPLACEMENTS.
024800
024900     ADD OLD-B-FUND-ARRAY-LENGTH     IN LENGTHS-AND-DISPLACEMENTS
025000       TO IN-DISP-TO-FIXED-3E-1      IN LENGTHS-AND-DISPLACEMENTS.
025100     ADD NEW-B-FUND-ARRAY-LENGTH     IN LENGTHS-AND-DISPLACEMENTS
025200       TO OUT-DISP-TO-FIXED-3E-1     IN LENGTHS-AND-DISPLACEMENTS.
025300
025400* DISPLACEMENT TO SECOND OCCURS OF FIXED DATA IN END BALANCES
025500     MOVE IN-DISP-TO-FIXED-3E-1      IN LENGTHS-AND-DISPLACEMENTS
025600       TO IN-DISP-TO-FIXED-3E-2      IN LENGTHS-AND-DISPLACEMENTS.
025700     MOVE OUT-DISP-TO-FIXED-3E-1     IN LENGTHS-AND-DISPLACEMENTS
025800       TO OUT-DISP-TO-FIXED-3E-2     IN LENGTHS-AND-DISPLACEMENTS.
025900
026000     ADD LENGTH-FIXED-3E             IN LENGTHS-AND-DISPLACEMENTS
026100       TO IN-DISP-TO-FIXED-3E-2      IN LENGTHS-AND-DISPLACEMENTS
026200          OUT-DISP-TO-FIXED-3E-2     IN LENGTHS-AND-DISPLACEMENTS.
026300
026400     ADD OLD-E-FUND-ARRAY-LENGTH     IN LENGTHS-AND-DISPLACEMENTS
026500       TO IN-DISP-TO-FIXED-3E-2      IN LENGTHS-AND-DISPLACEMENTS.
026600     ADD NEW-E-FUND-ARRAY-LENGTH     IN LENGTHS-AND-DISPLACEMENTS
026700       TO OUT-DISP-TO-FIXED-3E-2     IN LENGTHS-AND-DISPLACEMENTS.
026800
026810     IF    OLD-B-FUND-ARRAY-LENGTH   IN LENGTHS-AND-DISPLACEMENTS
026820     EQUAL NEW-B-FUND-ARRAY-LENGTH   IN LENGTHS-AND-DISPLACEMENTS
026830     AND   OLD-E-FUND-ARRAY-LENGTH   IN LENGTHS-AND-DISPLACEMENTS
026840     EQUAL NEW-E-FUND-ARRAY-LENGTH   IN LENGTHS-AND-DISPLACEMENTS
026850         SET CONVERSION-NOT-REQUIRED IN WORK-AREAS TO TRUE
026860     END-IF.
026870
026900 100000-EXIT.
027000     EXIT.
027100
027200 200000-REFORMAT-AN-TRX.
027300
027400     MOVE NEW-RDW-LENGTH             IN LENGTHS-AND-DISPLACEMENTS
027500       TO RDW-LENGTH                 IN NEW-AN-TRX-REC.
027600
027700     MOVE OLD-AN-TRX-REC (DISP-TO-FIXED-1 : LENGTH-FIXED-1)
027800       TO NEW-AN-TRX-REC (DISP-TO-FIXED-1 : LENGTH-FIXED-1).
027900     MOVE OLD-AN-TRX-REC (IN-DISP-TO-FIXED-2B-1
028000                          : LENGTH-FIXED-2B)
028100       TO NEW-AN-TRX-REC (OUT-DISP-TO-FIXED-2B-1
028200                          : LENGTH-FIXED-2B).
028300
028400     PERFORM 210000-PROCESS-BEGIN-FUNDS-1
028500        THRU 210000-EXIT.
028600
028700     MOVE OLD-AN-TRX-REC (IN-DISP-TO-FIXED-2B-2
028800                          : LENGTH-FIXED-2B)
028900       TO NEW-AN-TRX-REC (OUT-DISP-TO-FIXED-2B-2
029000                          : LENGTH-FIXED-2B).
029100
029200     PERFORM 220000-PROCESS-BEGIN-FUNDS-2
029300        THRU 220000-EXIT.
029400
029500     MOVE OLD-AN-TRX-REC (IN-DISP-TO-FIXED-3E-1
029600                          : LENGTH-FIXED-3E)
029700       TO NEW-AN-TRX-REC (OUT-DISP-TO-FIXED-3E-1
029800                          : LENGTH-FIXED-3E).
029900
030000     PERFORM 230000-PROCESS-END-FUNDS-1
030100        THRU 230000-EXIT.
030200
030300     MOVE OLD-AN-TRX-REC (IN-DISP-TO-FIXED-3E-2
030400                          : LENGTH-FIXED-3E)
030500       TO NEW-AN-TRX-REC (OUT-DISP-TO-FIXED-3E-2
030600                          : LENGTH-FIXED-3E).
030700
030800     PERFORM 240000-PROCESS-END-FUNDS-4
030900        THRU 240000-EXIT.
031000
031100 200000-EXIT.
031200     EXIT.
031300
031400 210000-PROCESS-BEGIN-FUNDS-1.
031500
031600     IF FUND-AREA-DECREASING         IN WORK-AREAS
031700         MOVE FUND-INFO-ARRAY        IN BEGIN-BALANCES
031800                                     IN OLD-AN-TRX-REC (1)
031900                                    (1 : NEW-B-FUND-ARRAY-LENGTH)
032000           TO FUND-INFO-ARRAY        IN BEGIN-BALANCES
032100                                     IN NEW-AN-TRX-REC (1)
032200         PERFORM 212000-CHECK-MAX-FUNDS
032300            THRU 212000-EXIT
032400         GO TO 210000-EXIT
032500     END-IF.
032600
032700     MOVE FUND-INFO-ARRAY            IN BEGIN-BALANCES
032800                                     IN OLD-AN-TRX-REC (1)
032900                                    (1 : OLD-B-FUND-ARRAY-LENGTH)
033000       TO FUND-INFO-ARRAY            IN BEGIN-BALANCES
033100                                     IN NEW-AN-TRX-REC (1)
033200                                    (1 : OLD-B-FUND-ARRAY-LENGTH).
033300
033400     MOVE SPACES
033500       TO FUND-INFORMATION           IN BEGIN-BALANCES
033600                                     IN NEW-AN-TRX-REC
033700                                    (1 ANN-POLICY-MAX-FUNDS
033800                                     IN OLD-FUND-CONSTANTS + 1).
033900
034000     INITIALIZE FUND-INFORMATION     IN BEGIN-BALANCES
034100                                     IN NEW-AN-TRX-REC
034200                                    (1 ANN-POLICY-MAX-FUNDS
034300                                     IN OLD-FUND-CONSTANTS + 1)
034400         REPLACING NUMERIC DATA BY ZEROES.
034500
034600     MOVE FUND-NUMBER-DEFAULT        IN NEW-FUND-CONSTANTS
034700       TO FUND-NUMBER                IN BEGIN-BALANCES
034800                                     IN NEW-AN-TRX-REC
034900                                    (1 ANN-POLICY-MAX-FUNDS
035000                                     IN OLD-FUND-CONSTANTS + 1).
035100
035200     COMPUTE FIRST-START             IN INIT-LENGTHS
035300         =   OLD-B-FUND-ARRAY-LENGTH IN LENGTHS-AND-DISPLACEMENTS
035400         +   DISPLACEMENT-CONSTANT   IN CONSTANTS.
035500
035600     MOVE LENGTH OF FUND-INFORMATION IN BEGIN-BALANCES
035700                                     IN NEW-AN-TRX-REC (1 1)
035800       TO LENGTH-OF-MOVE             IN INIT-LENGTHS
035900          LENGTH-MOVED               IN INIT-LENGTHS.
036000     ADD  OLD-B-FUND-ARRAY-LENGTH    IN LENGTHS-AND-DISPLACEMENTS
036100       TO LENGTH-MOVED               IN INIT-LENGTHS.
036200     MOVE LENGTH OF FUND-INFO-ARRAY  IN BEGIN-BALANCES
036300                                     IN NEW-AN-TRX-REC (1)
036400       TO MAX-LENGTH                 IN INIT-LENGTHS.
036500
036600     PERFORM 211000-INITIALIZE-ARRAY   THRU 211000-EXIT
036700       UNTIL LENGTH-MOVED            IN INIT-LENGTHS
036800             NOT LESS THAN
036900             MAX-LENGTH              IN INIT-LENGTHS.
037000
037100 210000-EXIT.
037200     EXIT.
037300
037400
037500
037600 211000-INITIALIZE-ARRAY.
037700
037800     COPY PVCSINIT
037900         REPLACING ==COPY-DATA-AREA==
038000         BY ==FUND-INFO-ARRAY  IN BEGIN-BALANCES
038100                               IN NEW-AN-TRX-REC (1)==.
038200
038300 211000-EXIT.
038400     EXIT.
038500
038600 212000-CHECK-MAX-FUNDS.
038700
038800     IF ANN-POLICY-MAX-FUNDS         IN OLD-FUND-CONSTANTS
038900       EQUAL
039000        ANN-POLICY-MAX-FUNDS         IN NEW-FUND-CONSTANTS
039100         GO TO 212000-EXIT
039200     END-IF.
039300
039400     IF FUND-NUMBER                  IN BEGIN-BALANCES
039500                                     IN OLD-AN-TRX-REC
039600                                    (1 ANN-POLICY-MAX-FUNDS
039700                                     IN NEW-FUND-CONSTANTS + 1)
039800       NUMERIC
039900         IF FUND-NUMBER              IN BEGIN-BALANCES
040000                                     IN OLD-AN-TRX-REC
040100                                    (1 ANN-POLICY-MAX-FUNDS
040200                                     IN NEW-FUND-CONSTANTS + 1)
040300           NOT EQUAL FUND-NUMBER-DEFAULT
040400                                     IN NEW-FUND-CONSTANTS
040500             SET TOO-MANY-MAX-FUNDS  IN FUNDS-CONFIG-COMM-AREA
040600               TO TRUE
040700         END-IF
040800     END-IF.
040900
041000 212000-EXIT.
041100     EXIT.
041200
041300 220000-PROCESS-BEGIN-FUNDS-2.
041400
041500     IF FUND-AREA-DECREASING         IN WORK-AREAS
041600         MOVE FUND-INFO-ARRAY        IN BEGIN-BALANCES
041700                                     IN OLD-AN-TRX-REC (2)
041800                                    (1 : NEW-B-FUND-ARRAY-LENGTH)
041900           TO FUND-INFO-ARRAY        IN BEGIN-BALANCES
042000                                     IN NEW-AN-TRX-REC (2)
042100         PERFORM 222000-CHECK-MAX-FUNDS
042200            THRU 222000-EXIT
042300         GO TO 220000-EXIT
042400     END-IF.
042500
042600     MOVE FUND-INFO-ARRAY            IN BEGIN-BALANCES
042700                                     IN OLD-AN-TRX-REC (2)
042800                                    (1 : OLD-B-FUND-ARRAY-LENGTH)
042900       TO FUND-INFO-ARRAY            IN BEGIN-BALANCES
043000                                     IN NEW-AN-TRX-REC (2)
043100                                    (1 : OLD-B-FUND-ARRAY-LENGTH).
043200
043300     MOVE SPACES
043400       TO FUND-INFORMATION           IN BEGIN-BALANCES
043500                                     IN NEW-AN-TRX-REC
043600                                    (2 ANN-POLICY-MAX-FUNDS
043700                                     IN OLD-FUND-CONSTANTS + 1).
043800
043900     INITIALIZE FUND-INFORMATION     IN BEGIN-BALANCES
044000                                     IN NEW-AN-TRX-REC
044100                                    (2 ANN-POLICY-MAX-FUNDS
044200                                     IN OLD-FUND-CONSTANTS + 1)
044300         REPLACING NUMERIC DATA BY ZEROES.
044400
044500     MOVE FUND-NUMBER-DEFAULT        IN NEW-FUND-CONSTANTS
044600       TO FUND-NUMBER                IN BEGIN-BALANCES
044700                                     IN NEW-AN-TRX-REC
044800                                    (2 ANN-POLICY-MAX-FUNDS
044900                                     IN OLD-FUND-CONSTANTS + 1).
045000
045100     COMPUTE FIRST-START             IN INIT-LENGTHS
045200         =   OLD-B-FUND-ARRAY-LENGTH IN LENGTHS-AND-DISPLACEMENTS
045300         +   DISPLACEMENT-CONSTANT   IN CONSTANTS.
045400
045500     MOVE LENGTH OF FUND-INFORMATION IN BEGIN-BALANCES
045600                                     IN NEW-AN-TRX-REC (2 1)
045700       TO LENGTH-OF-MOVE             IN INIT-LENGTHS
045800          LENGTH-MOVED               IN INIT-LENGTHS.
045900     ADD  OLD-B-FUND-ARRAY-LENGTH    IN LENGTHS-AND-DISPLACEMENTS
046000       TO LENGTH-MOVED               IN INIT-LENGTHS.
046100     MOVE LENGTH OF FUND-INFO-ARRAY  IN BEGIN-BALANCES
046200                                     IN NEW-AN-TRX-REC (2)
046300       TO MAX-LENGTH                 IN INIT-LENGTHS.
046400
046500     PERFORM 221000-INITIALIZE-ARRAY   THRU 221000-EXIT
046600       UNTIL LENGTH-MOVED            IN INIT-LENGTHS
046700             NOT LESS THAN
046800             MAX-LENGTH              IN INIT-LENGTHS.
046900
047000 220000-EXIT.
047100     EXIT.
047200
047300
047400
047500 221000-INITIALIZE-ARRAY.
047600
047700     COPY PVCSINIT
047800         REPLACING ==COPY-DATA-AREA==
047900         BY ==FUND-INFO-ARRAY  IN BEGIN-BALANCES
048000                               IN NEW-AN-TRX-REC (2)==.
048100
048200 221000-EXIT.
048300     EXIT.
048400
048500 222000-CHECK-MAX-FUNDS.
048600
048700     IF ANN-POLICY-MAX-FUNDS         IN OLD-FUND-CONSTANTS
048800       EQUAL
048900        ANN-POLICY-MAX-FUNDS         IN NEW-FUND-CONSTANTS
049000         GO TO 222000-EXIT
049100     END-IF.
049200
049300     IF FUND-NUMBER                  IN BEGIN-BALANCES
049400                                     IN OLD-AN-TRX-REC
049500                                    (2 ANN-POLICY-MAX-FUNDS
049600                                     IN NEW-FUND-CONSTANTS + 1)
049700       NUMERIC
049800         IF FUND-NUMBER              IN BEGIN-BALANCES
049900                                     IN OLD-AN-TRX-REC
050000                                    (2 ANN-POLICY-MAX-FUNDS
050100                                     IN NEW-FUND-CONSTANTS + 1)
050200           NOT EQUAL FUND-NUMBER-DEFAULT
050300                                     IN NEW-FUND-CONSTANTS
050400             SET TOO-MANY-MAX-FUNDS  IN FUNDS-CONFIG-COMM-AREA
050500               TO TRUE
050600         END-IF
050700     END-IF.
050800
050900 222000-EXIT.
051000     EXIT.
051100
051200 230000-PROCESS-END-FUNDS-1.
051300
051400     IF FUND-AREA-DECREASING         IN WORK-AREAS
051500         MOVE FUND-INFO-ARRAY        IN END-BALANCES
051600                                     IN OLD-AN-TRX-REC (1)
051700                                    (1 : NEW-E-FUND-ARRAY-LENGTH)
051800           TO FUND-INFO-ARRAY        IN END-BALANCES
051900                                     IN NEW-AN-TRX-REC (1)
052000         PERFORM 232000-CHECK-MAX-FUNDS
052100            THRU 232000-EXIT
052200         GO TO 230000-EXIT
052300     END-IF.
052400
052500     MOVE FUND-INFO-ARRAY            IN END-BALANCES
052600                                     IN OLD-AN-TRX-REC (1)
052700                                    (1 : OLD-E-FUND-ARRAY-LENGTH)
052800       TO FUND-INFO-ARRAY            IN END-BALANCES
052900                                     IN NEW-AN-TRX-REC (1)
053000                                    (1 : OLD-E-FUND-ARRAY-LENGTH).
053100
053200     MOVE SPACES
053300       TO FUND-INFORMATION           IN END-BALANCES
053400                                     IN NEW-AN-TRX-REC
053500                                    (1 ANN-POLICY-MAX-FUNDS
053600                                     IN OLD-FUND-CONSTANTS + 1).
053700
053800     INITIALIZE FUND-INFORMATION     IN END-BALANCES
053900                                     IN NEW-AN-TRX-REC
054000                                    (1 ANN-POLICY-MAX-FUNDS
054100                                     IN OLD-FUND-CONSTANTS + 1)
054200         REPLACING NUMERIC DATA BY ZEROES.
054300
054400     MOVE FUND-NUMBER-DEFAULT        IN NEW-FUND-CONSTANTS
054500       TO FUND-NUMBER                IN END-BALANCES
054600                                     IN NEW-AN-TRX-REC
054700                                    (1 ANN-POLICY-MAX-FUNDS
054800                                     IN OLD-FUND-CONSTANTS + 1).
054900
055000     COMPUTE FIRST-START             IN INIT-LENGTHS
055100         =   OLD-E-FUND-ARRAY-LENGTH IN LENGTHS-AND-DISPLACEMENTS
055200         +   DISPLACEMENT-CONSTANT   IN CONSTANTS.
055300
055400     MOVE LENGTH OF FUND-INFORMATION IN END-BALANCES
055500                                     IN NEW-AN-TRX-REC (1 1)
055600       TO LENGTH-OF-MOVE             IN INIT-LENGTHS
055700          LENGTH-MOVED               IN INIT-LENGTHS.
055800     ADD  OLD-E-FUND-ARRAY-LENGTH    IN LENGTHS-AND-DISPLACEMENTS
055900       TO LENGTH-MOVED               IN INIT-LENGTHS.
056000     MOVE LENGTH OF FUND-INFO-ARRAY  IN END-BALANCES
056100                                     IN NEW-AN-TRX-REC (1)
056200       TO MAX-LENGTH                 IN INIT-LENGTHS.
056300
056400     PERFORM 231000-INITIALIZE-ARRAY   THRU 231000-EXIT
056500       UNTIL LENGTH-MOVED            IN INIT-LENGTHS
056600             NOT LESS THAN
056700             MAX-LENGTH              IN INIT-LENGTHS.
056800
056900 230000-EXIT.
057000     EXIT.
057100
057200
057300
057400 231000-INITIALIZE-ARRAY.
057500
057600     COPY PVCSINIT
057700         REPLACING ==COPY-DATA-AREA==
057800         BY ==FUND-INFO-ARRAY  IN END-BALANCES
057900                               IN NEW-AN-TRX-REC (1)==.
058000
058100 231000-EXIT.
058200     EXIT.
058300
058400 232000-CHECK-MAX-FUNDS.
058500
058600     IF ANN-POLICY-MAX-FUNDS         IN OLD-FUND-CONSTANTS
058700       EQUAL
058800        ANN-POLICY-MAX-FUNDS         IN NEW-FUND-CONSTANTS
058900         GO TO 232000-EXIT
059000     END-IF.
059100
059200     IF FUND-NUMBER                  IN END-BALANCES
059300                                     IN OLD-AN-TRX-REC
059400                                    (1 ANN-POLICY-MAX-FUNDS
059500                                     IN NEW-FUND-CONSTANTS + 1)
059600       NUMERIC
059700         IF FUND-NUMBER              IN END-BALANCES
059800                                     IN OLD-AN-TRX-REC
059900                                    (1 ANN-POLICY-MAX-FUNDS
060000                                     IN NEW-FUND-CONSTANTS + 1)
060100           NOT EQUAL FUND-NUMBER-DEFAULT
060200                                     IN NEW-FUND-CONSTANTS
060300             SET TOO-MANY-MAX-FUNDS  IN FUNDS-CONFIG-COMM-AREA
060400               TO TRUE
060500         END-IF
060600     END-IF.
060700
060800 232000-EXIT.
060900     EXIT.
061000
061100 240000-PROCESS-END-FUNDS-4.
061200
061300     IF FUND-AREA-DECREASING         IN WORK-AREAS
061400         MOVE FUND-INFO-ARRAY        IN END-BALANCES
061500                                     IN OLD-AN-TRX-REC (2)
061600                                    (1 : NEW-E-FUND-ARRAY-LENGTH)
061700           TO FUND-INFO-ARRAY        IN END-BALANCES
061800                                     IN NEW-AN-TRX-REC (2)
061900         PERFORM 242000-CHECK-MAX-FUNDS
062000            THRU 242000-EXIT
062100         GO TO 240000-EXIT
062200     END-IF.
062300
062400     MOVE FUND-INFO-ARRAY            IN END-BALANCES
062500                                     IN OLD-AN-TRX-REC (2)
062600                                    (1 : OLD-E-FUND-ARRAY-LENGTH)
062700       TO FUND-INFO-ARRAY            IN END-BALANCES
062800                                     IN NEW-AN-TRX-REC (2)
062900                                    (1 : OLD-E-FUND-ARRAY-LENGTH).
063000
063100     MOVE SPACES
063200       TO FUND-INFORMATION           IN END-BALANCES
063300                                     IN NEW-AN-TRX-REC
063400                                    (2 ANN-POLICY-MAX-FUNDS
063500                                     IN OLD-FUND-CONSTANTS + 1).
063600
063700     INITIALIZE FUND-INFORMATION     IN END-BALANCES
063800                                     IN NEW-AN-TRX-REC
063900                                    (2 ANN-POLICY-MAX-FUNDS
064000                                     IN OLD-FUND-CONSTANTS + 1)
064100         REPLACING NUMERIC DATA BY ZEROES.
064200
064300     MOVE FUND-NUMBER-DEFAULT        IN NEW-FUND-CONSTANTS
064400       TO FUND-NUMBER                IN END-BALANCES
064500                                     IN NEW-AN-TRX-REC
064600                                    (2 ANN-POLICY-MAX-FUNDS
064700                                     IN OLD-FUND-CONSTANTS + 1).
064800
064900     COMPUTE FIRST-START             IN INIT-LENGTHS
065000         =   OLD-E-FUND-ARRAY-LENGTH IN LENGTHS-AND-DISPLACEMENTS
065100         +   DISPLACEMENT-CONSTANT   IN CONSTANTS.
065200
065300     MOVE LENGTH OF FUND-INFORMATION IN END-BALANCES
065400                                     IN NEW-AN-TRX-REC (2 1)
065500       TO LENGTH-OF-MOVE             IN INIT-LENGTHS
065600          LENGTH-MOVED               IN INIT-LENGTHS.
065700     ADD  OLD-E-FUND-ARRAY-LENGTH    IN LENGTHS-AND-DISPLACEMENTS
065800       TO LENGTH-MOVED               IN INIT-LENGTHS.
065900     MOVE LENGTH OF FUND-INFO-ARRAY  IN END-BALANCES
066000                                     IN NEW-AN-TRX-REC (2)
066100       TO MAX-LENGTH                 IN INIT-LENGTHS.
066200
066300     PERFORM 241000-INITIALIZE-ARRAY   THRU 241000-EXIT
066400       UNTIL LENGTH-MOVED            IN INIT-LENGTHS
066500             NOT LESS THAN
066600             MAX-LENGTH              IN INIT-LENGTHS.
066700
066800 240000-EXIT.
066900     EXIT.
067000
067100
067200
067300 241000-INITIALIZE-ARRAY.
067400
067500     COPY PVCSINIT
067600         REPLACING ==COPY-DATA-AREA==
067700         BY ==FUND-INFO-ARRAY  IN END-BALANCES
067800                               IN NEW-AN-TRX-REC (2)==.
067900
068000 241000-EXIT.
068100     EXIT.
068200
068300 242000-CHECK-MAX-FUNDS.
068400
068500     IF ANN-POLICY-MAX-FUNDS         IN OLD-FUND-CONSTANTS
068600       EQUAL
068700        ANN-POLICY-MAX-FUNDS         IN NEW-FUND-CONSTANTS
068800         GO TO 242000-EXIT
068900     END-IF.
069000
069100     IF FUND-NUMBER                  IN END-BALANCES
069200                                     IN OLD-AN-TRX-REC
069300                                    (2 ANN-POLICY-MAX-FUNDS
069400                                     IN NEW-FUND-CONSTANTS + 1)
069500       NUMERIC
069600         IF FUND-NUMBER              IN END-BALANCES
069700                                     IN OLD-AN-TRX-REC
069800                                    (2 ANN-POLICY-MAX-FUNDS
069900                                     IN NEW-FUND-CONSTANTS + 1)
070000           NOT EQUAL FUND-NUMBER-DEFAULT
070100                                     IN NEW-FUND-CONSTANTS
070200             SET TOO-MANY-MAX-FUNDS  IN FUNDS-CONFIG-COMM-AREA
070300               TO TRUE
070400         END-IF
070500     END-IF.
070600
070700 242000-EXIT.
070800     EXIT.
070900
071000
071100 300000-TERMINATION.
071200
071300     ADD +1
071400       TO ANN-AN-CONV-CTR            IN FUNDS-CONFIG-COMM-AREA.
071500
071600 300000-EXIT.
071700     EXIT.
