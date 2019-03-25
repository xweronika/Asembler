Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik

start:          mov ax,dane
                mov ds,ax
                mov ax,stosik
                mov ss,ax
                mov sp,offset szczyt
				;________________________________________________________________________________________________________________________
napiszPustyZnak:
                mov ax, 0b800h ;Początek bloku na pamięć (początek strony)
                mov es, ax ;rejestr segmentowy es - segemnt dodatkowy, wkładamy do es ax
                mov di, 0 ;di czyli rejestr indeksowy, ustawienie kursora na początku dla rejestru ax (0b800h)
                mov al, ' ' ; ax sklada sie z al i ah (do czyszczenia)
                mov ah, 07d ;biała litera na czarnym tle - modyfikacja wyglądu znaku (w tym przypadku do tego pustego znaku)
				mov cx, 2000 ;granica ekranu, wskazuje ile razy pętla czyszcząca ma sie wykonać 
czysc:		
				mov es:[di], ax   ;chcemy modyfikować wartość a nie wskaźnik, di wskazuje na pozycje kursora
				inc di 
				inc di ;zwiekszamy di, czyli przesuwamy sie dalej o 1 znak w kazdej pętli czyszcząc ekran w tym znaku (ax=al, hl)
				loop czysc
				mov ax, 0b800h ;ustawienie kursora na początku 
				mov di, 0 ;ustawienie kursora na początku
powtarzajWPionie:
				mov cx, [ilePrzesun] ;Wartość ilePrzesun a nie ilePrzesun, cx licznik, np dla a: ileprzesun - a - iledokońca, pętla tyle razy ile ileprzesun 
przesun:    
				inc di 
				inc di; przesuwamy kursor o 2 bajty czyli o 1 znak
				loop przesun
				mov cx, [ileWypisac] ; ile razy pętla wypisz ma sie wykonac, w tym miejscu np. dla a jestemy na 40 miejscu
wypisz:
				mov al, [jakaLiterka] ;litera od a
				mov ah, 07d ;biała litera na czarnym tle
				mov es:[di], ax ;ustawienie pozycji kursora
				inc di ;literay na 2 bajtach
				inc di
				loop wypisz
				add [ileWypisac], 2 ;add - dodaj, zwiekszamy o 2 bo dla kazdej litery kolejna o 2 sie zwieksza np a -> bbb
				mov bx, [ileDoKonca] ;wpisujemy do drugiego rejestruile dokonca
				shl bx, 1 ;przesuniecie w lewo, mnozenie razy 2 iledokonca, żeby przejść do kolejnej linii, iledokonca to ilosc znakow, która została do końca linii 
				add di, bx	;przechodzimy kursorem do tego miejsca, które jest w bx	
				sub [ilePrzesun], 1 ;odejmij 
				sub [ileDoKonca], 1
				sub [ileRazy], 1 ; licznik petli
				mov cx, [ileRazy] ; ile razy wieszy ma wypisac, czyli ile razy pętla napiszpustyznak ma sie wykonać, 
				inc [jakaLiterka] ; zmiana litery na kolejną
				loop powtarzajWPionie
				
				;Przerwanie kończące program
				mov  ah, 4ch
                mov  al, 0
                int  21h ;przerwanie
Progr           ends

dane            segment
	 ilePrzesun dw 39
	 ileDoKonca dw 40
	 ileWypisac dw 1
	    ileRazy dw 25   ;dw jest 16 bitowe
	jakaLiterka db 'a' ;db jest 8 bitowe
	;___________________________________________________________________________________________________________________________________________
	
dane            ends

stosik          segment
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start