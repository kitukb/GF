{-# OPTIONS -fno-warn-incomplete-patterns #-}
module GF.Canon.GFCC.PrintGFCC where

-- pretty-printer generated by the BNF converter

import GF.Canon.GFCC.AbsGFCC
import Char

-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t ---- . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Int where
  prt _ x = doc (shows x)


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)



instance Print CId where
  prt _ (CId i) = doc (showString i)
  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])



instance Print Grammar where
  prt i e = case e of
   Grm header abstract concretes -> prPrec i 0 (concatD [prt 0 header , doc (showString ";") , prt 0 abstract , doc (showString ";") , prt 0 concretes])


instance Print Header where
  prt i e = case e of
   Hdr cid cids -> prPrec i 0 (concatD [doc (showString "grammar ") , prt 0 cid , doc (showString "(") , prt 0 cids , doc (showString ")")])


instance Print Abstract where
  prt i e = case e of
   Abs absdefs -> prPrec i 0 (concatD [doc (showString "abstract ") , doc (showString "{") , prt 0 absdefs , doc (showString "}")])


instance Print Concrete where
  prt i e = case e of
   Cnc cid cncdefs -> prPrec i 0 (concatD [doc (showString "concrete ") , prt 0 cid , doc (showString "{") , prt 0 cncdefs , doc (showString "}")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print AbsDef where
  prt i e = case e of
   Fun cid type' exp -> prPrec i 0 (concatD [prt 0 cid , doc (showString ":") , prt 0 type' , doc (showString "=") , prt 0 exp])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print CncDef where
  prt i e = case e of
   Lin cid term -> prPrec i 0 (concatD [prt 0 cid , doc (showString "=") , prt 0 term])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print Type where
  prt i e = case e of
   Typ cids cid -> prPrec i 0 (concatD [prt 0 cids , doc (showString "->") , prt 0 cid])


instance Print Exp where
  prt i e = case e of
   Tr atom exps -> prPrec i 0 (concatD [doc (showString "(") , prt 0 atom , prt 0 exps , doc (showString ")")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print Atom where
  prt i e = case e of
   AC cid -> prPrec i 0 (concatD [prt 0 cid])
   AS str -> prPrec i 0 (concatD [prt 0 str])
   AI n -> prPrec i 0 (concatD [prt 0 n])
   AF d -> prPrec i 0 (concatD [prt 0 d])
   AM  -> prPrec i 0 (concatD [doc (showString "?")])


instance Print Term where
  prt i e = case e of
   R terms -> prPrec i 0 (concatD [doc (showString "[") , prt 0 terms , doc (showString "]")])
   P term0 term -> prPrec i 0 (concatD [doc (showString "(") , prt 0 term0 , doc (showString "!") , prt 0 term , doc (showString ")")])
   S terms -> prPrec i 0 (concatD [doc (showString "(") , prt 0 terms , doc (showString ")")])
   KS str -> prPrec i 0 (concatD [prt 0 str])
   KP strs variants -> prPrec i 0 (concatD [doc (showString "[") , doc (showString "pre") , prt 0 strs , doc (showString "[") , prt 0 variants , doc (showString "]") , doc (showString "]")])
   V n -> prPrec i 0 (concatD [doc (showString "$") , prt 0 n])
   C n -> prPrec i 0 (concatD [prt 0 n])
   F cid -> prPrec i 0 (concatD [prt 0 cid])
   FV terms -> prPrec i 0 (concatD [doc (showString "[|") , prt 0 terms , doc (showString "|]")])
   W str term -> prPrec i 0 (concatD [doc (showString "(") , prt 0 str , doc (showString "+") , prt 0 term , doc (showString ")")])
   RP term0 term -> prPrec i 0 (concatD [doc (showString "(") , prt 0 term0 , doc (showString "@") , prt 0 term , doc (showString ")")])
   TM  -> prPrec i 0 (concatD [doc (showString "?")])
   L cid term -> prPrec i 0 (concatD [doc (showString "(") , prt 0 cid , doc (showString "->") , prt 0 term , doc (showString ")")])
   BV cid -> prPrec i 0 (concatD [doc (showString "#") , prt 0 cid])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])


instance Print Variant where
  prt i e = case e of
   Var strs0 strs -> prPrec i 0 (concatD [prt 0 strs0 , doc (showString "/") , prt 0 strs])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])


