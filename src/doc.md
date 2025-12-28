# Documentation Huitr

## Présentation générale

Huitr est un langage fonctionnel *extrémiste*. Il y a en gros 2 syntaxes en
dehors des littéraux&nbsp;:
* Définir une fonction&nbsp;;
* Appeler une fonction.

En outre, il n’y a aucune opération relevant du sucre syntaxique, telle que `+`
ou encore `&&`, il faudra donc utiliser des fonctions bien choisies de la STD
(~~sexually transmitted disease~~ bibliothèque standard).

Huitr signifie HUitr Is Tough to Read.

Cette documentation présente tout d’abord les éléments de syntaxes basiques,
puis liste les fonctions disponibles dans la STD.

## Syntaxe

Un programme Huitr est constitué de plusieurs lignes, séparées par des
retour-lignes ou des point-virgules (en particulier, **les retour-lignes sont
significatifs**).

### Commentaires
* Si un `.` apparaît sur une ligne (en-dehors d’un flottant ou d’une chaîne),
  le reste de la ligne (i.e. jusqu’au retour-ligne suivant) est ignoré.
  *Exemple&nbsp;: `code . commentaire`.*
* Tout ce qui se trouve entre deux `..` est ignoré (y compris les retour-ligne).
  *Exemple&nbsp;: `code .. commentaire .. code`.*

### Littéraux
* Littéral d’entier. Exemples&nbsp;: `0`, `3`, `-1`, `0x3D`, `0B01001`, `0o14`.
* Littéral de flottant. Exemples&nbsp;: `0.0`, `3.1415`, `-6e12`, `4e-3`.
* Littéral de chaîne de caractères. Exemples&nbsp; : `""`, `"Hello, world!"`.
  *Les littéraux de chaîne supportent les caractères d’échappement `\n`
  (retour-ligne), `\t` (tabulation), `\b` (retour arrière) et `\r`
  (retour-charriot)*
* Littéral de chaîne multi-lignes. Exemple&nbsp;:
  ```huitr
  """Du texte
  sur plusieurs
  lignes."""
  ```
  *Attention, les guillemets seuls doivent être échappés.*
* Littéral «&nbsp;unit&nbsp;»&nbsp;: `()`. (correspond au `None` en Python)

*Note pour les chaînes de caractères&nbsp;: un support basique des lettres
accentées utilisées en français est présent mais une limitation technique
empêche d’inclure tous les caractères UNICODE. Les caractères supportés sont
les caractères affichables de la table ASCII, auquels sont ajoutés à, â, ç, é,
è, ê, ë, î, ï, ô, ö, ù, û, ü, ÿ, æ, œ, À, Â, Ç, É, È, Ê, Ë, Î, Ï, Ô, Ö, Ù, Û,
Ü, Ÿ, Æ, Œ, ’ (apostrophe courbe), l’espace insécable et l’espace fine
insécable.*

### Constantes
En Huitr, il n’y a pas de variables mais uniquement des constantes.
Pour déclarer une constante, il suffit d’utiliser la syntaxe
`... > nom_de_la_constante`. Le nom est constitué de caractères ASCII
alphanumériques et de tirets du bas (le premier caractère du nom ne doit pas
être un nombre).

Une expression d’assignation renvoie la valeur de la constante.

### Listes
Il est possible de définir une liste en juxtaposant plusieurs valeurs séparées
par des virgules. Par exemple, `1, "chocolatine", 3.14` est une liste contenant
l’entier `1`, la chaîne `"chocolatine"` et le flottant `3.14`. Pour les listes
vides ou ne contenant qu’un seul élément, voir plus bas (`std::list`).
À noter&nbsp;: **on peut insérer un retour-ligne après une virgule**.

Pour faire des listes dans des expressions plus complexes, il est possible de
mettre les listes entre parenthèses. En particulier, on peut faire des listes
de listes&nbsp;:
```huitr
(
  (1, 2, 3),
  ("hello", "world"),
  (4, 5, (6, 7))
)
```

Note&nbsp;: **on peut insérer un retour-ligne après une parenthèse ouvrante et
avant une parenthèse fermante**.

#### Exemple récapitulatif
```huitr
. ceci est un commentaire
1 > n  . maintenant, n vaut 1
"Hello, world!" > chaine
1, "hello", 5, 12 > liste
.. ceci est un commentaire qui tient sur plusieurs lignes
   super ! ..
```

