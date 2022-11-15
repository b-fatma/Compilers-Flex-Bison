%{
	#include "projet.tab.h"
	#include "TS.h"
	#include <stdio.h>
	extern nb_lignes;
	extern nb_col;
%}
lettre_maj [A-Z]
lettre_min [a-z]
chiffre [0-9]
idf {lettre_maj}({lettre_min}|{chiffre})*
cmnt #.*
cst_char '({lettre_maj}|{lettre_min})'
unsigned_cst_int (0|[1-9][0-9]*)
signed_cst_int \([+-](0|[1-9][0-9]*)\)
cst_float (0|[1-9][0-9]*)\.[0-9]*|\(([+-](0|[1-9][0-9]*)\.[0-9]*)\)
cst ([1-9]{chiffre}*|0)
cst_bool (true|false)
indent ("    "|\t)
%%
"int" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_int;}
"float" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_float;}
"char" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_char;}
"bool" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_bool;}
"if" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_if;}
"else" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_else;}
"for" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_for;}
"in" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_in;}
"range" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_range;}
"while" {rechercher(yytext, "Mot cle", 0, 0, 1); nb_col += yyleng; return mc_while;}
"=" {rechercher(yytext, "op aff", 0, 0, 2); nb_col += yyleng; return op_aff;}
">" {rechercher(yytext, "op sup", 0, 0, 2); nb_col += yyleng; return op_sup;}
">=" {rechercher(yytext, "op sup ou eg", 0, 0, 2); nb_col += yyleng; return op_sup_eg;}
"==" {rechercher(yytext, "op eg", 0, 0, 2); nb_col += yyleng; return op_eg;}
"!=" {rechercher(yytext, "op diff", 0, 0, 2);nb_col += yyleng; return op_diff;}
"<=" {rechercher(yytext, "op inf ou eg", 0, 0, 2); nb_col += yyleng; return op_inf_eg;}
"<" {rechercher(yytext, "op inf", 0, 0, 2); nb_col += yyleng; return op_inf;}
"+" {rechercher(yytext, "op add", 0, 0, 2); nb_col += yyleng; return op_add;}
"-" {rechercher(yytext, "op sous", 0, 0, 2); nb_col += yyleng; return op_sous;}
"*" {rechercher(yytext, "op mult", 0, 0, 2); nb_col += yyleng; return op_mul;}
"/" {rechercher(yytext, "op div", 0, 0, 2); nb_col += yyleng; return op_div;}
"and" {rechercher(yytext, "op and", 0, 0, 2); nb_col += yyleng; return op_and;}
"or" {rechercher(yytext, "op or", 0, 0, 2); nb_col += yyleng; return op_or;}
"not" {rechercher(yytext, "op not", 0, 0, 2); nb_col += yyleng; return op_not;}
"(" {rechercher(yytext, "par ouv", 0, 0, 2); nb_col += yyleng; return po;}
")" {rechercher(yytext, "par ferm", 0, 0, 2); nb_col += yyleng; return pf;}
"," {rechercher(yytext, "virg", 0, 0, 2); nb_col += yyleng; return virg;}
":" {rechercher(yytext, "deux points", 0, 0, 2); nb_col += yyleng; return deux_points;}
"[" {rechercher(yytext, "croch ouv", 0, 0, 2); nb_col += yyleng; return co;}
"]" {rechercher(yytext, "croch ferm", 0, 0, 2); nb_col += yyleng; return cf;}
"\." {rechercher(yytext, "point", 0, 0, 2); nb_col += yyleng; return point;}
{cst_char} {nb_col += yyleng; return cst_char;}
{cst_float} {nb_col += yyleng; return cst_float;}
{signed_cst_int} {nb_col += yyleng; return signed_cst_int;}
{unsigned_cst_int} {nb_col += yyleng; return unsigned_cst_int;}
{cst_bool} {nb_col += yyleng; return cst_bool;}
{cmnt} {nb_col += yyleng; return cmnt;}
{idf} {nb_col += yyleng; if(yyleng>8){printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext);}
                         else{return idf;}}
{indent} {nb_col += yyleng; return indent;}
[ ] nb_col += yyleng;
\n {nb_lignes++; nb_col = 1; return eol;}
. {printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext); nb_col += yyleng;}
