import reflectanceImage from "url:../img/projektbeschrieb.jpg";
import ndviZeitreiheImage from "url:../img/ndvi_zeitreihe.jpg";
import ndviJaehrlicheVeraenderungImage from "url:../img/ndvi_jaehrliche_veraenderung.jpg";
import sommersturm2017Image from "url:../img/sommersturm_2017.jpg";
import nbrDiff from "url:../img/nbr_diff.jpg";
import ndviAnomalienImage from "url:../img/ndvi_anomalien.jpg";
import { getVideoElement } from "./main_util";
const descriptionContent = {
  main_title: "Waldmonitoring Use-Cases mit Sentinel Satellitenbildern",
  authors:
    "Dominique Weber (HAFL), Alexandra Erbach (HAFL), Christian Rosset (HAFL), Hanskaspar Frei (KARTEN-WERK GmbH), Thomas Bettler (BAFU)",
  hint:
    "<div style='padding:20px 0'>August 2020</div>" +
    "<div>Auf dieser Seite finden Sie Hinweise zur korrekten Verwendung der Kartenviewer und Geodienste sowie Videoanleitungen und Hintergrundinformationen.</div>" +
    "<div style='padding:12px 0'><strong>Wichtig:</strong> Die bereitgestellten Daten und Services sind bis dato ausschliesslich für Testzwecke gedacht.</div>",
  blocks: [
    {
      title: "1 Ausgangslage",
      content: `das Angebot an Fernerkundungsdaten sowie leistungsstarken Analysetools nimmt ständig zu. 
    Wälder lassen sich folglich immer häufiger und detailreicher erfassen. 
    Damit dieses Potenzial in der Praxis stärker genutzt wird und einen faktischen Mehrwert erzielt, 
    müssen praxistaugliche Tools vorhanden sein und die Informationen bedarfsgerecht bereitgestellt werden. 
    Dies erfordert unter anderem einen intensiven Austausch innerhalb der Praxis und zwischen Forschung und Praxis. 
    Im Rahmen eines Forschungsprojektes der BFH-HAFL im Auftrag bzw. mit Unterstützung des BAFU wurden vorhandene, 
    möglichst schweizweit flächendeckende und frei verfügbare Fernerkundungsdaten für konkrete Use-Cases und mit 
    einem klaren Mehrwert für die Praxis eingesetzt. Das Hauptziel dieses Projektes war die Implementierung 
    von Kartenviewern sowie Geodiensten zu den entsprechenden Use-Cases.
    <div style="height:16px"></div>
    Dieses Projekt baut auf den Resultaten der Projekte «Waldmonitoring mit Sentinel-2 Satellitenbildern» und 
    «Praxistauglicher Einsatz von Fernerkundung im Waldbereich» auf [LINK zu den Berichten? >> Thomas fragen].
    <div style="height:24px"></div>
    `
    },
    {
      title: "2 Daten",
      content: `Das Ziel war die Nutzung von schweizweit frei verfügbaren Daten. 
      Dazu eigneten sich insbesondere die Sentinel-2-Satellitenbilder, deren Mehrwert 
      für die Waldwirtschaft bereits aufgezeigt werden konnte (<a href="https://www.szf-jfs.org/doi/abs/10.3188/szf.2018.0026">SZF Artikel</a>, 
      <a href="https://www.planfor.ch/de/content/april-mai-2019-sentinel-2-kursreihe">FOWALA Kurs</a>).
      <div style="height:16px"></div>
      <strong>Sentinel-2-Satellitenbilder</strong><br />
      Seit Ende 2015 sind Sentinel-2-Satellitendaten frei erhältlich und grossflächig verfügbar. 
      Die häufige Wiederholung der Aufnahmen in für Vegetationsanalysen wichtigen Spektralbändern 
      bietet dabei ein grosses Potenzial für die Nutzung im Waldbereich. 
      In einem bereits abgeschlossenen Projekt konnte aufgezeigt werden, dass sich starke 
      Waldveränderungen wie Holzschläge oder Sommersturmschäden zeitnah erfassen lassen. 
      Auch für die Klassifizierung von Hauptbaumarten und die Beurteilung der Vitalität 
      wurde ein grosses Potenzial festgestellt. 
      <div style="height:16px"></div>
      <strong>Vegetationsindizes</strong><br />
      Vegetationsindizes machen sich den starken Anstieg des Reflexionsgrades photosynthetisch aktiver 
      Vegetation vom roten (ca. 630–690 nm) zum nah-infraroten (ca. 750–900 nm) Spektralbereich zunutze. 
      Basierend auf Reflexionsverhältnissen im roten, nahinfraroten und kurzwellig infraroten Spektralbereich 
      dienen sie als Indikatoren für die Dichte, Produktivität und Vitalität der Vegetation und eignen sich 
      somit für das Monitoring von Waldveränderungen.
      <ol>
      <li>
      <strong>NDVI</strong> (<a href="https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index">Normalized Difference Vegetation Index</a>): Der NDVI ist der am 
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
      <div style="font-size:12px">Bildquelle: <a href="https://www.micasense.com/faq">https://www.micasense.com/faq</a></div>
      </li>
      <li>
      <div style="height:24px"></div>
      <strong>NBR</strong> (Normalized Burn Ratio): Der NBR, auch NDII genannt (Normalized Difference Infrared Index), 
      wird häufig für die Erkennung von Waldbrandflächen aber auch für die Detektion anderer Waldveränderungen verwendet. 
      Er berechnet sich aus den Reflexionswerten im nahen (NIR) und kurzwelligen (SWIR) Infrarotbereich:
      <br /><br />
      NBR=(NIR-SWIR)/(NIR+SWIR) 
      <br /><br />
      </li>
      </ol>
      <div style="height:16px"></div>
      <strong>Waldmaske</strong><br />
      Die Waldmaske wurde aus dem topografischen Landschaftsmodell der Schweiz (swissTLM3D) abgeleitet 
      (<a href="https://shop.swisstopo.admin.ch/de/products/landscape/tlm3D">https://shop.swisstopo.admin.ch/de/products/landscape/tlm3D</a>).
      <div style="height:16px"></div>
      <strong>Hintergrundkarten</strong><br />
      Als Hintergrundkarten werden die Luftbilder und Landeskarten von swisstopo, sowie das Vegetationshöhenmodell 
      des LFI als <a href="https://shop.swisstopo.admin.ch/de/products/geoservice/swisstopo_geoservices/WMTS_info">swisstopo Geodienste</a> eingebunden.
      <div style="height:24px"></div>
    `
    },
    {
      title: "3 Kartenviewer und Geodienste",
      content: `Für jeden Use-Case wird ein einfacher Kartenviewer angeboten. 
      Alle Viewer sind über die <a href="https://forestmonitoring.lab.karten-werk.ch/">Startseite</a>
      erreichbar und weisen –je nach Use-Case- unterschiedliche Funktionalitäten auf. 
      Sie wurden auch für die Verwendung ausserhalb des Büros konzipiert und können daher auf 
      mobilen Geräten benutzt werden. <br />
      In naher Zukunft werden sie durch weitere Funktionalitäten wie die Positionierung über GPS oder URL Parameter ergänzt.
      Die dargestellten Karten können auch als Geodienste (WMS, WMTS, WFS) in eine GIS-Umgebung eingebunden werden. Durch Klick auf die Kachel „Geodienste“, erfahren Sie mehr darüber und es gibt Videos mit Beispielen wie Sie die Services in QGIS einbinden können.
      Die gesamte Webapplikation ist Open Source und unter: <a href="https://github.com/HAFL-FWI/Digital-Forest-Monitoring/tree/master/webapp">https://github.com/HAFL-FWI/Digital-Forest-Monitoring/tree/master/webapp</a> verfügbar.  
      Bei Fragen oder Verbesserungswünschen wenden Sie sich bitte an untenstehenden Kontakt.<br /><br />
      Kontakt: Hanskaspar Frei von KARTEN-WERK GmbH, <a href="mailto:hkfrei@karten-werk.ch">hkfrei@karten-werk.ch</a>
      <div style="height:24px"></div>
      `
    },
    {
      title: "4 Use Case 1 - Jährliche Waldveränderungen",
      content: `<strong>Starke und flächige Waldveränderungen</strong> können mit Sentinel-2-Satellitenbildern erkannt und 
    als <strong>jährliche Hinweiskarten</strong> angeboten werden. Die dargestellten Veränderungen beziehen sich auf 
    eine starke <strong>Abnahme der Vegetationsaktivität zwischen August (Vorjahr) und Juni (Folgejahr)</strong>. 
    Die räumliche Auflösung beträgt 10 x 10 m. Kleinräumige und schwache Veränderungen sind damit 
    nicht detektierbar. Ausserdem kann keine Aussage über die Ursache der Veränderung getroffen werden. 
    Es kann sich also sowohl um Holzschläge, Sturmschäden als auch um andere Veränderungen handeln. 
    Mit der Angabe zur Stärke der Veränderung (siehe Legende im Kartenviewer) lassen sich jedoch z.B. 
    Durchforstungen und Räumungen oft gut unterscheiden.<br /><br />

    Das folgende Video gibt Hinweise zur Benutzung der <a href="https://forestmonitoring.lab.karten-werk.ch/veraenderung">
    Hinweiskarte für die jährlichen Veränderungen im Kartenviewer</a>:
    <div style="height:16px"></div>
    ${getVideoElement("mYK2KJqgrhM")}
    <div style="height:16px"></div>
    <u>Hintergrundinformationen zur Methode</u><br /><br />
    Sentinel-2-Daten bieten die Basis für eine objektive Einschätzung der jährlichen Veränderungen, 
    welche effizient und für grosse Flächen erfasst werden können, sei es auf Betriebs- oder Kantonsebene. 
    Für die automatische Detektion von Veränderungsflächen wurden die Unterschiede zwischen zwei Jahren mit 
    dem Normalized Difference Vegetation Index (NDVI; siehe Kapitel 2) untersucht. Um bewölkte Aufnahmen 
    automatisch herauszufiltern, wurde dabei für jeden Pixel (10 x 10 m) der maximale NDVI-Wert aller 
    verfügbaren Bilder der Sommermonate (Juni – August) verwendet. So entstehen praktisch wolkenfreie, 
    jährliche <strong>«NDVI Maximum Composites»</strong>. Aus diesen wurde die <strong>Differenz</strong> gebildet. Die Differenzwerte spiegeln 
    dementsprechend die Stärke der Veränderung wider. So weisen Werte näher -1 auf stärkere Waldveränderungen 
    (z.B. Räumungen) hin. Die Legende im Kartenviewer gibt Auskunft über die Stärke der Veränderung. 
    Mittels Schwellenwert wurden die Veränderungsflächen zudem als Vektordaten ausgeschieden und sind <a href="https://forestmonitoring.lab.karten-werk.ch/services">hier</a> 
    per Web Map Service (WMS) Dienst verfügbar.
    <div style="height:16px"></div>
    <img src="${ndviZeitreiheImage}" alt="plant reflection" style="max-width:100%"/>
    <div style="height:16px"></div>
    <img src="${ndviJaehrlicheVeraenderungImage}" alt="plant reflection" style="max-width:100%"/>
    <div style="font-size:12px">[Grafik 1 im BAFU-Vortrag/PPT -> unter Dokumentation, Grafik 2 aus Sen2 Fobi, K2, 3_Uebung_Jaehrliche Waldveraenderungen]</div>
    <div style="height:24px"></div>
    `
    },
    {
      title: "5	Use Case 2 - Test Sommersturmschäden 2017",
      content: `Das Ziel des zweiten Use Cases war die Erarbeitung von <strong>Hinweisen auf natürliche Störungen</strong>
      auf Basis von Sentinel-2-Satellitenbildern. Als erstes Resultat steht eine schweizweite <strong>Hinweiskarte 
      für Sommersturmschäden im Jahr 2017</strong> zur Verfügung. Zwischen dem 5.7.2017 und dem 19.8.2017 können alle 
      Daten ausgewählt werden, für die Sentinel-2 Aufnahmen zur Verfügung stehen. So kann nach einem Sturmereignis 
      direkt die nächste verwendbare Aufnahme ausgewählt werden. Die ausgewiesenen Veränderungsflächen wurden 
      basierend auf der Abnahme des Normalized Burn Ratio Vegetationsindexes (NBR; siehe Kapitel 2) mittels Schwellenwert 
      ausgeschieden.<br /><br />

      Die Werte in der Legende stellen die <strong>Abnahme des NBR Index</strong> multipliziert mit 100 dar, 
      gemittelt pro Fläche. Die Differenzbildung erfolgt dabei jeweils aus dem <strong>Bild des ausgewählten 
      Datums</strong> und einem <strong>wolkenfreien Referenz-Composite aller verfügbaren Bilder der vorhergehenden 45 Tage</strong>. 
      Werte näher bei -100 weisen auf stärkere Schäden hin. Auch Wolken und NoData-Flächen werden ausgewiesen, 
      um fehlerhafte Rückschlüsse auf das Nichtvorhandensein von Schäden zu vermeiden. Veränderungsflächen 
      wurden ab einer Mindestgrösse von 5 Aren ausgeschieden.<br /><br />
      
      Für jede ausgeschiedene Veränderungsfläche wurden neben dem Zeitpunkt (<i>time</i>) zudem Flächengrösse (<i>area</i>), 
      sowie Mittelwert (<i>mean</i>), Maximalwert (<i>max</i>) und 90%-Quantil (<i>p90</i>) der NBR-Differenzwerte berechnet und 
      als Attribute in den Vektordaten gespeichert. Das Attribut <i>class</i> differenziert zwischen Veränderungsflächen 
      (class = 1), Wolken (class = -1), und NoData (class = -2).<br /><br />
      
      Die Vektordaten stehen <a href="https://forestmonitoring.lab.karten-werk.ch/services">hier</a> als Web Feature Service (WFS) Dienst zur Verfügung.<br /><br />
      
      Die Resultate wurden teilweise mit Referenzdaten der WSL validiert und erwiesene flächige Schäden 
      konnten gut erkannt und abgegrenzt werden. Jedoch werden bis dato auch diverse Flächen fälschlicherweise 
      als Schadflächen ausgeschieden. Dies geschieht insbesondere an Wolkenrändern, sowie im Zusammenhang mit 
      Schnee oder Schattenwurf an steilen Nordhängen. In diesen Fällen ist bei der Interpretation der Ergebnisse 
      besondere Vorsicht geboten. Nach Möglichkeit sollte immer ein wolkenfreier Aufnahmezeitpunkt ausgewählt werden.
      <div style="height:16px"></div>
      <img src="${sommersturm2017Image}" alt="plant reflection" style="max-width:100%"/>
    <div style="font-size:12px">[Grafik aus der PPT 2. Workshop]</div>
    <div style="height:24px"></div>
    Das folgende Video gibt Hinweise zur Benutzung der <a href="https://forestmonitoring.lab.karten-werk.ch/stoerungen">
    Hinweiskarte für Sommersturmschäden im Jahr 2017 im Kartenviewer:</a>:
    <div style="height:16px"></div>
    ${getVideoElement("aamvbhKXoNU")}
    <div style="height:16px"></div>
    <u>Hintergrundinformationen zur Methode</u><br /><br />
    
    Der NBR wird häufig für die Erkennung von Waldbrandflächen verwendet, eignet sich aber auch für 
    die Detektion von flächigen Veränderungen aufgrund von natürlichen Störungen.<br /><br />

    Für jede Sentinel-2 Aufnahme innerhalb der definierten Zeitspanne (5.7.- 19.8.2017) wurde zuerst der 
    NBR berechnet (<strong>NBR<sub>Aktuell</sub></strong>). Wolken wurden dabei mittels der <a href="https://sentinel.esa.int/web/sentinel/technical-guides/sentinel-2-msi/level-1c/cloud-masks">ESA Wolkenmaske</a> ausgeschieden. 
    Daraufhin wurde der NBR für die Referenzperiode berechnet, welche als das 45-Tages-Fenster vor 
    dem aktuellen Aufnahmedatum definiert wurde. Zu diesem Zweck wurde zuerst mittels der in Kapitel 4 
    beschriebenen NDVI Maximum Composite Methode aus allen verfügbaren Aufnahmen innerhalb der 45-tägigen 
    Zeitspanne ein möglichst wolkenfreies Komposit erstellt. Für dieses wurde dann wiederum der NBR berechnet 
    (<strong>NBR<sub>Referenz</sub></strong>). Aus diesen beiden Bildern wurde daraufhin die Differenz gebildet (<strong>∆NBR</strong>), und die 
    Veränderungsflächen wurden mittels Schwellenwert ausgeschieden. 
    <div style="height:16px"></div>
    <img src="${nbrDiff}" alt="plant reflection" style="max-width:100%"/>
    <div style="font-size:12px">[Grafik aus der PPT 2. Workshop]</div>
    <div style="height:24px"></div>
    Dieser Workflow erfolgte wie beschrieben zunächst testweise für den Sommer 2017, 
    jedoch ist die automatisierte Bereitstellung der Veränderungsflächen für die ganze Schweiz 
    möglich und angedacht. Dabei würden die Informationen für alle verfügbaren Aufnahmen innerhalb 
    der letzten 45 Tage ab dem jeweils aktuellen Datum mittels sogenannten «rollenden Archiven» zur 
    Verfügung gestellt werden. <strong>Die vollautomatische Analyse und Bereitstellung der Resultate sollte 
    innerhalb von 1-2 Tagen nach Bildaufnahme</strong> möglich sein.<br /><br />

    Eine anspruchsvolle Situation stellt sich jedoch im Winter: Vegetationszustand, Beleuchtungsintensität, 
    Wolken, Schatten und Schnee stellen zusätzliche Herausforderungen dar. Ein möglicher Lösungsansatz 
    wäre eine Kombination mit Sentinel-1 Daten, welche von Bewölkungs- und Beleuchtungsintensität nicht beeinflusst werden.
    <div style="height:24px"></div>`
    },
    {
      title: "6	Use Case 3 - Hinweiskarte zur Vitalität",
      content: `Auch die Vitalität von Waldflächen kann mit Sentinel-2-Satellitenbildern grob erfasst werden. 
      Durch den <strong>Vergleich des aktuellen Vegetationszustandes mit den Vorjahren</strong> lassen sich daraus <strong>Hinweiskarten 
      zur Veränderung der Vitalität</strong> erstellen. <br />
      Als Indikator für die Vitalität wurde wiederum der NDVI-Vegetationsindex verwendet (siehe Kapitel 2). 
      Auf der Karte dargestellt werden sogenannte standardisierte <strong>NDVI-Anomalien</strong>. Dabei werden jeweils zweimonatige 
      Mittelwerte zu Mittelwerten derselben Zeitperiode (z.B. Juni – Juli) der verfügbaren Vorjahre in Beziehung gesetzt. 
      Negative Werte deuten auf eine Abnahme der Vitalität hin, positive Werte deuten auf eine Zunahme der Vitalität hin. 
      Je weiter die Werte von Null abweichen, desto wahrscheinlicher ist es, dass eine effektive Veränderung stattfand.<br />
      Ob es sich bei der Veränderung um Borkenkäferbefall, Trockenstress oder einen Holzschlag handelt, 
      wird hierbei nicht unterschieden. So können z.B. negative Werte sowohl einen Holzschlag wie auch eine vorzeitige 
      Herbstverfärbung beschreiben. Wir sprechen daher von Hinweiskarten und für die Interpretation ist immer auch 
      Expertenwissen über die Wälder und gegebenenfalls eine Feldbegehung notwendig. Durch die Kombination von 
      Satellitenaufnahmen innerhalb des zweimonatigen Fensters können viele Probleme mit Wolken und andere Fehlerquellen 
      reduziert, jedoch nicht vollständig ausgeschlossen werden. <br />
      Weiter ist zu berücksichtigen, dass die Sentinel-2-Daten erst seit 2015 verfügbar sind, 
      was für die Detektion von Anomalien bis jetzt ein relativ kurzer Zeitraum ist.
      <div style="height:24px"></div>
      Das folgende Video gibt Hinweise zur Benutzung der <a href="https://forestmonitoring.lab.karten-werk.ch/vitalitaet">
      Hinweiskarten zur Vitalität im Kartenviewer:</a>
      <div style="height:16px"></div>
      ${getVideoElement("wraBOBSfcdk")}
      <div style="height:16px"></div>
      <u>Hintergrundinformationen zur Methode</u><br /><br />
      Für die Berechnung der NDVI-Anomalien wurde der sogenannte standardisierte Z-Score verwendet 
      (siehe z.B. Meroni et al., 2019):<br /><br />

      Z<sub>i</sub> = (NDVI<sub>median,i</sub> - NDVI<sub>median,ref</sub>) / NDVI<sub>sd,ref</sub>
      <div style="height:16px"></div>
      Im Gegensatz zu Meroni et al. haben wir den Median anstatt dem arithmetischen Mittel verwendet, 
      da dieser robuster gegenüber Ausreissern ist. NDVI<sub>median,i</sub> bezeichnet somit den Median der NDVI-Werte 
      pro <strong>zweimonatigem Zeitfenster</strong> i. NDVI<sub>median,ref</sub> bezeichnet den Median der NDVI-Werte innerhalb der 
      <strong>gleichen</strong> zweimonatigen Zeitfenster (z.B. Juni - Juli) aller Vorjahre bis 2015. NDVIsd,ref ist die 
      Standardabweichung aller NDVI-Werte innerhalb der gleichen zweimonatigen Zeitfenster (z.B. Juni- Juli) 
      aller Vorjahre bis 2015. Die Berechnung erfolgt pixelbasiert für jedes 10x10m Pixel, und die Pixelwerte 
      in den Vitalitäts-Hinweiskarten entsprechen dem jeweiligen Z-Score Wert.<br /><br />

      Die Anomalien sind "normalisierte" Anomalien in dem Sinne, dass der Datenpunkt mit einem <a href="https://de.wikipedia.org/wiki/Streuungsma%C3%9F_(Statistik)">Streuungsmass</a>
      der beobachteten Verteilung verglichen wird, und nicht nur mit einem Lagemass. Auf diese Weise können NDVI-Beobachtungen 
      an verschiedenen Orten und zu verschiedenen Zeitpunkten dahingehend verglichen werden, wie «extrem» sie sind.
      <div style="height:16px"></div>
      <img src="${ndviAnomalienImage}" alt="ndvi anomalien" style="max-width:100%"/>
      <div style="font-size:12px">[Grafik abgewandelt saus der PPT 2. Workshop]</div>
      <div style="height:24px"></div>`
    }
  ]
};

export default descriptionContent;