### Déclarations de fonctions
Pour déclarer une fonction, il suffit de mettre du code entre crochets. La
valeur renvoyée est celle renvoyée par la dernière ligne. S’il n’y a rien
entre les crochets, la fonction renverra unit.
Il n’est pas nécessaire de préciser les paramètres de la fonction. Pour
récupérer les arguments, voir sous-section suivante.

Exemple&nbsp;: `[3 > n; n]` est une fonction renvoyant `3`.

### Appels de fonctions et chaînes
Pour appeler une fonction, on peut utiliser la même syntaxe que pour déclarer
une variable&nbsp;: `arg1, arg2, …, argn > fonction`. Cela appelle la fonction
`fonction` avec les arguments `arg1, …, argn`. Une fonction peut être appelée
sur 0 arguments. Pour récupérer les arguments, voir plus loin.

À noter&nbsp;: la priorité se fait de la gauche vers la droite. Par exemple,
`arg1, arg2 > fonction1, arg3, arg4 > fonction2, arg5 > fonction3` sera
interprété comme suit&nbsp;:
`((arg1, arg2 > fonction1), arg3, arg4 > fonction2), arg5 > fonction3`.

À noter&nbsp;: l’usage des parenthèses est possible pour modifier la priorité.
Attention cependant, `a, b > fonction` est différent de `(a, b) > fonction`.
En effet, dans le premier cas, la fonction est appelée avec deux arguments `a`
et `b`, et dans le deuxième cas elle est appelée avec un seul argument de type
liste contenant `a` et `b`.

Les constantes définies dans le corps d’une fonction ne sont plus accessibles
en-dehors de la fonction. À l’inverse, les constantes définies en-dehors du
corps d’une fonction sont accessibles par cette fonction (y compris celles
définies après la fonction). En outre, il est possible de faire des fonctions
récursives (`[foo > a] > a`) et mutuellement récursives
(`[foo > b] > a ; [bar > a] > b`).

**Important**&nbsp;: lisez *attentivement* la documentation de `std::test::if`
avant de vous lancer dans l’écriture de fonctions récursives&nbsp;!

Lors de l’appel d’une fonction, une liste `args` est définie dans le *scope* de
la fonction&nbsp;: elle contient la liste des arguments. Si aucun argument n’est
donné, la liste `args` est vide.
On pourra utiliser les fonctions de `std::list` sur `args` (cf. plus loin).

#### Exemple
Le code suivant définit une fonction `fact` qui calcule la factorielle de
l’entier passé en argument.
```huitr
[
    0, args > std::list::nth > n
    > (
        n, 0 > std::comp::eq,  . condition
        [1],  . si n = 0, on renvoie 1
        [  . sinon, on renvoie n * fact(n-1)
            n, 1 > std::math::minus > fact, n > std::math::prod
        ] > std::test::if
    )
] > fact
```

Note&nbsp;: **on peut insérer des retour-ligne après un crochet ouvrant et
avant un crochet fermant**.

## Bibliothèque standard

Voici la liste des modules et de leurs fonctions et constantes.

### `std::bool`
Ce module contient les constantes suivantes&nbsp;:
* `std::bool::true` : le booléen Vrai
* `std::bool::false` : le booléen Faux

Ce module contient les fonctions suivantes&nbsp;:
* `std::bool::and` prenant deux booléens `b1` et `b2` en entrée, et renvoyant
  la conjonction de `b1` et `b2`.
* `std::bool::not` prenant un booléen `b` en entrée, et renvoyant la négation
  de `b`.
* `std::bool::or` prenant deux booléens `b1` et `b2` en entrée, et renvoyant
  la disjonction de `b1` et `b2`.

### `std::comp`
Ce module contient les fonctions suivantes&nbsp;:
* `std::comp::eq` prenant deux valeurs en entrée et renvoyant un booléen
  indiquant si elles sont égales (en valeur, et non en mémoire). Les flottants
  et les entiers peuvent être comparés entre eux. Deux fonctions sont égales si
  elles contiennent les mêmes instructions (caractère pour caractère).
* `std::comp::ne` prenant deux valeurs en entrée et renvoyant un booléen
  indiquant si elles sont différentes. Note&nbsp;: `v1, v2 > std::comp::ne` est
  équivalent à `v1, v2 > std::comp::eq > std::bool::not`.
* `std::comp::le` prenant deux nombres (entiers ou flottants) `a` et `b` en
  entrée et renvoyant Vrai si `a` ⩽ `b` et Faux sinon.
* `std::comp::lt` : idem avec <.
* `std::comp::ge` : idem avec ⩾.
* `std::comp::gt` : idem avec >.

