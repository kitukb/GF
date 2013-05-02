--# -path=.:../abstract:../common:../prelude

resource ResLav = ParamX ** open Prelude in {

flags
  optimize = all ;
  coding = utf8 ;

param
  -- Nouns
  Case = Nom | Gen | Dat | Acc | Loc | Voc ;
  Gender = Masc | Fem ;
  NounDecl = D0 | D1 | D2 | D3 | D4 | D5 | D6 | DR ;

  -- Adjectives
  Definite = Indef | Def ;
  AdjType  = AdjQual | AdjRel | AdjIndecl ;

  -- TODO: pārveidot uz šādu formu lai ir arī apstākļa vārdi kas atvasināti no īpašības vārdiem
  AForm = AAdj Degree Definite Gender Number Case | AAdv Degree ;

  -- Participles
  PartType = IsUsi | TsTa ; -- TODO: šo jāmet ārā - pārklājas ar Voice, kas attiecas ne tikai uz divdabjiem
  Voice = Act | Pass ;

  -- Verbs
  -- Ind  = Indicative
  -- Rel  = Relative (Latvian specific: http://www.isocat.org/rest/dc/3836)
  -- Deb  = Debitive (Latvian specific: http://www.isocat.org/rest/dc/3835)
  -- Condit = Conditional
  -- DebitiveRelative = the relative subtype of debitive
  VerbForm =
  	  Infinitive
  	| Indicative Person Number Tense
  	| Relative Tense
  	| Debitive
  	| Imperative Number
  	| DebitiveRelative
  	| Participle PartType Gender Number Case
  	;
    -- TODO: divdabim noteiktā forma un arī pārākā / vispārākā pakāpe

  VerbMood =
  	  Ind Anteriority Tense
  	| Rel Anteriority Tense		--# notpresent
  	| Deb Anteriority Tense		--# notpresent
  	| Condit Anteriority		--# notpresent
  	;

  VerbConj = C2 | C3 ;

  -- Verb agreement
  -- Number depends on the person
  -- Gender has to be taken into accunt because of predicative nominals and participles
  -- Polarity may depend on the subject/object NP (double negation, if subject/object has a negated determiner)
  Agr = AgP1 Number Gender | AgP2 Number Gender | AgP3 Number Gender Polarity ;

  -- Clause agreement
  -- TODO: jāpāriet uz vienotu TopicFocus (=> ieraksta tips)
  --ClAgr = Topic Case Voice | TopicFocus Case Case Agr Voice ;
  --ClAgr = NomAcc Agr Voice | DatNom Agr Voice | DatGen Agr Voice ;

  ThisOrThat = This | That ;
  CardOrd = NCard | NOrd ;
  DForm = unit | teen | ten ;

oper
  vowel : pattern Str = #("a"|"ā"|"e"|"ē"|"i"|"ī"|"o"|"u"|"ū") ;

  simpleCons : pattern Str = #("c"|"d"|"l"|"n"|"s"|"t"|"z") ;
  labialCons : pattern Str = #("b"|"m"|"p"|"v") ;
  sonantCons : pattern Str = #("l"|"m"|"n"|"r"|"ļ"|"ņ") ;
  doubleCons : pattern Str = #("ll"|"ln"|"nn"|"sl"|"sn"|"st"|"zl"|"zn") ;

  prefix : pattern Str = #("aiz"|"ap"|"at"|"ie"|"iz"|"no"|"pa"|"pār"|"pie"|"sa"|"uz") ;

  NON_EXISTENT : Str = "NON_EXISTENT" ;

  Verb : Type = { s : Polarity => VerbForm => Str } ;

  -- TODO: voice ir jāliek pa tiešo zem VP (?)
  ClAgr : Type = { c_topic : Case ; c_focus : Case ; agr : Agr ; voice : Voice } ;

  -- TODO: topic un focus jāapvieno vienā (jaunā) agr parametrā (?), jo
  --       ne vienmēr ir abi un ne visas kombinācijas ir vajadzīgas
  --       
  -- TODO: lai varētu spēlēties ar vārdu secību, compl vēlāk būs jāskalda pa daļām
  VP = { v : Verb ; compl : Agr => Str ; agr : ClAgr ; objNeg : Polarity } ;
  -- compl: objects, complements, adverbial modifiers
  -- topic: typically - subject
  -- focus: typically - objects, complements, adverbial modifiers

  VPSlash = VP ** { p : Prep } ; -- TODO: p pārklājas ar agr
  -- principā rekur ir objekts kuram jau kaut kas ir bet ir vēl viena brīva valence...

  Prep : Type = { s : Str ; c : Number => Case } ;
  -- In the case of case-based valences, the preposition is empty ([])
  -- TODO: position of prepositions (pre or post)

  --Valence : Type = { p : Prep ; c : Number => Case } ;
  -- e.g. 'ar' + Sg-Acc or Pl-Dat; Preposition may be skipped for simple case-baced valences

  toAgr : Person -> Number -> Gender -> Polarity -> Agr = \pers,num,gend,pol ->
    case pers of {
      P1 => AgP1 num gend ;
      P2 => AgP2 num gend ;
      P3 => AgP3 num gend pol
    } ;

  toClAgr : Case -> Case -> Agr -> Voice -> ClAgr = \c_topic,c_focus,agr,voice -> {
    c_topic = c_topic ;
    c_focus = c_focus ;
    agr = agr ;
    voice = voice
  } ;

  toClAgr_Reg : Case -> ClAgr = \c_topic -> toClAgr c_topic Nom (AgP3 Sg Masc Pos) Act ;

  fromAgr : Agr -> { pers : Person ; num : Number ; gend : Gender ; pol : Polarity } = \agr ->
    case agr of {
      AgP1 num gend     => { pers = P1 ; num = num ; gend = gend ; pol = Pos } ;
      AgP2 num gend     => { pers = P2 ; num = num ; gend = gend ; pol = Pos } ;
      AgP3 num gend pol => { pers = P3 ; num = num ; gend = gend ; pol = pol }
    } ;

  conjAgr : Agr -> Agr -> Agr = \agr1,agr2 ->
    let
      a1 = fromAgr agr1 ;
      a2 = fromAgr agr2
    in
      toAgr
        (conjPerson a1.pers a2.pers) -- FIXME: personu apvienošana ir tricky un ir jāuztaisa korekti
        (conjNumber a1.num a2.num)
        (conjGender a1.gend a2.gend)
        (conjPolarity a1.pol a2.pol) ;

  conjGender : Gender -> Gender -> Gender = \gend1,gend2 ->
    case gend1 of {
      Fem => gend2 ;
      _   => Masc
    } ;

  conjPolarity : Polarity -> Polarity -> Polarity = \pol1,pol2 ->
    case pol1 of {
      Neg => Neg ;
      _   => pol2
    } ;

  --agrP3 : Number -> Gender -> Polarity -> Agr = \num,gend,pol -> toAgr P3 num gend pol ;

}
