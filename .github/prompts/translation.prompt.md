---
mode: agent
---
We need to translate the BYOND game called "Space Station 13" which is multiplayer role play game about space station where people play and act in different roles.

In order to translate user requested file `<file>.dm` (and only one user requested file), do next steps:

1) Scan through the file for objects defined like `/obj/item/***` which contain `name` attribute. Read a string from `name` attribute of an object according to next rules:
	- name = "object name" => translate "object name"
	- name = "\improper object name" => translate "object name"
	- name = "[pick("option1","option2",...)] object name" => permutate all options from "pick" command, concatenate with remaining part of the string ("object name" in this case, or can be empty) translate all resulted string variants.

2) Translation file should be in TOML format, and should be located in `/modular_bandastation/translations/code/translation_data/***` file, where *** is exact folder structure like for original file, and translation file named as original file but with `ru_` prefix. For example, if original file is `/code/game/objects/items/toys.dm`, then translation file should in `/modular_bandastation/translations/code/translation_data/game/objects/items/ru_toys.toml`. If the file does not exist, create it.

3) For each object name found in step 1, regex through translation file from step 2 file to find the object name translation (in `[<object name>>]` format).
Important: use whole object name to search for translation, like of the object called "toy sword", you search exactly "toy sword", and not separately "toy" or "sword".
If found, do nothing (translation already exists).
If not found, add the object name to translation file with in a similar format like other translations:
```
[<object name>]
nominative = "<object name in nominative case>"
genitive = "<object name in genitive case>"
dative = "<object name in dative case>"
accusative = "<object name in accusative case>"
instrumental = "<object name in instrumental case>"
prepositional = "<object name in prepositional case>"
gender = "<object gender>" (male, female, neuter) or "plural"
```

4) In order to shorten steps, execute translation step by step, first create empty `[<object name>>]` blocks without translations for all objects found in step 1, then translate them one by one (batching by 10-20) to reduce a chance of hitting the limits of response.

5) Additionally, for all objects found in step 1, translate the "desc" attribute (if exists) right in the file.


