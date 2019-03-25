        assume cs:kod,ds:dane,ss:stosik
kod     segment

blad1: mov dx,offset blad_1  ;wk�adanie do dx offsetu blad1
	mov ah,09h ; funkcja do wy�wietlania, w ah musi by� funkcja, kt�r� wywo�ujemy przerwaniem ni�ej
	int 21h ;przerwanie do wy�wietlania
	jmp koniec
blad2: mov dx,offset blad_2
	mov ah,09h
	int 21h
	jmp koniec
blad3: mov dx,offset blad_3
	mov ah,09h
	int 21h
	jmp koniec
;________________________________________________________________________
start:  mov ax,dane
        mov ds,ax
        mov ax,stosik
        mov ss,ax
        mov sp,offset szczyt
;_______________________________________________________________________
	
	mov dx,offset poczatek	;dx - rejestr
	mov ah,09h ;funkcja do wy�wietlania, w ah musi by� funkcja, kt�r� wywo�ujemy przerwaniem ni�ej
	int 21h ; przerwanie do wy�wietlania - wyswietla prosbe o podanie liczby (funkcja 09h - wypis tekstu) - 'Prosze o podanie liczby : $'

	mov dx,offset max ; 1 bajt, oznacza �e mo�na wpisa� max 6 znak�w, a w�a�ciwie 5 znak�w i enter;
;pobranie naszej liczby z klawiatury:
	mov ah,0Ah	 ; funkcja do wczytywania z klawiatury
	int 21h	        ;funkcja 0Ah - odczytanie wiersza z klawiatury do AL

;sprawdzanie czy zostal podany znak, cmp por�wnuje, czy zawarto�� zmiennej ile jest r�wna 0, 
;je - je�li r�wna zero (flaga Z=1) skok do etykiety blad1 

	cmp ile,0h ;ile-nasza liczba, 0h - por�wnanie z zerem, ile zosta�o wpisane, to jest 2 bajt po maxie
	je blad1 ;je�li jest 0 to blad1 - nic nie zosta�o podane
        
	
	mov bx,0 ; zerujemy rejestr bx 
        mov ch,0 ; zerujemy ch
	mov cl,ile  ;zerujemy cl
	; ch i cl daja rejestr cx, kt�ry jest potrzebny do zaimplementowania p�tli loop, 
	; rejestr cx ma 2 bajty, a cl i ch maj� po 1 bajcie i zerujemy pierwszy bajt, a do drugiego wprowadzamy wartos� ile, a nie od razu do cx bo 'ile' jest 1 bajtowe     


        ;zamiana �ancucha znakow(pobranego z klawiatury) na liczbe
        mov bx,0 ; zerujemy bx

;p�tla - proba
proba:	mov ax,0 ; zerujemy rejestr aby wyczyscic go z ewentualnych pozostalosci po poprzednich opercjach
            
	mov al,tab[bx] ; do al przesylamy zaw. tablicy o indxie bx (zacznie od indexu 0, poniwewaz zerowalismy), bx s�u�y nam jako index w tablicy, al to po�owa ax
	sub al,'0' ; odejmujemy 0 od rejestru al, czyli od naszej liczby (tzn. od znak�w kt�re zosta�y pobrane z klawiatury)
	push ax ; zaw. rej. ax na stos, ax jest teraz cyfr�, jedn� kafelk� z naszej tablicy, dajemy na stos, �eby ta nasza cyfra sie nie zgubi�a
	cmp ax,10 ;sprawd� czy zawarto�� rej ax jest rowna dziesiec przez cmp - por�wnanie i jnc - je�li nie carry - przeniesienie zewn�trzne dla operacji arytmet.
	jnc blad2 ; skok 
	;gdy podamy znak i odejmiemy od niego '0', to zmieni sie on z kodu ascii na liczbe dziesi�tn�, a litery maja zawsze wieksza wartosc od 10, bo s� za cyframi
	;blad2 - Wpisane znaki nie sa liczba
	
	;tworzenie liczby z cyfr np. 2,3 -> 2*10=20, 20+3=23
	mov ax,suma ; przeniesienie do rej ax, zmiennej suma
	mov dx,10d ; do dx 10 w zapisie dziesiatkowym
	mul dx  ; mnozenie liczby w ax przez 10 bez uwzglednienia znaku, wynik przechowywany w ax
	mov suma,ax ; z rej ax
	jc blad3 ;jesli przeniesienie to blad3 - Wpisana liczba jest za duza - jesli wyjdzie przeniesienie to znaczy ze liczba jest za duza 

	pop ax    ; zdejmij ze stosu ax 
	add suma,ax ; dodaj bez uwzgledniania przeniesienia ax do suma
	jc blad3 ; skok jesli flaga CF = 1, czyli jesli wystapi przeniesienie, czyli tzw. nadwyzka, blad3 - Wpisana liczba jest za duza
	
	inc bx  ; dodaj 1 do bx, �eby przej�� do nast�pnego indeksu w tablicy, czyli do nast�pnej cyfry
	loop proba ; odejmuje od cx 1, jesli cx jest rozne od 0 dziala dalej, bo loop tak dzia�a


;wstawienie znaku $ na koncu tablicy
        mov bh,0  
        mov bl,ile    ; bh i bl daja razem rej bx, bx-16 bit�w = 2 bajty, bh, bl-8bit�w = 1 bajt, ile to miejsce po naszej ostatniej cyfrze,�eby bx wpisa� w to miejsce $
	mov tab[bx],'$' ; na koncu tablicy wstawia $, aby program wiedzial gdzie konczyc czytac
	;wstawia go po tej naszej liczbie, kt�r� uzyskali�my w p�tli wy�ej

	;koniec zamiany lancucha na liczbe

