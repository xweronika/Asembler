Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik
 
pobierz_baj		proc   ;funkcja, czyli proc - pobierz_baj
				mov     ah,3Fh ;Funkcja 3Fh - pobieranie z pliku oznaczonego identyfikatorem BX
				mov     cx,1 ;Ilość bajtów do pobrania
				ret   ;Powrót z podprogramu, czyli z pobierz_baj
				endp
 ;______________________________________________________________________________________________________________________________
start:    mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt
  ;______________________________________________________________________________________________________________________________             
                ;Nie ustalaliśmy ES - wskazuje więc na PSP (specjalny blok programu który przechowuje informacje na jego temat) zawiera też 
		;ile bajtów wpisało sie w command-line i zapamiętuje to, co się tam wpisało, czyli w naszym przypadku spacja+(nazwa).dat
                mov     cl,es:[80h] ;Pod adresem 80h w PSP przechowywana jest długość stringa z argumentami,czyli tego command-line
                dec     cl ;Dekrementujemy tą długość (bo argumenty zaczynają się od spacji), czyli to co wpisaliśmy do command-line usuwając spacje
                mov     si,offset nazwa ;Ustalamy wskaźnik SI na miejsce w pamięci w segmencie danych, wkładamy offset nazwy do si
                mov     di,82h ;Ustalamy wskaźnik DI na początek stringa z argumentami w PSP (pomijając wymienioną wcześniej spację),czyli wskaźnik będzie na pierwszej literze pliku z nutami
               
                ;Kopiowanie nazwy pliku z PSP do segmentu danych
pob_param_pliku:    mov     al,es:[di] ;Skopiuj z ES:DI do AL, es nie zostało określone i wskazuje na PSP, a w di mamy wskaźnik na piersze literze pliku z nutami, ed- segment extrra
                mov     ds:[si],al ;Skopiuj z AL do DS:SI, kopiujemy litera po literze do ds:[si]
                inc     si ;Inkrementuj SI - teraz wskazuje na kolejny bajt do którego ma być skopiowany znak
                inc     di ;Inkrementuj DI - teraz wskazuje na kolejny znak do skopiowania
                dec     cl ;Dekrementuj długość stringa, w tym stringu jest nazwa pliku z nutami, którą długosc skracamy
                jnz     pob_param_pliku ;Jeżeli ta długość jest różna od zera to jeszcze mamy znaki do skopiowania
               
                ;Otwarcie pliku
                mov     ax,3D00h ;Funkcja 3Dh - Otwieranie pliku, w naszym przypadku pliku z nutami
                mov     dx,offset nazwa ;W DX jest adres nazwy pliku z nutami
                int     21h ;przerwanie do funkcji
                jnc     dalej ;Jeżeli flaga carry (przepełnienie) jest ustawiona to jest błąd
                jmp blad 
dalej:          mov     bx,ax ;W AX zwracany jest identyfikator powiązany z plikiem - wrzucamy go do BX 
               ;czyszczenie ekranu:
		mov ah,00 
		mov al,03h ;funkcja do czyszczenia ekranu konsoli
                int 10h 

                lea dx,tekst1  ;lea wczytuje offset tekstu1 do dx, tekst1 = ...play music...
                mov ah,09h;Funkcja wypisująca na ekran napis o adresie zawartym w rejestrze DX
                int 21h;Wywołanie przerwania DOSa z funkcją 09H;
                ;Włączenie głośniczka
                in      al,61h ;Pobieramy wartość z portu 61
                or      al,00000011b ;2 pierwsze bity ustawiamy na 1 - resztę zostawiamy bez zmian
                out     61h,al ;Wrzucamy spowrotem tą wartość do tego portu
               
