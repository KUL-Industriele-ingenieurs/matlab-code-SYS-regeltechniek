#import "school-template.typ": *

#show: project.with(
  title: "Take Home Exam 2026 — Notities",
  course: "Systeemtheorie en Regeltechniek",
  authors: ("Ruben Ryckaert",),
  academic_year: "2025-2026",
  short_title: true,
  show_disclaimer: false,
)

// ============================================================================
//                          QUESTION 1: FILTER ANALYSIS
// ============================================================================

= Vraag 1 — ECG Spiertrilling Filter
#chapter-outline()

== 1.1 Overzicht: Wat is het probleem?

Bij het meten van een ECG-signaal (hartsignaal) zijn de sensoren zeer gevoelig voor *spiertrillingen* (tremor). Deze trillingen zitten typisch in het frequentiegebied van $8$–$25 "Hz"$ ($approx 50$–$157 "rad/s"$). We willen deze frequenties *filteren* zodat artsen het werkelijke biosignaal kunnen zien.

#concept(title: "Filtertype")[
  Het filter uit de Bode plot (Figuur 1) is een combinatie van twee tweede-orde circuits:
  1. *Notch filter (bandstop)* — verwijdert de trilfrequentie
  2. *Laagdoorlaatfilter (low-pass)* — dempt hoogfrequente ruis

  Totaal: 4 polen, 2 nullen $arrow.r$ 2 excess polen $arrow.r$ $-40 "dB/decade"$ bij hoge frequentie en fase $arrow.r -180°$.
]

== 1.2 Transferfunctie uit de Bode Plot

#theorie(title: "Aflezen van de Bode plot")[
  Uit Figuur 1 lezen we af:
  - *Lage frequentie*: magnitude $approx 0 "dB"$ (versterking = 1)
  - *Notch*: extreem diepe dip ($arrow.r -350 "dB"$) bij $omega_n approx 100 "rad/s"$
  - *Na de notch*: magnitude herstelt naar $0 "dB"$
  - *Hoge frequentie*: afname met $-40 "dB/decade"$ (twee excess polen)
  - *Fase*: begint bij $0°$, eindigt bij $-180°$
]

#form(title: "Notch filter (bandstop)")[
  $ H_1(s) = frac(s^2 + omega_n^2, s^2 + 2 zeta_1 omega_n s + omega_n^2) $

  Met $omega_n = 100 "rad/s"$ en $zeta_1 = 0.05$ (smalle notch).

  De *nulpunten* liggen op de imaginaire as: $s = plus.minus j omega_n$ $arrow.r$ magnitude wordt exact $0$ ($-infinity "dB"$) bij $omega = omega_n$.

  De *polen* liggen net links van de imaginaire as (kleine demping) $arrow.r$ smalle notch.
]

#form(title: "Laagdoorlaatfilter (low-pass)")[
  $ H_2(s) = frac(omega_("lp")^2, s^2 + 2 zeta_2 omega_("lp") s + omega_("lp")^2) $

  Met $omega_("lp") = 1000 "rad/s"$ en $zeta_2 = 0.707$ (Butterworth — geen resonantiepiek).
]

#form(title: "Gecombineerde transferfunctie")[
  $ H(s) = H_1(s) dot H_2(s) = frac((s^2 + 10000) dot 10^6, (s^2 + 10s + 10000)(s^2 + 1414.2s + 10^6)) $

  DC-versterking: $H(0) = frac(10000, 10000) dot frac(10^6, 10^6) = 1 arrow.r 0 "dB"$ $checkmark$
]

== 1.3 Elektronisch Circuit

Het circuit bestaat uit twee gestage, gescheiden door een *buffer* (spanningsvolger) om belasting te voorkomen.

#theorie(title: "Stage 1: Notch Filter — Parallel LC tank + weerstand")[
  *Circuit:*
  ```
  V_in ---[ L₁ ‖ C₁ ]---+--- V_mid
                          |
                         [R₁]
                          |
                         GND
  ```

  De *parallel LC tank* heeft impedantie:
  $ Z_("tank") = frac(s L_1, s^2 L_1 C_1 + 1) $

  Bij resonantie ($omega = 1/sqrt(L_1 C_1)$) is $Z_("tank") arrow.r infinity$ $arrow.r$ signaal wordt geblokkeerd.
]

