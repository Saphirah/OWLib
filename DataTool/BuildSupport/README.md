# Overwatch build 154504

This fork compiles the CMF and TRG manifest providers for Overwatch
`2.25.0.1.154504` directly into DataTool. TACTLib discovers providers in loaded
assemblies through `ManifestCryptoAttribute`; no launcher or fallback is needed.
Existing providers remain available for other supported builds.

## Warum gab es einen Kompatibilitaets-Launcher?

Der Launcher ist ein kleines Startprogramm fuer die bereits heruntergeladenen
offiziellen DataTool-Dateien. Er stellt zwei zusaetzliche Routinen bereit, mit
denen DataTool die Inhaltsverzeichnisse (CMF) und Ressourcenverknuepfungen (TRG)
von Spielbuild 154504 lesen kann. Danach startet er das normale DataTool.
TACTLib erkennt diese Routinen automatisch in den geladenen Assemblies.
Dadurch war kein Neubau der offiziellen Binaerdateien erforderlich.

Wir koennen den Code direkt aendern; genau das macht dieser Fork jetzt.
Die beiden Routinen werden direkt in DataTool eingebaut und beim normalen
Programmstart erkannt. Fuer ein neu gebautes DataTool aus diesem Fork entfaellt
der separate Launcher. Die bisherige lokale Installation und ihre Exportskripte
verwenden weiterhin den vorhandenen Launcher, bis sie auf den Neubau umgestellt
werden. Ein Git-Push allein ersetzt keine bereits installierten Programme.

## Source and license

The two provider files come from [TACTLib PR #40](https://github.com/overtools/TACTLib/pull/40)
by sandsand244263, commit `9b333b84211a4b95928e01be303b5ed27729c0aa`.
Only trailing whitespace has been removed. The original MIT license is included
in `TACTLib-LICENSE.txt`. The PR was closed without merging; this is fork-specific
support, not an upstream release.

The TRG IV package-count term was inferred by the original contributor and
validated against client manifests. Support is specific to this build and does
not promise compatibility with later patches.

## Build and verify on Windows

Install the .NET 10 SDK, then run from the repository root:

```powershell
git submodule update --init --recursive
dotnet build DataTool/DataTool.csproj -c Release
./scripts/Test-Build154504.ps1 -DataToolPath ./DataTool/bin/Release/net10.0/DataTool.exe -OverwatchPath 'C:/Games/Overwatch'
```

The integration check requires a local game installation and checks for a
nonempty map catalog containing Dorado. It fails with the unmodified official
v2.25.0.0+1151 release because build 154504 has no provider there.

GitHub's source ZIP omits submodule contents. Clone recursively to build:

```powershell
git clone --recursive https://github.com/Saphirah/OWLib.git
```

## Validation (2026-11-01)

- Release build with .NET SDK 10.0.403: successful, 0 errors.
- Official DataTool v2.25.0.0+1151: integration check fails with unsupported build 154504.
- This fork: integration check passes, 305 map headers including Dorado.
- The existing TankLib test `TestGetPayloadGUID` fails with `EndOfStreamException`
  while reading its texture fixture. TankLib, its tests, and both submodule
  revisions are unchanged from upstream; that test project does not reference
  DataTool or the new providers.
- The upstream build also reports compiler warnings and ImageSharp 3.1.12
  NuGet vulnerability advisories. These dependencies are unchanged here.
