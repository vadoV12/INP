; Autor reseni: andrej vadovsky xvadova00

; Projekt 2 - INP 2025
; Souhlaskove modulovana samohlaskova sifra na architekture MIPS64

; DATA SEGMENT
                .data
msg:            .asciiz "andrejvadovsky" 
cipher:         .space  31 ; misto pro zapis zasifrovaneho textu
vowels: .asciiz "aeiouy"
; zde si muzete nadefinovat vlastni promenne ci konstanty,
; napr. hodnoty posuvu pro jednotlive znaky sifrovacho klice

params_sys5:    .space  8 ; misto pro ulozeni adresy pocatku
                          ; retezce pro vypis pomoci syscall 5
                          ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

main:           ; ZDE NAHRADTE KOD VASIM RESENIM
                daddi      r1,r0,msg        ;vstupny retazec
                daddi      r2,r0,vowels     ;samohlasky
                daddi      r4,r0,6          ;pocet samohlasok
                daddi      r10,r0,122       ;'z'
                daddi      r15,r0,cipher    ;adresa vystupneho retazca
                lb         r5,0(r1)         ;msg
                lb         r6,0(r2)         ;vowels
pokracovanie1:
                addi       r4,r4,-1         ;dekremantacia pocitadla samohlasok
                beq        r5,r6,vypocet1   ;ak je znak samohlaska skoc na vypocet1
                daddi      r2,r2,1          ;pokracujeme v retazci samohlasok
                lb         r6,0(r2)         ;nacitame dalsiu samohlasku
                bne        r0,r4,pokracovanie1      ;opakuj kym su samohlasky
                lb         r16,0(r1)      ;uloz znak zo vstupneho retazca
                sb         r5,0(r15)      ;uloz do cipher
                daddi      r15,r15,1      ;posunut index cipher
                B          start2         ;skoc na start2
pridavok:                   ; pokial sme presli 'z'
                addi       r5,r5,-26    ;odcitame 26 teda pocet prvkov v abecede
                sb         r5,0(r15)
                daddi      r15,r15,1 
                B          start2
vypocet1:                   ;vypocet ked je prvy znak samohlaska, nic sa nezmeni
                addi       r5,r5,26
                slt        r9,r10,r5
                bne        r9,r0,pridavok
                sb         r5,0(r15)
                daddi      r15, r15, 1 
                B          start2
vypocet2:
                beq        r16,r0,vypocet1  ;pokial neni spoluhlaska nic sa nezmeni
                addu       r17,r17,r16      ;Ascii hodnota spoluhlasky
                addi       r17,r17,-96      ;Odcitame od ascii hodnoty hodnotu 'a'
                addu       r5,r5,r17        ;pricitame k samohlaske
                slt        r9,r10,r5
                bne        r9,r0,pridavok    ;ak sme presli 'z'
                sb         r5,0(r15)        ;zapisujeme
                daddi      r15, r15, 1      ;posuvame

start2:         ;spracovanie dalsieho znaku
                daddi      r1,r1,1
                daddi      r17,r0,0
                daddi      r2,r0,vowels
                daddi      r4,r0,6
                lb         r5,0(r1)         ;msg
                lb         r6,0(r2)         ;vowels
pokracovanie2:      ;deje sa to iste co v pokracovanie1
                addi       r4,r4,-1
                beq        r5,r6,vypocet2
                daddi      r2,r2,1
                lb         r6,0(r2)
                bne        r0,r4,pokracovanie2
                lb         r16,0(r1)
                sb         r5,0(r15)            
                daddi      r15,r15,1
                bne        r5,r0,start2

                sb      r0, 0(r15)     ;nulovy znak na konec
                daddi   r4, r0, cipher ; vozrovy vypis: adresa msg do r4
                jal     print_string ; vypis pomoci print_string - viz nize


; NASLEDUJICI KOD NEMODIFIKUJTE!

                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