#theorie(title: "Stage 2: Low-Pass Filter — Serie RL + shunt C")[
  *Circuit:*
  ```
  V_mid ---[buffer]---[R₂]---[L₂]---+--- V_out
                                      |
                                     [C₂]
                                      |
                                     GND
  ```

  Bij hoge frequentie: $L_2$ blokkeert, $C_2$ laat door naar GND $arrow.r$ signaal wordt gedempt.
]

== 1.4 Kirchhoff Verificatie

#theorie(title: "Stage 1 — Kirchhoff")[
  Spanningsdeler met $Z_("tank")$ en $R_1$:

  $ H_1(s) = frac(R_1, Z_("tank") + R_1) = frac(s^2 + 1/(L_1 C_1), s^2 + s/(R_1 C_1) + 1/(L_1 C_1)) $

  Met $L_1 = 1 "H"$, $C_1 = 100 mu"F"$, $R_1 = 1000 Omega$:

  $ omega_n = 1/sqrt(L_1 C_1) = 1/sqrt(10^(-4)) = 100 "rad/s" $ $checkmark$
  $ zeta_1 = 1/(2 R_1 C_1 omega_n) = 1/(2 dot 1000 dot 10^(-4) dot 100) = 0.05 $ $checkmark$
]

#theorie(title: "Stage 2 — Kirchhoff")[
  Spanningsdeler: $V_("out")$ over $C_2$:

  $ H_2(s) = frac(1/(L_2 C_2), s^2 + s R_2/L_2 + 1/(L_2 C_2)) $

  Met $R_2 = 141.42 Omega$, $L_2 = 100 "mH"$, $C_2 = 10 mu"F"$:

  $ omega_("lp") = 1/sqrt(L_2 C_2) = 1/sqrt(10^(-6)) = 1000 "rad/s" $ $checkmark$
  $ zeta_2 = R_2/(2 L_2 omega_("lp")) = 141.42/(2 dot 0.1 dot 1000) = 0.707 $ $checkmark$
]

== 1.5 Pool-Nulpunten Kaart

#concept(title: "Interpretatie")[
  - *Nulpunten* ($times$): op de imaginaire as bij $s = plus.minus 100j$ $arrow.r$ perfecte onderdrukking bij $omega = 100$
  - *Polen notch* ($circle.filled$): net links van de imaginaire as $arrow.r$ smalle notch
  - *Polen LP* ($circle.filled$): verder links $arrow.r$ bredere bandbreedte
  - Alle polen links $arrow.r$ *stabiel systeem* $checkmark$
]

// ============================================================================
//                          QUESTION 2: P CONTROLLER
// ============================================================================

= Vraag 2 — P Regelaar
#chapter-outline()

== 2.1 Transferfunctie van het systeem

Uit `tf01.mat`:
$
  G(s) = frac(10^7 s + 9.81 dot 10^8, s^4 + 1.275 dot 10^4 s^3 + 1.326 dot 10^7 s^2 + 5.572 dot 10^7 s + 1.07 dot 10^9)
$

#concept(title: "Systeemeigenschappen")[
  - *Orde*: 4 (4 polen, 1 nulpunt)
  - *Type*: continu tijdssysteem
  - De DC-versterking is $G(0) = 9.81 dot 10^8 / (1.07 dot 10^9) approx 0.917$
]

== 2.2 Stabiliteitsanalyse

#theorie(title: "Hoe bepaal je stabiliteit?")[
  Een systeem is:
  - *Stabiel*: alle polen hebben negatief reëel deel ($"Re"(p_i) < 0$)
  - *Marginaal stabiel*: minstens één pool op de imaginaire as ($"Re"(p_i) = 0$), rest negatief
  - *Instabiel*: minstens één pool met positief reëel deel ($"Re"(p_i) > 0$)

  *Methoden om stabiliteit te checken:*
  + Pool-nulpunten kaart (directe inspectie)
  + Stapantwoord (groeit het signaal onbeperkt?)
  + Impulsantwoord (sterft het uit?)
  + Nyquist plot (omcirkelt het $-1$?)
]

#waarschuwing(title: "Routh-Hurwitz criterium")[
  Voor een 4e-orde systeem is het *niet voldoende* dat alle coëfficiënten positief zijn. Je moet de volledige Routh-tabel berekenen of de polen numeriek bepalen.
]

