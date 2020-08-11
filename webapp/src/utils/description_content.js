import reflectanceImage from "url:../img/projektbeschrieb.png";
import ndviZeitreiheImage from "url:../img/ndvi_zeitreihe.png";
import useCase2Viewer from "url:../img/uc2_viewer_screenshot.jpg";
import sentinel_orbits from "url:../img/sentinel_orbits.jpg";
import sommersturm2017Image from "url:../img/sommersturm_2017.jpg";
import nbrDiff from "url:../img/nbr_diff.png";
import ndviAnomalienImage from "url:../img/ndvi_anomalien.PNG";
import SchlussberichtWeb from "url:../assets/Schlussbericht_Web.pdf";
import { getVideoElement } from "./main_util";

const descriptionContent = {
  main_title: "Waldmonitoring Use-Cases mit Sentinel Satellitenbildern",
  authors:
    "Dominique Weber (HAFL), Alexandra Erbach (HAFL), Christian Rosset (HAFL), Hanskaspar Frei (KARTEN-WERK GmbH), Thomas Bettler (BAFU)",
  hint: `<div style='padding:20px 0'>August 2020</div>
    <div>Auf dieser Seite werden die Ergebnisse des Forschungsprojektes <strong>«Einsatz von Fernerkundungsdaten in Forstbetrieben und Forstdiensten anhand von konkreten Use-Cases»</strong> vorgestellt, 
    welches von der Fachhochschule für Agrar-, Forst- und Lebensmittelwissenschaften BFH-HAFL im Auftrag und mit Unterstützung des Bundesamtes für Umwelt (BAFU) und KARTEN-WERK GmbH durchgeführt wurde.</div>
    <div style="height:16px"></div>
    <div>Das Hauptziel des Projektes war die Implementierung von Kartenviewern sowie Geodiensten (Erklärung dazu siehe z.B. <a href="https://www.geo.admin.ch/de/geo-dienstleistungen/geodienste.html" rel="noopener noreferrer" target="_blank">hier</a>) für konkrete Use-Cases mit existierenden, 
    möglichst frei verfügbaren Fernerkundungsdaten. Es wurden 3 Use-Cases zusammen mit VertreterInnen aus der Praxis ausgearbeitet 
    (Abgleich von Angebot und Nachfrage), und die Informationen, Daten und Resultate bedarfsgerecht bereitgestellt.</div>
    <ul style="margin-block-start: 8px; margin-block-end:8px">
    <li style="padding:4px 0">Use-Case 1 - <strong>Monitoring jährlicher Waldveränderungen (forstliche Eingriffe und andere)</strong></li>
    <li>Use-Case 2 - <strong>Rasche Erfassung von Sommersturmschäden</strong></li>
    <li style="padding:4px 0">Use-Case 3 - <strong>Hinweiskarten zur Vitalität von Waldflächen</strong></li>
    </ul>
  
    <div>Auf dieser Seite finden Sie Hinweise zur korrekten Verwendung der Kartenviewer und Geodienste sowie Videoanleitungen 
    und Hintergrundinformationen. Zu Beginn wird auf den Hintergrund des Projektes sowie die verwendeten Daten eingegangen. 
    Daraufhin werden die drei Use-Cases nacheinander vorgestellt, wobei jeweils Hinweise zur Benutzung sowie Hintergrundinformationen 
    zur Methode bereitgestellt werden, veranschaulicht durch Grafiken und Video-Tutorials. Nach einer kurzen Erläuterung zu den 
    Kartenviewern und Geodiensten wird schliesslich noch ein Ausblick auf den Fortgang des Projektes gegeben.</div>
    <div style='padding:12px 0'><strong>Wichtig:</strong> Die bereitgestellten Daten und Services sind bis dato ausschliesslich für Testzwecke gedacht.</div>`,
  blocks: [
    {
      title: "Inhalt",
      content: `<div><table>
      <tr><td class="contents">1 Hintergrund</td></tr>
      <tr><td class="contents">2 Daten</td></tr>
      <tr><td class="contents">3 Use-Case 1 - Jährliche Waldveränderungen</td></tr>
      <tr><td class="contents">4 Use-Case 2 - Test Sommersturmschäden 2017</td></tr>
      <tr><td class="contents">5 Use-Case 3 - Hinweiskarte zur Vitalität</td></tr>
      <tr><td class="contents">6 Kartenviewer und Geodienste</td></tr>
      <tr><td class="contents">7 Ausblick</td></tr>
      </table></div><div style="height:16px"></div>`
    },
    {
      title: "1 Hintergrund",
      content: `Das Angebot an Fernerkundungsdaten sowie leistungsstarken Analysetools nimmt ständig zu. 
      Wälder lassen sich folglich immer häufiger und detailreicher erfassen. Damit dieses Potenzial in 
      der Praxis jedoch stärker genutzt wird und einen faktischen Mehrwert erzielt, braucht es praxistaugliche 
      Tools und die Bereitstellung von bedarfsgerechten Informationen. Dies erfordert einen intensiven Austausch 
      zwischen Forschung und Praxis. Um den Bedarf der Praxis von Anfang an zu bedienen, wurde im Rahmen dieses 
      Forschungsprojektes eine Expertengruppe mit je drei VertreterInnen von Forstbetrieben und Forstdiensten gebildet. 
      Die drei Use-Cases wurden in enger Zusammenarbeit mit den Praxispersonen ausgebarbeitet.
    <div style="height:16px"></div>
    Dieses Projekt baut auf den Resultaten der Projekte <a href="https://www.planfor.ch/de/content/schlussbericht-waldmonitoring-mit-sentinel-2-satellitenbildern" rel="noopener noreferrer" target="_blank">
    «Waldmonitoring mit Sentinel-2 Satellitenbildern»</a> und 
    <a href="https://www.planfor.ch/de/content/schlussbericht-praxistauglicher-einsatz-von-fernerkundung-im-waldbereich-zustand-entwicklung" rel="noopener noreferrer" target="_blank">
    «Praxistauglicher Einsatz von Fernerkundung im Waldbereich»</a> auf.
    <div style="height:24px"></div>
    `
    },
    {
      title: "2 Daten",
      content: `Im Fokus dieses Projektes lag die Nutzung von schweizweit frei verfügbaren Daten. Dafür eignen sich insbesondere die Sentinel-2-Satellitenbilder, 
      deren Mehrwert für die Waldwirtschaft bereits aufgezeigt werden konnte
      (<a href="https://www.szf-jfs.org/doi/abs/10.3188/szf.2018.0026" rel="noopener noreferrer" target="_blank">SZF Artikel</a>, 
      <a href="https://www.planfor.ch/de/content/april-mai-2019-sentinel-2-kursreihe" rel="noopener noreferrer" target="_blank">FOWALA Kurs</a>).
      Zusätzlich wurde die nationale Waldmaske (swissTLM3D) verwendet und es können verschiedene Hintergrundkarten 
      (z.B. Luftbilder) dargestellt werden.
      <div style="height:16px"></div>
      <strong>Sentinel-2</strong><br />
      Seit Ende 2015 sind Sentinel-2-Satellitenbilder frei erhältlich und grossflächig verfügbar. 
      Die häufige Wiederholung der Aufnahmen (alle 2-5 Tage) in für Vegetationsanalysen wichtigen 
      pektralbändern bietet dabei ein grosses Potenzial für die Nutzung im Waldbereich. In einem bereits 
      abgeschlossenen Projekt (<a href="https://www.planfor.ch/de/content/schlussbericht-waldmonitoring-mit-sentinel-2-satellitenbildern" rel="noopener noreferrer" target="_blank">
      Weber & Rosset, 2019</a>) konnte aufgezeigt werden, dass sich starke Waldveränderungen 
      wie Holzschläge oder Sommersturmschäden zeitnah erfassen lassen. Auch für die Klassifizierung von Hauptbaumarten 
      und die Beurteilung der Vitalität wurde ein grosses Potenzial festgestellt.
      <div style="height:16px"></div>
      <strong>Vegetationsindizes</strong><br />
      Vegetationsindizes werden aus der Kombination mehrerer Spektralbänder berechnet und eignen sich zur <strong>Beurteilung 
      des Vegetationszustandes</strong>. Zum Beispiel kann mit solchen Indizes das Verhältnis der Reflexionen im roten und nahen 
      infraroten Spektralbereich abgebildet werden, welches sich in Abhängigkeit vom Chlorophyllgehalt der Pflanzen und 
      der Zellstruktur der Blätter ändert (siehe Abb. 1). Basierend auf Reflexionsverhältnissen im roten (ca. 630–690 nm), 
      nahen infraroten (ca. 780– 900 nm) und kurzwellig infraroten (ca. 1400-3000 nm) Spektralbereich dienen sie als Indikatoren 
      für die Dichte, Produktivität und Vitalität der Vegetation und eignen sich somit für das <strong>Monitoring von Waldveränderungen</strong>.
      <ol>
      <li>
      <strong>NDVI</strong> (<a href="https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index" rel="noopener noreferrer" target="_blank">Normalized Difference Vegetation Index</a>): Der NDVI ist der am 
      häufigsten verwendete Vegetationsindex. Er berechnet sich aus den Reflexionswerten 
      im nahen Infrarotbereich (NIR) und im roten sichtbaren Bereich (Rot) des Lichtspektrums:<br /><br />
      
      NDVI=(NIR-Rot)/(NIR+Rot) 
      
      <br /><br />
      Durch die Normierung ergibt sich ein Wertebereich zwischen −1 und +1. 
      Negative Werte bezeichnen Wasserflächen. Ein Wert zwischen 0 und 0.2 entspricht nahezu 
      vegetationsfreien Flächen, während ein Wert nahe 1 auf eine hohe Vegetationsbedeckung 
      mit vitalen grünen Pflanzen schließen lässt.
      <div style="height:16px"></div>
      <img src="${reflectanceImage}" alt="plant reflection" style="max-width:100%"/>
      <div style="height:16px"></div>
      <div style="font-size:12px">Abb. 1 : Reflexionsgrad der Vegetation [%] in Abhängigkeit von der Wellenlänge des Lichtes [nm]. 
      Der starke Anstieg der Reflexion innerhalb des roten und nahen infraroten Spektralbereichs ist ein Indikator für die 
      Vitalität von Pflanzen und eignet sich zur Unterscheidung von gesunder (grüne Kurve) und gestresster (schwarze Kurve) Vegetation. 
      (Bildquelle: <a href="https://www.micasense.com/faq" rel="noopener noreferrer" target="_blank">https://www.micasense.com/faq</a>)</div>
      </li>
      <li>
      <div style="height:24px"></div>
      <strong>NBR</strong> (Normalized Burn Ratio): Der NBR, auch NDII genannt (Normalized Difference Infrared Index), 
      wird häufig für die Erkennung von Waldbrandflächen aber auch für die Detektion anderer Waldveränderungen wie 
      Sturmschadflächen verwendet. Er berechnet sich aus den Reflexionswerten im nahen (NIR) und kurzwelligen (SWIR) Infrarotbereich:
      <br /><br />
      NBR=(NIR-SWIR)/(NIR+SWIR) 
      <br /><br />
      </li>
      </ol>
      <div style="height:16px"></div>
      <strong>Waldmaske</strong><br />
      Die Waldmaske wurde aus dem topografischen Landschaftsmodell der Schweiz (swissTLM3D) abgeleitet 
      (<a href="https://shop.swisstopo.admin.ch/de/products/landscape/tlm3D" rel="noopener noreferrer" target="_blank">https://shop.swisstopo.admin.ch/de/products/landscape/tlm3D</a>).
      <div style="height:16px"></div>
      <strong>Hintergrundkarten</strong><br />
      Als Hintergrundkarten werden die Luftbilder und Landeskarten von swisstopo, sowie das Vegetationshöhenmodell 
      des LFI als <a href="https://shop.swisstopo.admin.ch/de/products/geoservice/swisstopo_geoservices/WMTS_info" rel="noopener noreferrer" target="_blank">swisstopo Geodienste</a> eingebunden.
      <div style="height:24px"></div>
    `
    },
    {
      title: "3 Use-Case 1 - Jährliche Waldveränderungen",
      content: `<strong>Starke und flächige Waldveränderungen</strong> können mit Sentinel-2-Satellitenbildern erkannt 
      und als <strong>jährliche Hinweiskarten</strong> angeboten werden. Die dargestellten Veränderungen beziehen sich 
      auf eine starke <strong>Abnahme der Vegetationsaktivität zwischen August (Vorjahr) und Juni (Folgejahr)</strong>. 
      Die Stärke der Veränderung ist grob dargestellt (siehe Legende im Kartenviewer). Die räumliche Auflösung 
      beträgt 10 x 10 m. Kleinräumige und schwache Veränderungen sind damit nicht detektierbar. 
      Ausserdem kann keine Aussage über die Ursache der Veränderung getroffen werden. 
      Es kann sich also sowohl um Holzschläge, Sturmschäden als auch um andere Veränderungen handeln.<br /><br />

      Das folgende <strong>Video</strong> erläutert die <strong>Benutzung des Kartenviewers</strong> «<a href="https://forestmonitoring.lab.karten-werk.ch/veraenderung">Jährliche Veränderungen</a>»:
    <div style="height:16px"></div>
    ${getVideoElement("mYK2KJqgrhM")}
    <div style="height:16px"></div>
    <u>Hintergrundinformationen zur Methode</u><br /><br />
    Für die automatische Detektion von Veränderungsflächen wurden die Unterschiede zwischen zwei Jahren mit dem NDVI 
    (Normalized Difference Vegetation Index; siehe Abschnitt 2) untersucht. Um bewölkte Aufnahmen automatisch herauszufiltern, 
    wurde dabei für jeden Pixel (10 x 10 m) der maximale NDVI-Wert aller verfügbaren Bilder der Sommermonate (Juni – August) verwendet. 
    Während dieser Zeit ist praktisch die gesamte Vegetation grün. So entstehen nahezu wolkenfreie, jährliche Rasterbilder mit dem 
    maximalen NDVI (<strong>«NDVI Maximum Komposit»</strong>). Aus diesen Kompositen wird die <strong>Differenz</strong> zwischen zwei Jahren gebildet. Die Differenzwerte 
    spiegeln dementsprechend die Stärke der Veränderung wider. So weisen Werte näher -1 auf stärkere Waldveränderungen (z.B. Räumungen) 
    hin. Mittels Schwellenwert wurden die Veränderungsflächen zudem als Vektordaten (Polygone) ausgeschieden und sind 
    <a href="https://forestmonitoring.lab.karten-werk.ch/services">hier</a> per Web Map Service (WMS) Dienst verfügbar. 
    Bisher wurden Veränderungskarten für die Jahre 2016/2017, 2017/2018 und 2018/2019 gerechnet. 
    Ab Herbst 2020 wird die Veränderungskarte für 2019/2020 zur Verfügung stehen. Die nachstehende Abbildung veranschaulicht das Vorgehen.
    <div style="height:8px"></div>
    <img src="${ndviZeitreiheImage}" alt="plant reflection" style="max-width:100%"/>
    <div style="height:16px"></div>
    <div style="font-size:12px">Abb. 2 : Veranschaulichung der Methode zur Erkennung von Waldveränderungen auf Basis des 
    Sentinel-2-NDVI. Aus allen verfügbaren Sentinel-2-Aufnahmen der Sommermonate wird pro Jahr ein NDVI Maximum Komposit Raster erstellt. 
    Aus diesen Kompositen wird jeweils die Differenz zwischen zwei Jahren gebildet (∆NDVI), wie hier im Beispiel zwischen 2017 und 2018.</div>
    <div style="height:24px"></div>
    `
    },
    {
      title: "4 Use-Case 2 - Test Sommersturmschäden 2017",
      content: `Im Rahmen des zweiten Use-Cases wurde eine Methode für die automatische Bereitstellung von 
      schweizweiten <strong>Hinweiskarten für Sommersturmschäden</strong> auf Basis von Sentinel-2-Satellitenbildern entwickelt. 
      Als Beispiel und für den Praxistest wurden die Sommerstürme (Ende <a href="http://www.sturmarchiv.ch/index.php?title=Extremereignisse_2017#Juli" rel="noopener noreferrer" target="_blank">
      Juli</a> und Anfang <a href="http://www.sturmarchiv.ch/index.php?title=Extremereignisse_2017%23August" rel="noopener noreferrer" target="_blank">August</a>) im Jahr 2017 ausgewählt. 
      Zwischen dem 5.7.2017 und dem 19.8.2017 können alle verfügbaren Sentinel-2-Aufnahmen, welche mindestens einen Teil 
      der Schweiz abdecken, vom Benutzer/Benutzerin ausgewählt werden. So kann nach einem Sturmereignis rasch geprüft werden, 
      ob eine brauchbare, sprich <strong>möglichst wolkenfreie</strong>, Aufnahme zur Verfügung steht. Daraufhin werden im Kartenviewer potenzielle 
      Veränderungsflächen angezeigt, falls welche vorhanden sind.<br /><br />

      Diese ausgewiesenen Veränderungsflächen basieren auf der Abnahme des Normalized Burn Ratio Vegetationsindexes 
      (NBR; siehe Abschnitt 2). In einem Vorgängerprojekt 
      (<a href="https://www.planfor.ch/de/content/schlussbericht-waldmonitoring-mit-sentinel-2-satellitenbildern" rel="noopener noreferrer" target="_blank">Weber & Rosset, 2019</a>) 
      hat sich dieser Index als geeignet für die Detektion von Sturmschadflächen erwiesen.<br /><br />

      Die Werte in der Legende des Kartenviewers stellen die <strong>Abnahme des NBR</strong> multipliziert mit 100 dar, 
      gemittelt pro Veränderungsfläche (Polygon). Die Multiplikation mit 100 erfolgt dabei lediglich aus Speicherplatzgründen 
      (Ganzzahl statt Dezimalzahl). Die Differenzbildung erfolgt aus dem <strong>Bild des ausgewählten Datums</strong> und einem Referenzzustand 
      vor dem vermuteten Ereignis / ausgewählten Datum. Als Referenz wird ein möglichst <strong>wolkenfreies Komposit</strong> (siehe auch Abschnitt 3) 
      aller verfügbaren Bilder der <strong>45 Tage vor dem ausgewählten Datum</strong> verwendet. Werte näher bei -100 weisen auf stärkere Schäden hin. 
      Auch Wolken werden angezeigt (siehe Abb. 3), um fehlerhafte Rückschlüsse auf das Nichtvorhandensein von Schäden zu vermeiden. 
      Das gleiche gilt für sogenannte NoData- Flächen, das heisst Flächen, für die zum gewählten Zeitpunkt keine Sentinel-2-Daten zur 
      Verfügung stehen (siehe Abb. 3). Da die Schweiz durch zwei Orbits abgedeckt wird, wird an einem Aufnahmedatum immer nur ein Teil 
      der Fläche der Schweiz erfasst (siehe Abb. 4). Der andere Teil wird im Kartenviewer jeweils als NoData-Fläche gekennzeichnet.
      <br /><br />
      
      Die Veränderungspolygone wurden mittels Schwellenwert (-15) und ab einer Mindestgrösse von 5 Aren ausgeschieden. 
      Für jede ausgeschiedene Veränderungsfläche wurden neben dem Zeitpunkt (time) zudem Flächengrösse (area), sowie Mittelwert (mean), 
      Maximalwert (max) und 90%-Quantil (p90) der NBR-Differenzwerte berechnet und als Attribute in den Vektordaten gespeichert. 
      Das Attribut class differenziert zwischen Veränderungsflächen (class = 1), Wolken (class = -1), und NoData (class = -2). 
      Die Vektordaten stehen <a href="https://forestmonitoring.lab.karten-werk.ch/services">hier</a> als Web Feature Service (WFS) Dienst zur Verfügung.<br /><br />
      
      <div style="height:16px"></div>
      <img src="${useCase2Viewer}" alt="useCase 2 viewer screenshot" style="max-width:100%"/>
      <div style="height:8px"></div>
      <div style="font-size:12px">Abb. 3 : Hinweis auf Veränderungen gemäss Sentinel-2-Aufnahme vom 5.8.2017 
      (Screenshot aus dem Kartenviewer). Mithilfe der Legende können potenzielle Schadflächen (gelb bis rot), 
      Wolken (grau schraffiert) und Flächen mit keinen Daten (grau ausgefüllt) unterschieden werden. Das blau 
      umrandete Symbol stellt einen Link auf Sentinel Playground bereit, sodass das zugrundeliegende Satellitenbild 
      einfach visuell überprüft werden kann (Plausibilitätskontrolle).</div>
      <div style="height:32px"></div>

      <img src="${sentinel_orbits}" alt="sentinel orbits" style="max-width:100%"/>
      <div style="height:8px"></div>
      <div style="font-size:12px">Abb. 4 : Darstellung der beiden Sentinel-Orbits, welche die Fläche der Schweiz abdecken. 
      An einem Aufnahmedatum wird entweder Orbit 108 oder 65 erfasst. Für den überlappenden Bereich ist die Bildverfügbarkeit 
      am höchsten (alle 2-3 Tage).</div>
      <div style="height:24px"></div>

      Die Resultate wurden teilweise mit Referenzdaten der WSL validiert und erwiesene flächige Schäden konnten gut erkannt 
      und abgegrenzt werden (siehe Abb. 5). Jedoch werden bis dato auch diverse Flächen fälschlicherweise als Schadflächen 
      ausgeschieden. Dies geschieht insbesondere an Wolkenrändern, sowie im Zusammenhang mit Schnee oder Schattenwurf an 
      steilen Nordhängen. In diesen Fällen ist bei der Interpretation der Ergebnisse besondere Vorsicht geboten. <br />
      Nach Möglichkeit sollte immer ein <strong>wolkenfreier Aufnahmezeitpunkt</strong> ausgewählt werden. Zu diesem Zweck wird für jedes 
      Aufnahmedatum ein Direkt-Link auf Sentinel Playground bereitgestellt (siehe blau umrandetes Symbol in Abb. 3), sodass 
      jedes Bild einfach visuell überprüft werden kann. Aufnahmedatum und Bildausschnitt werden dabei im Link gespeichert und 
      direkt übernommen. In Nussbaumen TG betrug die Wartezeit zwischen dem Sturm vom 2.8.2017 und der nächsten verfügbaren 
      wolkenfreien Aufnahme zum Beispiel 13 Tage (siehe Abb. 5). Das genaue Vorgehen zur Auswahl einer brauchbaren Aufnahme 
      wird im untenstehenden <strong>Video</strong> erklärt und veranschaulicht.
      <div style="height:16px"></div>
      <img src="${sommersturm2017Image}" alt="plant reflection" style="max-width:100%"/>
    <div style="font-size:12px">Abb. 5 : Gute räumliche Abgrenzung von flächigen Schäden im Falle eines Sturmereignisses 
    in Nussbaumen TG am 2.8.2017. Die ausgewiesenen potenziellen Schadflächen wurden mit Referenzdaten der WSL (in Gelb) 
    abgeglichen.</div>
    <div style="height:24px"></div>
    Das folgende <strong>Video</strong> erläutert die <strong>Benutzung des Kartenviewers</strong>
    «<a href="https://forestmonitoring.lab.karten-werk.ch/stoerungen">Sommersturmschäden 2017</a>»:
    <div style="height:16px"></div>
    ${getVideoElement("aamvbhKXoNU")}
    <div style="height:16px"></div>
    <u>Hintergrundinformationen zur Methode</u><br /><br />
    Für jede Sentinel-2-Aufnahme innerhalb der definierten Zeitspanne (5.7. bis 19.8.2017) wurde zuerst der NBR berechnet 
    (<strong style="color:green">NBR<sub>Aktuell</sub></strong>), siehe Abb. 6). Wolken wurden dabei mittels der 
    <a href="https://sentinel.esa.int/web/sentinel/technical-guides/sentinel-2-msi/level-1c/cloud-masks" rel="noopener noreferrer" target="_blank">ESA Wolkenmaske</a> 
    ausgeschieden. Daraufhin wurde der NBR für die <strong>Referenzperiode</strong> berechnet, welche als das <strong>45-Tages-Fenster</strong> 
    vor dem ausgewählten Aufnahmedatum definiert wurde. <br />
    Zu diesem Zweck wurde zuerst mittels der in Abschnitt 3 beschriebenen <i>NDVI Maximum Komposit Methode</i> aus allen verfügbaren 
    Aufnahmen innerhalb der 45-tägigen Zeitspanne ein möglichst wolkenfreies Komposit erstellt. Für dieses wurde dann wiederum der 
    NBR berechnet (<strong style="color:blue">NBR<sub>Referenz</sub></strong>, siehe Abb. 6). Aus diesen beiden Bildern wurde daraufhin die Differenz gebildet (<strong>∆NBR</strong>), und die 
    Veränderungsflächen wurden mittels Schwellenwert ausgeschieden. Die nachfolgende Abbildung veranschaulicht das Vorgehen.

    <div style="height:24px"></div>
    <img src="${nbrDiff}" alt="plant reflection" style="max-width:100%"/>
    <div style="font-size:12px">Abb. 6 : Darstellung des Arbeitsflusses zu Use-Case 2. Für jede Sentinel-2-Aufnahme wird der 
    NBR berechnet (NBR Aktuell). Daraufhin wird der NBR für die Referenzperiode berechnet, welche als das 45-Tages-Fenster 
    vor dem ausgewählten Aufnahmedatum definiert wurde. Zu diesem Zweck wird aus allen verfügbaren Aufnahmen innerhalb der 
    45-tägigen Zeitspanne ein möglichst wolkenfreies Komposit erstellt, für welches wiederum der NBR berechnet wird (NBR Referenz). 
    Aus diesen beiden Bildern wird die Differenz gebildet (∆NBR), und die Veränderungsflächen werden mittels Schwellenwert 
    ausgeschieden.</div>
    <div style="height:24px"></div>
    Dieser Prozess erfolgte wie beschrieben zunächst testweise für den Sommer 2017, jedoch ist die automatisierte Bereitstellung der 
    Veränderungsflächen für die ganze Schweiz möglich und angedacht. Dabei würden die Informationen für alle verfügbaren Aufnahmen 
    innerhalb der letzten 45 Tage ab dem jeweils aktuellen Datum mittels sogenannten «rollenden Archiven» zur Verfügung gestellt werden. 
    Die vollautomatische Analyse und Bereitstellung der Resultate sollte innerhalb von 2-5 Tagen nach Bildaufnahme möglich sein.<br /><br />

    Eine anspruchsvolle Situation stellt sich jedoch im Winter: Vegetationszustand, Beleuchtungsintensität, Wolken, Schatten und Schnee 
    stellen zusätzliche Herausforderungen dar. Ein möglicher Lösungsansatz wäre eine Kombination mit Sentinel-1 Daten, welche von 
    Bewölkungs- und Beleuchtungsintensität nicht beeinflusst werden 
    (siehe dazu ein <a href="https://www.wsl.ch/de/projekte/sturmhinweiskarte.html" rel="noopener noreferrer" target="_blank">laufendes Projekt an der WSL</a>).
    <div style="height:24px"></div>`
    },
    {
      title: "5 Use-Case 3 - Hinweiskarte zur Vitalität",
      content: `Auch die Vitalität von Waldflächen kann mit Sentinel-2-Satellitenbildern grob erfasst werden. 
      Durch den <strong>Vergleich des aktuellen Vegetationszustandes mit den Vorjahren</strong> lassen sich daraus <strong>Hinweiskarten 
      zur Veränderung der Vitalität</strong> erstellen. Hier handelt es sich allerdings um einen ersten Test. 
      Eine Validierung und Verfeinerung der Methode steht noch aus.<br /><br />
      Als Indikator für die Vitalität wurde wiederum der NDVI-Vegetationsindex verwendet (siehe Abschnitt 2). 
      Auf der Karte dargestellt werden sogenannte <strong>NDVI-Anomalien</strong>. Dabei werden jeweils die NDVI-Medianwerte des zweimonatigen 
      Zeitfensters (z.B. Juni - Juli) mit den Medianwerten aller Vorjahre (bis 2015) innerhalb derselben Zeitperiode verglichen 
      (siehe Abb. 7). Negative Werte deuten auf eine Abnahme der Vitalität hin, positive Werte deuten auf eine Zunahme der Vitalität hin. 
      Je weiter die Werte von null abweichen (Erwartungswert), desto wahrscheinlicher ist es, dass eine effektive Veränderung stattfand. 
      Ob es sich bei der Veränderung um Borkenkäferbefall, Trockenstress oder einen Holzschlag handelt, wird hierbei nicht unterschieden. 
      So können z.B. negative Werte sowohl einen Holzschlag wie auch eine vorzeitige Herbstverfärbung beschreiben. Wir sprechen daher von 
      Hinweiskarten und für die Interpretation ist immer auch Expertenwissen über die Wälder und gegebenenfalls eine Feldbegehung notwendig. 
      Durch die Kombination von Satellitenaufnahmen innerhalb des zweimonatigen Fensters können viele Probleme mit Wolken und andere 
      Fehlerquellen reduziert, jedoch nicht vollständig ausgeschlossen werden. Weiter ist zu berücksichtigen, dass die Sentinel-2-Daten 
      erst seit 2015 verfügbar sind, was für die Detektion von Anomalien bis jetzt ein relativ kurzer Zeitraum ist (eine höhere Aussagekraft 
      wird mit jedem zusätzlichen Jahr erwartet).

      <div style="height:24px"></div>
      Das folgende <strong>Video</strong> erläutert die <strong>Benutzung des Kartenviewers</strong> 
      «<a href="https://forestmonitoring.lab.karten-werk.ch/vitalitaet">Hinweiskarten zur Vitalität</a>»:
      <div style="height:16px"></div>
      ${getVideoElement("wraBOBSfcdk")}
      <div style="height:16px"></div>
      <u>Hintergrundinformationen zur Methode</u><br /><br />
      Die Berechnung der NDVI-Anomalien basiert auf dem sogenannten <a href="https://de.wikipedia.org/wiki/Standardisierung_(Statistik)" rel="noopener noreferrer" target="_blank">Z-Wert</a> 
      (siehe z.B. <a href="https://www.sciencedirect.com/science/article/pii/S0034425718305509" rel="noopener noreferrer" target="_blank">Meroni et al., 2019</a>):<br /><br />

      Z<sub>i</sub> = (NDVI<sub>median,i</sub> - NDVI<sub>median,ref</sub>) / NDVI<sub>sd,ref</sub>
      <div style="height:16px"></div>
      Im Gegensatz zu Meroni et al. haben wir den Median anstatt dem arithmetischen Mittel verwendet, 
      da dieser robuster gegenüber Ausreissern ist. NDVI<sub>median,i</sub> bezeichnet somit den <strong>Median</strong> der NDVI-Werte pro 
      <strong>zweimonatigem Zeitfenster</strong> i. NDVI<sub>median,ref</sub> bezeichnet den <strong>Median</strong> der NDVI-Werte innerhalb der <strong>gleichen</strong> 
      zweimonatigen Zeitfenster (z.B. Juni - Juli) der Referenzperiode. NDVI<sub>sd,ref</sub> ist die <strong>Standardabweichung</strong> aller 
      NDVI-Werte innerhalb der gleichen zweimonatigen Zeitfenster (z.B. Juni- Juli) der Referenzperiode.<br /><br />

      Die Standardabweichung gibt Auskunft über die Variabilität der NDVI-Werte innerhalb der Referenzperiode. 
      Je grösser die Variabilität ist, desto kleiner wird die Wahrscheinlichkeit, dass Veränderungen, insbesondere schwache, 
      ausgeschieden werden, was sich in Z-Werten nahe null widerspiegelt. Die Berechnung erfolgt pixelbasiert für jeden 10 x 10 m Pixel, 
      und die Pixelwerte in den Hinweiskarten entsprechen dem jeweiligen Z-Wert.

      <div style="height:16px"></div>
      <img src="${ndviAnomalienImage}" alt="ndvi anomalien" style="max-width:100%"/>
      <div style="font-size:12px">Abb. 7 : NDVI-Zeitreihen-Beispiel zur Veranschaulichung der Z-Wert-Methode. 
      Die blauen Punkte entsprechen den tatsächlichen NDVI-Werten an einem bestimmten Ort (pixelbasiert). 
      Die blauen Linien stellen Interpolationen dar und haben keine weitere Bedeutung. Die Referenzperiode bezieht 
      sich in diesem Fall auf 2016 bis 2018, dargestellt in Grün. 2019 stellt in diesem Beispiel den aktuellen Zustand 
      dar und ist in Rot gekennzeichnet. Die gestrichelten Linien stellen jeweils die beiden Mediane dar, die miteinander 
      verglichen werden, das heisst der Median über Juni/Juli aller Jahre der Referenzperiode (in Grün) mit dem Median 
      über Juni/Juli des aktuellen Jahres (in Rot).</div>
      <div style="height:24px"></div>`
    },
    {
      title: "6 Kartenviewer und Geodienste",
      content: `Für jeden Use-Case wird ein eigener <strong>Kartenviewer</strong> angeboten. Alle Kartenviewer 
      sind über die Startseite <a href="https://forestmonitoring.lab.karten-werk.ch/">https://forestmonitoring.lab.karten-werk.ch/</a> 
      erreichbar und weisen, je nach Use-Case, unterschiedliche Funktionalitäten auf. Sie wurden auch für die Verwendung ausserhalb 
      des Büros konzipiert und können daher auf <strong>mobilen Geräten</strong> benutzt werden.<br />
      Es ist vorgesehen, die Kartenviewer durch weitere Funktionalitäten, wie zum Beispiel die Positionierung über GPS, 
      in einem Nachfolgeprojekt zu ergänzen.<br />
      Die dargestellten Karten können auch als <strong>Geodienste</strong> (WMS, WMTS, WFS) in eine GIS-Umgebung eingebunden werden. 
      Durch Klick auf die Kachel „<a href="https://forestmonitoring.lab.karten-werk.ch/services">Geodienste</a>“ 
      erfahren Sie mehr darüber. Einfache Video-Tutorials zeigen anhand von Beispielen, wie Sie die Services in QGIS einbinden können.<br /><br />
      Die gesamte Webapplikation ist Open Source und unter: <a href="https://github.com/HAFL-FWI/Digital-Forest-Monitoring/tree/master/webapp" rel="noopener noreferrer" target="_blank">https://github.com/HAFL-FWI/Digital-Forest-Monitoring/tree/master/webapp</a> verfügbar.  
      Bei Fragen oder Verbesserungswünschen wenden Sie sich bitte an untenstehenden Kontakt.<br /><br />
      Hanskaspar Frei von KARTEN-WERK GmbH, <a href="mailto:hkfrei@karten-werk.ch">hkfrei@karten-werk.ch</a>
      <div style="height:24px"></div>
      `
    },
    {
      title: "7 Ausblick",
      content: `Im Rahmen eines Nachfolgeprojektes soll der Nutzen von Fernerkundung für die forstliche Praxis weiter erhöht werden. 
      Dazu wird die aktuelle Lösung (Kartenviewer, Geodienste) in Umfang (weiterentwickelte bzw. neue Use-Cases und Tools) und 
      Qualität (bedarfsgerechte Darstellung etc.) ausgebaut. Zudem soll die effektive Verwendung in der Praxis durch intensiven 
      Austausch und den Aufbau einer Community signifikant gesteigert werden.<br /><br />
      In diesem Rahmen sollen unter anderem konkrete Einsatzbeispiele zur effektiven Verwendung der Daten und Tools in der 
      Praxis gesammelt, dokumentiert und bereitgestellt werden. Wer dazu beitragen möchte, weitere Anregungen oder generell 
      Interesse hat, aktiver Teil der User Community zu werden, kann sich sehr gerne jederzeit bei Alexandra Erbach (<a href="mailto:alexandra.erbach@bfh.ch">alexandra.erbach@bfh.ch</a>) melden.
      <div style="height:18px"></div>
      <div><a href="${SchlussberichtWeb}" rel="noopener noreferrer" target="_blank">Download Schlussbericht als PDF</a></div>
      <div style="height:24px"></div>
      `
    }
  ]
};

export default descriptionContent;
