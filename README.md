# Einkommenssteuer Deutschland
Tabellen und R-Scripte zur Einkommenssteuer in Deutschland

# Zweck

Die R-Scripte stellen verschiedene Aspekte der **Einkommenssteuer** im Deutschland grafisch oder tabellarisch dar.

Ziel ist nicht die exakte Berechnung des zu zahlenden **Steuerbetrages** gem. [Einkommenssteuergesetz (EStG)](https://www.gesetze-im-internet.de/estg/), sondern eine gute grafische Darstellung ohne störende Sprünge und ein ***Vergleich der Steuertarife*** über die Jahre hinweg.


# Quelle der Daten für die Steuertabellen

Die Werte für die Steuertabellen und die Formeln stammen von [WikiPedia: Tarifgeschichte der Einkommensteuer in Deutschland](https://de.wikipedia.org/wiki/Tarifgeschichte_der_Einkommensteuer_in_Deutschland), die wiederum den verschiedenen Fassungen des ***EStG*** entnommen sind. Die Daten wurden nicht auf Übernahmefehler geprüft.

## 2000 bis heute

Die Einkommenssteuer kennt zur Zeit fünf **Tarifzonen** (bis einschließlich 2006 nur vier siehe untern). Die Tarifzonen werden mit 0 beginnend nummeriert. Die Tarifzone 0 hat als unteren **Eckwert** 0 Euro und als oberen Eckwert den **Grundfreibetrag**, bis zu dem keine Steuern gezahlt werden. Der Steuersatz ist somit 0 %.

Bei den Tarifzonen ist zwischen **progressiv** steigenden Steuersätzen und **proportionalen** Steuersätzen zu unterscheiden. Bei Zonen mit progressiv steigenden Steuersätzen steigt der Steuersatz linear mit dem zu versteuernden Einkommen vom unteren Steuersatz bis zum Steuersatz der nächsten Zone. Es gibt zwei progressive Tarifzonen (Tarifzone 1 und 2). Die anderen sind proportional, was in der Tarifzone 0 trivial ist.

Die **Parameter p** und der **Steuerbetrag bei unterem Eckwert** jeder Tarifzone werden aus den Eckwerten und dem Steuersatz berechnet. Im ***EStG*** wird der Parameter p mit 10<sup>8</sup> multipliziert und auf 2 Stellen hinter dem Komma gerundet. Zum Ausgreich wird der das versteuernde Einkommen durch 10.000 geteilt. Da es in den Formeln mit sich selbst mumitpliziert wird, ergibt sich ein Faktor voon 10<sup>8</sup>. In den Tabellen wird ohne Rundung und ohne diesen Faktor gespeichert.

Der Steuerbetrag bei unterem Eckwert wird seit etwa 2015 auf Cent gerundet (davor auf €) (Kleine Abweichungen in den Tarifzonen).

Weil der **Parameter p** anders als im ***EStG §32a*** nicht gerundet wird, können sich kleinere Abweichungen im Ergebnis zu Formeln mit gerundeten Parametern gemäß ***EStG*** ergeben. Dies hat in der grafischen Darstellung jedoch den Vorteil, dass es keine optisch störenden Sprünge gibt.

Der Steuerbetrag und das zu versteuernde Einkommen werden nicht wie im Gesetz auf ganze Euro abgerundet, sondern aus ganze Cent oder in Zwischenrechnungen nocht gerundet. Wobei alle Grafiken auf Stützwerte mit ganzen Euros beruhen.

Die Steuerformel in einer Tarifzone lautet:

**( p * ( zvE - unterer Eckwert )  + Steuersatz ) *  ( zvE - unterer Eckwert ) + Steuerbetrag bei unterem Eckwert**

Für die ***Tarifzonen 0, 3 und 4** ist in dieser Formel ***p = 0***, weil sie nicht progressiv sind.

Abgesehen von den Rundungsunterschieden ist die hier verwendete Formel zu den Berechnungsvorschriften des ***EStG §32a*** gleichwertig und Funktioniert mit den Eckwerten und Steuersätzen ab 2000.

## 2000 bis 2006 - Vier Tarifzonen

Von 2000 bis 2006 gab es nur vier Tarifzonen. Um dies in einheitlich in einer Eckwertetabelle abbilden zu können, wurde für die Zeit 2002 bis 2006 eine 'virtuelle' Tarifzone eingeführt, die ab 500.000 € begint und den gleichen Steuersatz wie die vierte Tarifzone hat.

### 2000 und 2001 - Deutsche Mark

In den Jahren 2000 und 2001 wurde die Steuer in Deutsche Mark (DM) berechnet. Um diese Zeit mit in die Berechnung aufzunehmen wurden die DM-Beträge in Euro umgerechnet und auf ganze Euro gerundet.

