# Sources, what each confirmed, and discrepancies

## Sources used

1. **Joseph H. Peterson, *John Dee's Five Books of Mystery* (Weiser, 2003)**, full OCR text on archive.org:
   https://archive.org/stream/JohnDeesFiveBooksOfMysterJosephH.Peterson/John-Dees-Five-Books-of-Myster-Joseph-H.-Peterson_djvu.txt
   Confirmed: the full dialogue of Liber II (the 40 letters with their numbers and over/under positions; Michael's reading rule; the seven ring names and Michael's reordering; the seven birds and the 7×7 table; Zaphkiel…Gabriel; the pillars; Daughters and Sons; the Zabathiel reading rule; the placement instructions for the heptagon, pentagram and Levanael cross). Liber I, 10 March 1582: wax, 9 in diameter, 27 in circumference, 1⅛ in thick, cross on the back. Editorial note: Dee's Heptarchia Mystica dates the 40-letter session to **19 March** 1582. Peterson notes that the wax seal in the British Museum differs from Sloane 3188. The OCR is noisy (e.g. "Horlcon" for Horlωn, "V" for o at cell 36), so it was cross-checked against source 2.
2. **Clay Holden, John Dee Publication Project, *Mysteriorum Liber Secundus*** (transcription of Sloane 3188 with Dee's marginalia, © 1996):
   http://www.john-dee.org/Secundus.pdf
   Confirmed the same dialogue in cleaner text, plus Dee's margin notes: the 20 for cell 9 ("Corrected thus after, by Uriel … to be 20"); "o, and 17 under it" at cell 36; "Uriel also did correct this place" for the second 'a 5'. Also the full second table with its numbers and pricks (SAAI 21/8 EME 8. … IHRLAA 21/8.), Uriel's notes on the 30 and the 26, and the small Levanael figure (VA / LE NA / el).
3. **Peterson's redrawing of the seal**, esotericarchives.com: https://www.esotericarchives.com/dee/aemethd.jpg (contents page: https://www.esotericarchives.com/dee/sl3188.htm, which also gives the session list and dates).
   Confirmed: the final drawn values of all 40 cells; the orientation (heptagon vertex up, the T cell starting at 12 o'clock, lettering tops outward); the placement of every inner name.
4. **Sloane MS 3188 f.30r photo** (Wikimedia Commons, PD): https://commons.wikimedia.org/wiki/File:Sloane3188-john_dee.png
   Confirmed: the overall layout and orientation agree with Peterson's redrawing (DEIMO30A upside-down at the bottom, XE 21 at the bottom of the ring, IHRLAA at the upper left, and so on). Too low-resolution for single numbers.
5. **David Richard Jones, "In Operibus Sigillo Dei Aemeth"**, Hermetic Library (read through archive.org snapshots of hermetic.com, because the live site blocks scripts):
   - https://hermetic.com/jones/in-operibus-sigillo-dei-aemeth/the-circumference: the 40-cell list, 9° cells, a number sum of 440, T at the top.
   - https://hermetic.com/jones/in-operibus-sigillo-dei-aemeth/the-thrones-the-names-drawn-from-the-circumference-of-the-sigillum: derivations of the seven names, the double-'a' rule, and the remark that the drawn seal differs from the Action at y15 and at A666.
   - https://hermetic.com/jones/in-operibus-sigillo-dei-aemeth/galethog: the seven sigils are set counter-clockwise from the top.
   - https://hermetic.com/jones/in-operibus-sigillo-dei-aemeth/introduction-and-parts: Daughters in the angles, Sons in the lines, Daughters of the daughters and Sons of the sons on the two heptagons. This is a modern interpretive essay; I used it only for cross-checking.
6. **Wikipedia, "Sigillum Dei"**: https://en.wikipedia.org/wiki/Sigillum_Dei. Confirmed only the general background: Dee received his version in 1582 through Kelley, and the medieval Liber Juratus version is different (72-letter ring, Hebrew-derived archangels). Most of the article describes the Liber Juratus type, not Dee's.
7. **Wikimedia Commons file pages** for licences (see images.md). The British Museum's own collection page (https://www.britishmuseum.org/collection/object/H_1838-1232-90-a) returned 403, so the museum's catalogue text is **unverified** here.

## My own checks (computed, see seal.json)

- I applied Michael's rule to the 40 cells: all seven names (Thaoth, Galas, Gethog, Horlωn, Innon, Aaoth, Galethog) come out exactly.
- Reading table 1 down its columns gives Zaphkiel … Gabriel, followed by '+'.
- Diagonals of table 2 give all 7 Daughters, 7 Sons, 7 Daughters of daughters and 7 Sons of sons exactly.
- Read anti-diagonal by anti-diagonal as one stream, table 2 gives Zabathiel, Zedekieil, Madimiel, Semeliel, Nogahel, Corabiel and Levanael, using all 49 cells once. Only Zabathiel's path is stated in the text; the rest is my reconstruction (flagged).

## Discrepancies and choices

| Item | Versions | Chosen |
|---|---|---|
| Ring cell 22 (y) | Dictated "15 under" (Peterson OCR, Holden; Holden's printed seal also shows 15). Peterson's redrawing shows **14** below. Jones says the drawn seal differs from the Action here. | 14, marked `unverified`. Check a high-res MS image if possible. |
| Ring cell 9 (a) | Dictated 22. Dee's margin note: corrected by Uriel to 20. | 20 |
| Ring cell 20 (H) | Dictated "under it 22". The drawn seal has 12 below. | 12 below. Horlωn only works with this, and Dee records that Uriel corrected the numbers "for quantity and … place over or under". |
| Ring cell 30 (r) | Dictated "16 over". The drawn seal has 16 below. | below (needed for Horlωn) |
| Ring cell 32 (A) | First "666 in triangle"; Michael rubbed out the two lower 6s. | 6 above |
| Ring cell 36 | Peterson OCR "V"; Holden "o". | o 17 below |
| Ring cell 38 | Two 'a 5' figures were dictated; Uriel's correction replaced the first. | one 'a 5 below' |
| Ring cell 40 (ω) | Revealed last, on a trumpet. The text does not clearly state its number. The drawing shows 6 above. | 6 above, `unverified` (Horlωn requires it) |
| Ring cell 13 (o 18) | Text: "18 over". Jones's table notation suggests "under", but his own derivation treats it as over. Peterson's drawing: over. | above |
| Zabathiel | Table corner = S; Uriel and the drawing use Z. | Z in the drawing; S noted |
| Name of God, row 1 | Many modern redrawings: "SAAIEME" without numbers. Dee: SAAI(21/8)EME(8.) | Dee's version |
| Session date of the 40 letters | Peterson's contents page: "Mar 1582 (date uncertain)". Dee's Heptarchia Mystica extract: 19 March. | 19 March 1582, with the caveat noted |
| Wax seal (British Museum) vs Sloane 3188 | Peterson: they differ (details not listed). | Followed Sloane 3188. Wax-seal differences are unverified. |
| Shape of the back cross | Instructed 10 March 1582; shape only in a small MS drawing. | Not specified (`backCross_unverified`) |
| Small padding crosses in the name bands | Present in the drawings; number and positions not given in the text. | Marked `crosses_unverified` |
