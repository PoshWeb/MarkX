## MarkX 0.1.4

* MarkX now handles multiple files (#57)
* MarkX is now an eponym (#55)
* MarkX now supports MDX (#59)
* MarkX now supports Astro (#64)
* Extended Type Improvements
  * `MarkX.CrossReference` cross references (#80)  
  * `MarkX.Date` (#58)
  * `MarkX.Find` finds content in Markdown (#76)  
  * `MarkX.Replace` replaces content in Markdown (#77)  
  * `MarkX.FindCodeBlock` finds code blocks (#78)
  * `MarkX.FindHyperlink` finds hyperlinks in markdown (#47)
  * `MarkX.FindReference` finds code references (#79)
  * `MarkX.get_Content` (#53)
  * `MarkX.get_Content` gets markdown content (front matter + markdown) (#53)
  * `MarkX.get_DataPath` gets the path to external front matter (#84)
  * `MarkX.get_DataUrl` gets markdown embedded in a data url (#74)
  * `MarkX.get_JavaScript` (#61)  
  * `MarkX.get_JavaScriptKeywordPattern` matches javascript keywords (#70)
  * `MarkX.get_JSON` gets markdown as [Markpub](https://markpub.at) json (#75)
  * `MarkX.get_Liquid` now matches content (#54)
  * `MarkX.get_Markdown ContentType` gets ideal content types (#66)
  * `MarkX.get_MarkdownExtension` gets markdown extensions (#65)
  * `MarkX.get_Markpub` (#49)
  * `MarkX.get_Path` gets markdown path (#51)
  * `MarkX.get_StartPattern` matches the first heading, element, or block (#68)
  * `MarkX.get_SVG` gets markdown embedded in an SVG (#73)
  * `MarkX.get/set_FrontMatter` gets/sets Markdown front matter (#63)
  * `MarkX.HTML` fault tolerance (#52)
  * `MarkX.HTML` javascript support (#62)
  * `MarkX.Layout` gets or sets layout script or layout front matter (#72)
  * `MarkX.Page` gets markdown as a page (#71)
  * `MarkX.Save` saves markdown content (#67)
  * `MarkX.TableOfContents` gets a table of contents (#83)
  * `MarkX.Tags` (#41)
  * `MarkX.Title` (#60)
* Fixes:
  * `MarkX` no longer misses markdown when provided with headers (#50)
  * `MarkX.set_YamlHeader` tolerates `powershell-yaml` parameter difficulties (#69)
  * `MarkX` uses MarkDig's Advanced Extensions for better compatibility with `ConvertFrom-Markdown` (#81)
  * `MarkX` uses plural aliasing (#82)
* Demo now in `README.md.ps1` (#56)

---

## MarkX 0.1.3

* Property Improvement:
  * Late binding MarkX.DataSet (#44)
* New Properties:
  * MarkX.Liquid ( #45 )
  * MarkX.LiquidPattern ( #46 )

---

## MarkX 0.1.2

Minor performance improvements:

* Directly using Markdig (#38)
* Preferring `[IO.File]::Exists` (#42)

---

## MarkX 0.1.1

* MarkX Help (#26)
* MarkX now accepts commands / help (#27)
* MarkX.Headings gets heading elements (#29)
* MarkX.Lexicon gets lexicons in Markdown (#25)
* MarkX.YamlHeader support (#32, #33)
* Allowing piped markdown file input (#34)
* MarkX.Code gets code within markdown (#30)
* MarkX.CodeBlock gets code blocks within markdown (#31)
* MarkX.ToString can now stringify any property (#35)
* MarkX formatting (#36)

---

## MarkX 0.1

* `Get-MarkX` ( #1, #4 )
* Docs
  * Sponsorship ( #20 )
  * Security ( #19 )
  * Contributing ( #18 )
  * Code of conduct ( #17 )
  * README (generated with MarkX) (#16)
* Extended Types
  * `MarkX.get_HTML` ( #14 )
  * `MarkX.ToString()` ( #12 )
  * `MarkX.get_DataSet` ( #13 )
  * `MarkX.get_Images` (#11)
  * `MarkX.get_Links` (#10)
  * `MarkX.get_Table` ( #9 )
  * `MarkX.get_InnerText` ( #8 )
  * `MarkX.get_XML` ( #7 )
  * `MarkX.get/set_Markdown` ( #6 )
  * `MarkX.Sync` ( #5 )
  * `MarkX.ToTable` ( #22 )
* MarkX build ( #2, #3 )
* MarkX Action ( #21 )
* MarkX Tests ( #15 )