== 2.3 Gesloten-lus met P regelaar

#theorie(title: "Closed-loop structuur")[
  Met een proportionele regelaar $C(s) = K$:

  $ T(s) = frac(K dot G(s), 1 + K dot G(s)) $

  De polen van $T(s)$ zijn de wortels van: $1 + K dot G(s) = 0$

  Als $K$ toeneemt, verschuiven de polen (root locus).
]

== 2.4 Bode Plot Analyse

#theorie(title: "Gain Margin en Phase Margin")[
  - *Gain Margin (GM)*: hoeveel versterking je kunt toevoegen voordat het systeem instabiel wordt. Gemeten bij de *fase-kruisfrequentie* ($angle G = -180°$).

  $ "GM" = frac(1, |G(j omega_("pc"))|) quad "of in dB:" quad "GM"_("dB") = -20 log_10 |G(j omega_("pc"))| $

  - *Phase Margin (PM)*: hoeveel extra fasevertraging het systeem aankan. Gemeten bij de *winstkruisfrequentie* ($|G| = 1 = 0 "dB"$).

  $ "PM" = 180° + angle G(j omega_("gc")) $

  #belangrijk[De maximale $K$ voor stabiliteit is gelijk aan de Gain Margin: $K_("max") = "GM"$]
]

== 2.5 Root Locus

#theorie(title: "Root Locus")[
  De root locus toont hoe de *gesloten-lus polen* bewegen als $K$ van $0$ naar $infinity$ gaat.

  - Start bij de *open-lus polen* ($K = 0$)
  - Eindigt bij de *open-lus nulpunten* of $infinity$ ($K arrow.r infinity$)
  - Kruising met de imaginaire as $arrow.r$ *marginale stabiliteit* $arrow.r$ $K = K_u$
]

== 2.6 Marginaal stabiel: $K_u$ en $T_u$

#form(title: "Ultimate Gain en Ultimate Period")[
  - $K_u$ = de versterkingsfactor waarbij het systeem *marginaal stabiel* is (polen exact op de imaginaire as)
  - $T_u$ = de *oscillatieperiode* bij marginale stabiliteit

  $ T_u = frac(2 pi, omega_u) $

  waarbij $omega_u$ de frequentie is van de imaginaire polen bij $K = K_u$.

  Deze waarden zijn cruciaal voor Ziegler-Nichols tuning (Vraag 3).
]

== 2.7 Keuze van $K$

#concept(title: "Ontwerpaanpak")[
  Kies $K < K_u$ voor een stabiele gesloten lus. Een veelgebruikte vuistregel:

  $ K_p = 0.5 dot K_u $

  Dit geeft voldoende *stabiliteitsmarge* terwijl er nog redelijke prestaties zijn. Afwegen:
  - Grotere $K$ $arrow.r$ snellere respons, maar minder stabiel, meer overshoot
  - Kleinere $K$ $arrow.r$ stabieler, maar tragere respons, grotere fout
]

// ============================================================================
//                          QUESTION 3: PID CONTROLLER
// ============================================================================

= Vraag 3 — PID Regelaar
#chapter-outline()

== 3.1 PID Controller Structuur

#theorie(title: "PID in het frequentiedomein")[
  $ C(s) = K_p + frac(K_i, s) + K_d s = frac(K_d s^2 + K_p s + K_i, s) $

  - *P (proportioneel)*: versterkt de fout $arrow.r$ snellere respons
  - *I (integraal)*: elimineert steady-state fout $arrow.r$ accumuleert fout over tijd
  - *D (derivaat)*: dempt oscillaties $arrow.r$ reageert op de verandering van de fout
]

#form(title: "Tijdsdomein")[
  $ u(t) = K_p e(t) + K_i integral_0^t e(tau) d tau + K_d frac(d e(t), d t) $

  Met $e(t) = r(t) - y(t)$ (fout = referentie - uitgang).
]

== 3.2 Ziegler-Nichols Tuning