### `std::conv`
Ce module contient les fonctions suivantes&nbsp;:
* `std::conv::to_string` prenant en argument n’importe quelle valeur et
  renvoyant une chaîne de caractères la représentant. Par exemple,
  `(1, 2, 3) > std::string::to_string` renvoie `"(1, 2, 3)"`.
* `std::conv::to_int` prenant en argument une chaîne de caractère contenant un
  littéral d’entier et la convertissant en entier.
* `std::conv::to_float` prenant en argument une chaîne de caractère contenant un
  littéral de flottant et la convertissant en flottant.
* `std::conv::to_int_opt` faisant la même chose que `to_int` mais renvoyant
  `()` si la chaîne ne représente pas un littéral d’entier.
* `std::conv::to_float_opt` faisant la même chose que `to_float` mais
  renvoyant `()` si la chaîne ne représente pas un littéral de flottant.

### `std::io`
Ce module contient les fonctions suivantes&nbsp;:
* `std::io::print` prenant une valeur en entrée et l’affichant **avec retour
  ligne**. Renvoie la valeur donnée en entrée.
* `std::io::print_no_newline` faisant la même chose mais **sans retour ligne**.
  Renvoie également la valeur donnée en entrée.
* `std::io::input` affichant son entrée sans retour ligne et renvoyant une ligne
  lue dans l’entrée standard.
* `std::io::read` prenant en entrée une chaîne de caractère contenant un nom de
  fichier, puis renvoyant le contenu du fichier en question.

### `std::list`
Ce module contient la constante suivante&nbsp;:
* `std::list::empty` : la liste vide.

Ce module contient les fonctions suivantes&nbsp;:
* `std::list::nth` prenant une liste `l` et un entier `n` en entrée et renvoyant
  le `n`-ième élément de `l` (en commençant à 0).
  (*note&nbsp;: cette fonction est utile pour récupérer les arguments dans les
  fonctions&nbsp;: le premier argument pouvant être récupéré avec
  `args, 0 > std::list::nth`.*)
* `std::list::len` prenant une liste `l` en entrée et renvoyant sa longueur.
* `std::list::is_empty` prenant une liste `l` en entrée et renvoyant Vrai si
  elle est vide et Faux sinon (raccourci de
  `l > std::list::len, 0 > std::comp::eq` avec une meilleure complexité).
* `std::list::cons` (*cons*truire) prenant en entrée un élément `x` et une liste
  `l` et renvoyant une liste ayant comme premier élément `x` puis les éléments
  de la liste `l`. Par exemple,
  `3, (4, 2, 9.2, "chocolatine") > std::list::cons` vaut
  `3, 4, 2, 9.2, "chocolatine"`.
* `std::list::head` prenant une liste en entrée et renvoyant son premier
  élément. Plante si la liste est vide.
* `std::list::tail` prenant une liste en entrée et renvoyant une liste contenant
  tous ses éléments sauf le premier. Plante si la liste est vide.
* `std::list::map` prenant une fonction `f` et une liste
  `(elt1, elt2, ..., eltn)` en argument, et renvoyant la liste contenant
  `(elt1 > f, elt2 > f, ..., eltn > f)`.
* `std::list::filter` prenant une fonction `f` et une liste
  `(elt1, elt2, ..., eltn)` en argument, et renvoyant la liste contenant les
  `elti` pour lesquels `elti > f` a renvoyé `std::bool::true`. *Par exemple,
  si `x > f` ne renvoie vrai que si `x` est positif,
  `f, (9, 0.2, -4, -12, 0, 14) > std::list::filter` renvoie `(9, 0.2, 0, 14)`.*

Note&nbsp;: pour faire une liste contenant un seul élément `x`, il suffit de
faire `x, std::list::empty > std::list::cons`.

### `std::math`
Ce module contient les constantes suivantes&nbsp;:
* `std::math::tau` : `6.283185307179586` (π=τ/2).
* `std::math::e` : `2.71828182845904509`.

Ce module contient les fonctions suivantes&nbsp;:
* `std::math::add` prenant un nombre arbitraire de nombres (ou une liste de
  nombres) et renvoyant la somme des nombres. La somme d’une liste vide est 0.
* `std::math::prod` prenant un nombre arbitraire de nombres (ou une liste de
  nombres) et renvoyant le produit des nombres. Le produit d’une liste vide est
  1.
* `std::math::minus` prenant *exactement* deux nombres `a` et `b` en entrée
  et renvoyant `a-b`.
