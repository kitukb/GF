--# -path=.:../chunk:../finnish/stemmed:../finnish:../api

concrete TranslateFin of Translate = 
  TenseX,
  CatFin,
  NounFin - [
    PPartNP
    ,UsePron, PossPron  -- Fin specific: replaced by variants with prodrop
    ],
  AdjectiveFin,
  NumeralFin,
  SymbolFin [
    PN, Symb, String, CN, Card, NP, MkSymb, SymbPN, CNNumNP
    ],
  ConjunctionFin,
  VerbFin -  [
    UseCopula,  
    PassV2  -- generalized in Extensions
    ],
  AdverbFin,
  PhraseFin,
  SentenceFin,
  QuestionFin,
  RelativeFin,
  IdiomFin,
  ConstructionFin,
  DocumentationFin,

  ChunkFin,
  ExtensionsFin [CompoundCN,AdAdV,UttAdV,ApposNP,MkVPI, MkVPS, PredVPS, PassVPSlash, PassAgentVPSlash],

  DictionaryFin ** 

open MorphoFin, ResFin, ParadigmsFin, SyntaxFin, StemFin, (E = ExtraFin), (G = GrammarFin), Prelude in {

flags literal=Symb ; coding = utf8 ;

-- the overrides -----
lin

 UsePron p = G.UsePron p | G.UsePron (E.ProDrop p) ;
 PossPron p = G.PossPron p | E.ProDropPoss p ;
}

