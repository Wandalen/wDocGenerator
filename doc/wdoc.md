## Concepts

- `markdown` - markup langugage.
- `docsify` - app that renders html pages from `markdown` on the fly. [ Docsify ]( https://github.com/docsifyjs/docsify/ ).
- `jsdoc` - markup language used to document javascript code. [ JsDoc ]( http://usejsdoc.org/ ).
- `tutorial` - document that explains how to complete certain task.
- `concept` - document that explains the basic ideas of the technology.

## Parallel processes
Docs generation consists of such independent processes:

### Generation of the reference.
It's a generation of `markdown` files from `jsdoc` annotated source code.

In: Path to directory with `*.js`, `*.s`, `*.ss` files

Out:
- `*.md` files located at `outPath/Reference`, each of which represents single entity( module, class, namespace ).
- Reference index generated at `outPath/ReferenceIndex.md`

Command : `wdoc .generate.reference sourcesPath`

### Preparation of the `docsify` app.

Built docsify app is copied into root of `outPath` directory.

Command : `wdoc .generate.docsify outPath`

### Preparation of the `tutorials`.

Aggregates tutorials and creates index file.

>If subdir has README.md file its treated like index file, otherwise generates index bases on *.md files from that dir.

In: Path to the directory with `*.md` files of the tutorials.

Out:
- Tutorials copied into path `outPath/Tutorials`.
- Tutorials index file generated at `outPath/TutorialsIndex.md`

Command : `wdoc .generate.tutorials tutorialsPath`

### Preparation of the `concepts`.

Aggregates concepts and creates index file.

>If subdir has README.md file its treated like index file, otherwise generates index bases on *.md files from that dir.

In: Path to the directory with `*.md` files of the concepts.

Out:
- Concepts are copied into path `outPath/Concepts`.
- Index file generated at `outPath/ConceptsIndex.md`

Command : `wdoc .generate.concepts conceptsPath`

## List of output files and directories

Default output path `outPath` : `out/doc`.
Folders structure :

```
•
├── Reference
│   ├── module # docs for modules
│   ├── class  # docs for classes
│   └── namespace # docs for namespaces
├── Tutorials
├── Concepts
├── ReferenceIndex.md
├── TutorialsIndex.md
├── ConceptsIndex.md
├── server.ss # server for docsify app
├── vendor # docsify app
└── index.html # main page of docsify app
```

## How to build the doc:

List of options and defaults:

```
sourcesPath : 'proto',
conceptsPath : 'doc/concepts',
tutorialsPath : 'doc/tutorial',

outPath : 'out/doc',

docsify : 1, # controls docsify app preparation
includingConcepts : 1,  # controls including of concepts
includingTutorials : 1  # controls including of tutorials

willModulePath : '.' # path to will module, is used in pair with `useWillForManuals` option
useWillForManuals : 0 # controls including of tutorials/concepts from submodules of provided will module, ignores `conceptsPath` and `tutorialsPath` if enabled

```

List of commands:

`wdoc .help`

`wdoc .generate sourcePath` - runs all processes of doc generatior

`wdoc .generate.docsify outPath` - runs preparation of the docsify app

`wdoc .generate.reference sourcesPath` - runs generation of the reference

`wdoc .generate.tutorials tutorialsPath` - runs preparation of the tutorials

`wdoc .generate.concepts conceptsPath` - runs preparation of the concepts

Custom options:

Example#1 - custom `outPath`:

`wdoc .generate sourcePath outPath : some/path`

Example#2 - disable including of tutorials and concepts:

`wdoc .generate sourcePath includingConcepts : 0 includingTutorials : 0`

Example#3 - custom path for tutorials :

`wdoc .generate sourcePath tutorialsPath : path/to/tutorials`

Example#4 - include tutorials from submodules using will config :

`wdoc .generate.tutorials useWillForManuals : 1 willModulePath : path/to/some/module`