* `std::math::div` prenant deux nombres `a` et `b` en entrée et renvoyant
  `a/b`. Renvoie toujours un flottant. En cas de division par 0, renvoie `inf`.
* `std::math::floordiv` prenant deux entiers `a` et `b` et renvoyant le quotient
  de la division euclidienne de `a` par `b`. Renvoie un entier. Plante en cas de
  division par 0.
* `std::math::mod` prenant deux entiers `a` et `b` en entrée et renvoyant
  le reste de la division euclidienne de `a` par `b`. La sortie est toujours
  positive.
* `std::math::sqrt` prenant un nombre positif et renvoyant sa racine carrée
  (de type float).
* `std::math::loge` prenant un nombre strictement négatif et renvoyant son
  logarithme népérien (de type float).
* `std::math::log10` prenant un nombre strictement négatif et renvoyant son
  logarithme en base 10 (de type float).
* `std::math::log2` prenant un nombre strictement négatif et renvoyant son
  logarithme en base 2 (de type float).
* `std::math::exp` prenant un nombre et renvoyant son exponentielle base e
  (de type float).
* `std::math::sin` prenant un nombre et renvoyant son sinus (de type float).
* `std::math::cos` prenant un nombre et renvoyant son cosinus (de type float).
* `std::math::floor` prenant un nombre et renvoyant sa partie entière
  inférieure.
* `std::math::ceil` prenant un nombre et renvoyant sa partie entière
  supérieure.

### `std::string`
Ce module contient les fonctions suivantes&nbsp;:
* `std::string::nth` prenant une chaîne de caractères et un nombre `i` en
  entrée, et renvoyant le i-ième caractère de la chaîne (en commençant à 0).
* `std::string::len` prenant une chaîne en entrée et renvoyant sa longueur.
* `std::string::is_empty` renvoyant `true` si la chaîne donnée en entrée est
  vide, `false` sinon.
* `std::string::concat_strings` renvoyant la concaténation de toutes les chaînes
  données en argument.
* `std::string::split_on_char` prenant en arguments une chaîne de carcatères `s`
  et un caractère `c` (i.e. une chaîne de caractères de longueur 1) et renvoie
  une liste contenant les facteurs de `s` délimités par `c`. Par exemple,
  `"hello world", "o" > std::string::split_on_char` renvoie
  `"hell", " w", "rld"`. `"hello world", "." > std::string::split_on_char`
  renvoie `"hello world", std::list::empty > std::list::cons`.
  `"", "." > std::string::split_on_char` renvoie
  `"", std::list::empty > std::list::cons`.
* `std::string::sub` prenant en argument une chaîne de caractères `s`, un indice
  de début `i` et une longueur `l` et renvoyant le facteur de `s` commençant à
  l’indice `i` et ayant une longueur `l`. Par exemple
  `"abcd", 1, 2 > std::string::sub` renvoie `"bc"`.

### `std::test`
Ce module contient la fonction suivante&nbsp;:
* `std::test::if` prenant en argument un booléen, une valeur `v1` et une
  valeur `v2`. Si le booléen est vrai, renvoie `v1`, s’il est faux, renvoie
  `v2`. Par exemple, `true, 1, 0 > std::test::if` renvoie `1`, mais
  `false, 1, 0 > std::test::if` renvoie `0`.
  ***ATTENTION***&nbsp;: `v1` et `v2` sont évalués AVANT l’exécution du
  `if`. Si vous souhaitez les évaluer après (par exemple pour faire un appel
  récursif coûteux), `v1` et `v2` peuvent être des fonctions, et le
  résultat peut être appelé en-dehors du `if`. Par exemple&nbsp;:
  `> (condition, [3 > appel_tres_long], [4 > appel_tres_long] > std::test::if)`.
  Dans cet exemple, le `if` n’appelle rien&nbsp;: il renvoie une des deux
  fonctions en fonction de la condition, et la fonction renvoyée est appelée
  par le `> (...)`.

## Exemple
Des exemples d’utilisations des fonctions peuvent être consultés dans l’exemple
*fizzbuzz*, qui est accessible en revenant dans l’onglet
«&nbsp;Paramètres&nbsp;». Ce programme affiche tous les nombres de 1 à 100, et
remplace les multiples de 3 par «&nbsp;fizz&nbsp;», les multiples de 5 par
«&nbsp;buzz&nbsp;» et les multiples de 15 par «&nbsp;fizzbuzz&nbsp;».