pobierz:        ;Pobieranie danych z pliku z nutami
				call pobierz_baj ;call - wywołaj funkcję pobierz_baj (na górze)
                mov     dx,offset nuta ;Adres do którego mają być wrzucone dane wkładamy do dx
                int     21h ; przerwanie do funkcji pobierz_baj, które ustawia parametry do przerwania
				;W tym miejscu zostaje pobrajny bajt, czyli jeden znak z zawartości pliku z nutami do dx, ponieważ w funkcji pobierz_baj ustaliliśmy jej parametry
                jc      wyjscie ;Jeżeli flaga carry jest ustawiona to jest błąd
                cmp     ax,cx ;W AX jest podane ile rzeczywiście bajtów zostało podanych - porównujemy czy pobrało tyle ile chcieliśmy, czy 1 i  idziemy dalej, 
				;czy 0 i kończymy, w funkcji pobierz_baj do cx daliśmy 1
                jnz     wyjscie ;Jeżeli nie to trafiliśmy na koniec pliku - wyjdź
				
				call pobierz_baj
                mov     dx,offset oktawa ;Adres do którego mają być wrzucone dane
                int     21h
                jc      wyjscie ;Jeżeli flaga carry jest ustawiona to jest błąd
                cmp     ax,cx ;W AX jest podane ile rzeczywiście bajtów zostało podanych - porównujemy czy pobrało tyle ile chcieliśmy
                jnz     wyjscie ;Jeżeli nie to trafiliśmy na koniec pliku - wyjdź
				
				call pobierz_baj
                mov     dx,offset dlugosc ;Adres do którego mają być wrzucone dane
                int     21h
                jc      wyjscie ;Jeżeli flaga carry jest ustawiona to jest błąd
                cmp     ax,cx ;W AX jest podane ile rzeczywiście bajtów zostało podanych - porównujemy czy pobrało tyle ile chcieliśmy
                jnz     wyjscie ;Jeżeli nie to trafiliśmy na koniec pliku - wyjdź
                
				;na enter
			        mov     ah,3Fh ;Funkcja 3Fh - pobieranie z pliku oznaczonego identyfikatorem BX
                mov     cx,2 ;Ilość bajtów do pobrania, bo enter ma 2 bajty
                mov     dx,offset enterr ;Adres do którego mają być wrzucone dane
                int     21h
                jc      wyjscie ;Jeżeli flaga carry jest ustawiona to jest błąd
                cmp     ax,cx ;W AX jest podane ile rzeczywiście bajtów zostało podanych - porównujemy czy pobrało tyle ile chcieliśmy
                jnz     wyjscie ;Jeżeli nie to trafiliśmy na koniec pliku - wyjdź
				
                ;Obliczenie tonu
                xor     ah,ah ;Zerujemy AH gdyż będzie nam potrzebny cały rejestr AX, używamy xor do zerowania
                mov     al,nuta ;Wrzucamy nutę do AL (nie mogliśmy bezpośrednio do AX bo nuta to bajt), tu nuta zawiera 1 cyfre
                sub     al,'0' ;Odejmujemy wartość ASCII - teraz mamy czystą wartość nuty, czyli w komputerze jest teraz cyfra, odejmujemy 1, bo chcemy przeżucić wartość z 1 na 0
                mov     si,ax ;Nutę wsadzamy do SI - będzie naszym wskaźnikiem
                shl     si,1 ;Mnożymy razy dwa (gdyż każda z nut jest dwubajtową wartością w segmencie danych), shl - przesuwa w lewo
                add     si,offset nuty ;Dodajemy adres pierwszej nuty by otrzymać wskaźnik na nutę która nas interesuje
                mov     ax,ds:[si] ;Pobieramy tą nutę z segmentu danych do AX, traktujemy to jak tablicę
                mov     cl,oktawa ;Do CL wrzucamy oktawę
                sub     cl,'0' ;Odejmujemy wartość ASCII - teraz mamy czystą wartość oktawy
                shr     ax,cl ;Przesuwamy w prawo o tą wartość (dzielimy przez 2 do potęgi oktawy)
                out     42h,al ;Wrzucamy część mniejszą rejestru AX do portu 42h, wgrywanie częstotliwość do głośnika z nuty
                mov     al,ah ;out nie może pobierać wartości z AH
                out     42h,al ;A następnie wrzucamy część większą rejestru AX do portu 42h
               
                ;Timer - w (CX DX) ilość mikrosekund które ma czekać
                push    bx ;Zapisujemy BX (identyfikator pliku), gdyż...
                xor     bx,bx ;...musimy go wyzerować (zbugowany timer)
                xor     dx,dx ;Zerujemy DX
                mov     cl,dlugosc ;Do CL dajemy bajt długości
                sub     cl,'0' ;Odejmujemy wartość ASCII - teraz mamy czystą wartość długości
                mov     ah,86h ;Funkcja 86h przerwania 15h - timer
                int     15h ;funkcja nie robi nic poza tym że trwa dokładnie tyle czasu ile jest podane w rejestrach cx, dx
                pop     bx ;Wczytujemy spowrotem BX, bo wczesniej daliśmy go na stos
               
                jmp     pobierz ;skok bezwarunkowy
               
               