#theorie(title: "Ultimate Gain Methode")[
  De Ziegler-Nichols methode gebruikt $K_u$ en $T_u$ uit Vraag 2 als startpunt:

  #figure(
    table(
      columns: 4,
      align: center,
      stroke: 0.5pt,
      [*Type*], [$K_p$], [$T_i$], [$T_d$],
      [P], [$0.5 K_u$], [—], [—],
      [PI], [$0.45 K_u$], [$T_u / 1.2$], [—],
      [*PID*], [*$0.6 K_u$*], [*$T_u / 2$*], [*$T_u / 8$*],
    ),
    caption: [Ziegler-Nichols tuning tabel],
  )

  Omrekening naar $K_i$ en $K_d$:
  $ K_i = K_p / T_i quad quad K_d = K_p dot T_d $
]

#waarschuwing(title: "Beperkingen van Ziegler-Nichols")[
  - Geeft typisch $approx 25%$ overshoot
  - Is een *startpunt*, geen eindresultaat
  - Werkt het beste voor systemen met een duidelijke $K_u$ en $T_u$
  - Moet altijd worden fijngestemd voor de specifieke toepassing
]

== 3.3 Use Case en Fijnafstelling

#concept(title: "Stapantwoord-parameters")[
  Bij het beoordelen van een controller kijken we naar:

  - *Rise time ($t_r$)*: tijd om van 10% naar 90% van de eindwaarde te gaan
  - *Settling time ($t_s$)*: tijd tot het signaal binnen 2% van de eindwaarde blijft
  - *Overshoot ($M_p$)*: maximale overschrijding als percentage
  - *Steady-state error ($e_("ss")$)*: verschil tussen gewenste en werkelijke eindwaarde

  #figure(
    table(
      columns: 3,
      align: (left, center, left),
      stroke: 0.5pt,
      [*Parameter*], [*Verhoog*], [*Effect*],
      [$K_p$ ↑], [Sneller], [Meer overshoot, minder stabiel],
      [$K_i$ ↑], [$e_("ss") arrow.r 0$], [Meer oscillaties, trager],
      [$K_d$ ↑], [Minder overshoot], [Gevoelig voor ruis],
      [$K_p$ ↓], [Stabieler], [Tragere respons],
    ),
    caption: [Effect van PID-parameters op het stapantwoord],
  )
]

#voorbeeld(title: "Fijnafstellingsstrategie")[
  *Startpunt*: Ziegler-Nichols PID ($approx 25%$ overshoot).

  *Doel* (voorbeeld industriële oven):
  - Overshoot $< 5%$ (voorkomen van verbranding)
  - Settling time $< 30 "s"$
  - Steady-state error $= 0$

  *Aanpak*:
  + Verlaag $K_p$ met factor $0.4$ $arrow.r$ minder overshoot
  + Verlaag $K_i$ met factor $0.3$ $arrow.r$ minder integrale opbouw
  + Verhoog $K_d$ met factor $1.5$ $arrow.r$ meer demping
  + Itereer tot de doelen bereikt zijn
]

// ============================================================================
//                          QUESTION 4: TIME DELAY
// ============================================================================

= Vraag 4 — Tijdsvertraging
#chapter-outline()

== 4.1 Tijdsvertraging in de Feedback Loop

#theorie(title: "Effect van tijdsvertraging")[
  Een *tijdsvertraging* $tau$ in de terugkoppellus voegt extra fase toe:

  $ e^(-s tau) quad arrow.r quad |e^(-j omega tau)| = 1, quad angle e^(-j omega tau) = -omega tau "rad" $

  De vertraging verandert *niet* de amplitude, maar voegt *negatieve fase* toe die toeneemt met de frequentie. Dit vreet in op de fasemarge.
]

#form(title: "Maximale tijdsvertraging")[
  De maximale vertraging voordat het systeem instabiel wordt:

  $ tau_("max") = frac("PM", omega_("gc")) $

  waarbij:
  - $"PM"$ = fasemarge in *radialen* ($"PM"_("rad") = "PM"_("deg") dot pi/180$)
  - $omega_("gc")$ = winstkruisfrequentie (waar $|L(j omega)| = 1$)
  - $L(s) = C(s) dot G(s)$ = open-lus transferfunctie
]

#waarschuwing(title: "Waarom wordt het instabiel?")[
  Bij $omega_("gc")$ is de loop gain precies $1$. Als de totale fase daar $-180°$ bereikt:
  - Het systeem versterkt en draait het signaal exact om $arrow.r$ *positieve terugkoppeling*
  - Het signaal groeit exponentieel $arrow.r$ *instabiel*

  Extra fase door de vertraging: $-omega_("gc") dot tau$ radialen. Bij $tau = tau_("max")$ is de totale fase exact $-180°$.
]