;dzies - wyswietlenie liczby
	mov dx,offset des  ;des - napis 'Liczba dziesietna: $'
        mov ah,09h ; funkcja do wy�wietlania, w ah musi by� funkcja, kt�r� wywo�ujemy przerwaniem ni�ej
        int 21h  ;przerwanie do wy�wietlania - wyswietla napis 'Liczba dziesietna: $' (funkcja 09h - wypis tekstu)

	mov dx,offset tab ; wyswietla liczbe dziesiatna, wy�wietla t� tablice czyli cyfra po cyfrze, kt�re wcze�niej wpisali�my		
	int 21h ;przerwanie do wy�wietlania

;bin
;bin - wyswietlenie napisu
	mov dx,offset bin ; bin - napis 'Binarna: $'
	mov ah,09h ;funkcja do wy�wietlania, w ah musi by� funkcja, kt�r� wywo�ujemy przerwaniem ni�ej
	int 21h	;przerwanie do wy�wietlania - wyswietla napis 'Binarna: $' (funkcja 09h - wypis tekstu)

;przygotowanie do p�tli
	mov cx,16  ; 16 do rej cx, cx-licznik p�tli, 16 razy ma sie wykonac bo suma jest 16 bitowa
	mov dx,suma ; przenies suma do dx
	rol dx,1 ; przesuniecie cykliczne bajlu lub slowa w lewo o 1, tutaj ju� t� liczbe przes�wamy, �eby pierwsza cyfra by�a na ko�cu
	push dx ; dx na stos, w dx jest suma


petla:	and dx,0000000000000001b ; logiczny iloczyn bajt lub slow (00, 01, 10 -0; 11-1) 
		;przesuniecie cykliczne naszej liczby w kodzie bin i porowannie z 1 na koncu
		
	add dx,'0'; dodaj do rej dx 0 [zamiana do kodu ascii],�eby wy�wietli�o cyfre a nie kod, w dx jest 0 lub 1 z por�wnania logicznego
        mov ah,02h ;wy�wietlanie znaku, funkcja do przerwania 21h
	int 21h	  ;wyswietla znak z dx
	pop dx   ; sciagniej dx ze stosu
	rol dx,1 ;  przesuniecie cykliczne batlu lub slowa w lewo o 1
	push dx ; dx na stos
	loop petla	;koniec p�tli

;hex
	mov dx,offset heksa ; wyswietla napis 'Heksadecymalna: $'
	mov ah,09h ;funkcja do wy�wietlania, w ah musi by� funkcja, kt�r� wywo�ujemy przerwaniem ni�ej
	int 21h	;przerwanie do wy�wietlania - wyswietla napis z heksa (funkcja 09h - wypis tekstu)

;przygotowanie do p�tli	 
	mov cx,4 ; 4 do cx, licznik petli, 4 razy bo w hex por�wnujemy 4 znaki systemu binarnego 
	mov bx,suma ; suma do bx
	rol bx,4 ; przesuniecie cykliczne batlu lub slowa w lewo o 4, tutaj ju� t� liczbe przes�wamy, �eby pierwsze 4 cyfry by�y na ko�cu
	push bx ; bx na stos
	
petla2:	and bx,0000000000001111b ; logiczny iloczyn bajt lub slow (00, 01, 10 -0; 11-1) 
;przesuniecie cykliczne naszej liczby w kodzie bin i porowannie 4 cyfr na koncu

        mov ah,02h 	
	mov dl,hex[bx] ; wyswietl ze zmiennej hex - '0123456789ABCDEF' znak o indexie bx, dlatego dl a nie dx bo dl 1 bajtowe, jak wyjdzie 0...11 to 3 czyli 3 znak w tablicy hex
	int 21h  ; wyswietla znak 
	pop bx  ; bx ze stosu
	rol bx,4 ; przesuniecie cykliczne batlu lub slowa w lewo o 4 
	push bx ; bx na stos
	loop petla2  ;koniec p�tli

	
        mov ah,01h ; czeka na znak z klawiatury, przed zamknieciem programu
        int 21h ;przerwanie programowe

koniec:	mov ah,4ch ;koniec - zamkniecie programu
	int 21h

kod     ends

dane    segment

max db 6 ;db-bajt
ile db ?
tab db 6 dup(0)	; dup - duplikowanie, czyli  6 zer stworzy, bo duplikuje
suma dw 0 ;dw - 2bajty
hex db '0123456789ABCDEF'

;Deklarowanie napis�w
poczatek db 13,10,'Prosze o podanie liczby : $'
des db 13,10,13,10,'Liczba dziesietna: $'
bin db 13,10,'Binarna: $'
heksa db 13,10,'Heksadecymalna: $'
blad_1 db 13,10,'Nic nie zostalo podane!$'
blad_2 db 13,10,'Wpisane znaki nie sa liczba!$'
blad_3 db 13,10,'Wpisana liczba jest za duza !$' ;Maksymalna liczba 16 bitowa, kt�r� mo�emy wpisa�: 65535, a minimalna to 0

;_______________________________________________________________________
dane    ends

stosik  segment
        
	dw 100h dup(?)
szczyt  dw 0

stosik  ends
        end start