wyjscie:        ;Wyłączenie głośniczka
                in      al,61h ;Pobieramy wartość do AL z portu 61h
                and     al,11111100b ;Zerujemy dwa pierwsze bity - resztę zostawiamy bez zmian
                out     61h,al ;Wrzucamy tą wartość spowrotem do tego portu
               
                mov     ah,3Eh ;Funkcja 3Eh przerwania 21h - zamknięcie pliku oznaczonego identyfikatorem BX, czyli pliku z nutami
                int     21h
                jmp koniec
				
blad:           mov ah,00
                mov al,03h	;czyszczenie ekranu (konsoli)
                int 10h
                lea dx,tekst2;Wpisanie adresu napisu do rejestru DX
			    mov ah,09h;Funkcja wypisująca na ekran napis o adresie zawartym w rejestrze DX
			    int 21h;Wywołanie przerwania DOSa z funkcją 09H

koniec:         mov     ax,4C00h ;Wyjście
                int     21h
Progr           ends
 
dane            segment
nuty        dw      (1193000/33) ;C     - 1
                dw      (1193000/37) ;D     - 2
                dw      (1193000/41) ;E     - 3
                dw      (1193000/44) ;F     - 4
                dw      (1193000/49) ;G     - 5
                dw      (1193000/55) ;A     - 6
                dw      (1193000/62) ;H     - 7

nuta            db      ?            ;pytajnik oznacza wartość nieustaloną (można skojarzyć np. ze stworzeniem zmiennej w C++ i nie przypisaniem do niej wartości)
oktawa          db      ?
dlugosc         db      ?
enterr          dw      ?            ;2 ostatnie bajty - zarezerwowane na enter (bajty 0Dh, 0Ah)
nazwa           db      80h dup(0)   ;Rezerwujemy pamięć na nazwę pliku (80h bajtów o wartości 0 - rezerwujemy zerami gdyż nazwa pliku musi się kończyć bajtem 0)
tekst1          db 14,' ',14,' ',14,' play music ',14,' ',14,' ',14,' ',1,10,13,'$'; liczby to nutki w ascii
tekst2          db 'Brak pliku$';
;______________________________________________________________________________________________________________________________
dane            ends
 
stosik          segment
                dw      100h dup(0)
szczyt          Label word
stosik          ends
 
end start
;______________________________________________________________________________________________________________________________
;Kazda nuta sklada sie z 3 cyfr zakonczonych enterem.
;Pierwszy znak to nuta, drugi to oktawa, trzeci to dlugosc trwania nuty
;Przykladowa nuta:
;244
;2 - druga nuta czyli D (liczona od 1 do 7)
;4 - czwarta oktawa	   (liczona od 1 - pierwszej oktawy)
;4 - dlugosc nuty       (zaczynajac od 1 wzwyz - kazdy kolejny stopien jest wiekszy o ok 65.5 ms)
;Pauzy mozna tworzyc poprzez uzycie odpowienio wysokiej oktawy (ja używałem oktawy p do swoich utworów) 
;- ponieważ oktawy tworzone są przez dzielenie nuty, bardzo wysokie oktawy po prostu wyzerują jej wartość, co umożliwia użycie pauzy przy włączonym głośniku.
;Mozna przerwe rowniez zrobic jako wartosc np:
;194 gdzie:
;1 nuta C (dowolnosc)
;9 odpowiednio wysoka oktawa
;4 dlugosc trwania przerwy
;Plik musi być zakończony enterem.

;długość nut:
;1 ~ 65.5 ms 	~ 0,06 sek			;6 ~ 393 ms 		~ 0,39 sek				
;2 ~ 131 ms 		~ 0,13 sek		;7 ~ 458,5 ms 	~ 0,45 sek			; ~ 720,5 ms	~ 0,72 sek			;? ~ 982,5 ms 	~ 0,98 sek
;3 ~ 196,5 ms 	~ 0,19 sek			;8 ~ 524 ms 		~ 0,52 sek		< ~ 786 ms 		~ 0,78 sek   		@ ~ 1048 ms 	~ 1,04 sek 
;4 ~ 262 ms 		~ 0,26 sek		9 ~ 589,5 ms 	~ 0,58 sek			= ~ 851,5 ms 	~ 0,85 sek
;5 ~ 327,5 ms 	~ 0,32 sek			: ~ 655 ms		~ 0,65 sek			> ~ 917 ms 		~ 0,91 sek