== 4.2 Simulink Model

#concept(title: "Simulink blokschema")[
  ```
  Step → [Sum] → [PID] → [Plant G(s)] → Output
           ↑                    |
           |                    ↓
           +←── [Transport Delay] ←──+
  ```

  Belangrijk: gebruik het *Transport Delay* blok in Simulink (niet andere delay-blokken).

  De vertraging zit in de *terugkoppellus*, niet in het voorwaarts pad.
]

== 4.3 Padé-benadering

#theorie(title: "Padé-benadering voor analyse")[
  Voor analytische berekeningen benaderen we de tijdsvertraging met een rationale functie:

  $ e^(-s tau) approx frac(1 - tau s/2, 1 + tau s/2) quad "(1e orde Padé)" $

  Hogere orde geeft meer nauwkeurigheid. In MATLAB: `[num, den] = pade(tau, n)`.

  Dit laat ons toe de polen van het gesloten-lus systeem mét vertraging te berekenen.
]

== 4.4 Herafstemming met Vertraging

#concept(title: "Strategie")[
  Wanneer de vertraging de fasemarge opeet, moet de controller aangepast worden:

  + *Verlaag de bandbreedte* (lagere $K_p$) $arrow.r$ lagere $omega_("gc")$ $arrow.r$ minder fase-impact van de vertraging
  + *Verlaag $K_i$* $arrow.r$ minder integrale actie, minder fase bij lage frequentie
  + *Behoud/verhoog $K_d$* $arrow.r$ voegt positieve fase toe (phase lead) die de vertraging deels compenseert

  Het doel is om voldoende fasemarge te herstellen ondanks de vertraging.
]

// ============================================================================
//                          BELANGRIJKE THEORIECONCEPTEN
// ============================================================================

= Belangrijke Theorieconcepten
#chapter-outline()

== 5.1 Transferfuncties

#theorie(title: "Definitie")[
  Een transferfunctie beschrijft de relatie tussen input en output in het *Laplace-domein*:

  $ H(s) = frac(Y(s), X(s)) = frac(b_m s^m + dots + b_1 s + b_0, a_n s^n + dots + a_1 s + a_0) $

  - *Nulpunten*: wortels van de teller ($H(s) = 0$) $arrow.r$ frequenties die geblokkeerd worden
  - *Polen*: wortels van de noemer ($H(s) arrow.r infinity$) $arrow.r$ bepalen het dynamisch gedrag
]

== 5.2 Bode Plot Samenvattingsregels

#form(title: "Asymptotische Bode Plot")[
  *Magnitude*:
  - Pool bij $omega_p$: $-20 "dB/dec"$ na $omega_p$
  - Nulpunt bij $omega_z$: $+20 "dB/dec"$ na $omega_z$
  - Pool bij $s = 0$ (integrator): $-20 "dB/dec"$ altijd
  - Dubbele pool: $-40 "dB/dec"$

  *Fase*:
  - Eenvoudige pool: $0° arrow.r -90°$ (transitie over 2 decades rond $omega_p$)
  - Eenvoudige nulpunt: $0° arrow.r +90°$
  - Integrator: constant $-90°$
]

== 5.3 Nyquist en Stabiliteit

#theorie(title: "Nyquist criterium")[
  Het Nyquist plot toont $G(j omega)$ in het complexe vlak voor $omega: 0 arrow.r infinity$.

  *Vereenvoudigd criterium* (voor open-lus stabiele systemen):
  Het gesloten-lus systeem is stabiel als en slechts als het Nyquist plot het punt $-1 + 0j$ *niet omcirkelt*.

  De afstand van het Nyquist plot tot $-1$ is gerelateerd aan de stabiliteitsmarges.
]

== 5.4 Root Locus Samenvatting

#theorie(title: "Root Locus regels")[
  + Start bij open-lus polen ($K = 0$)
  + Eindigt bij open-lus nulpunten of $infinity$
  + Aantal takken = orde van de noemer
  + Op de reële as: root locus rechts van een oneven aantal reële polen+nulpunten
  + Kruising imaginaire as $arrow.r K_u$ (marginale stabiliteit)
]

// ============================================================================
//                              FORMULARIUM
// ============================================================================

#printformularium()
