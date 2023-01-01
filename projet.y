%{
 int nb_lignes = 1, nb_col = 1, nb_indent = 0;
%}
%token eol mc_int mc_float mc_char mc_bool mc_if mc_else mc_for mc_in mc_range mc_while
    op_aff op_sup op_sup_eg op_eg op_diff op_inf_eg op_inf op_add op_sous op_mul op_div op_and op_or op_not
    po pf virg deux_points co cf cst_char cst_float signed_cst_int unsigned_cst_int cst_bool cmnt idf indent dedent
%start S
%left op_add op_sous
%left op_sup op_sup_eg op_eg op_diff op_inf_eg op_inf
%left op_mul op_div

%%
S: DECLARATIONS INSTRUCTIONS{printf("Programme syntaxiquement correct\n");YYACCEPT;}

DECLARATIONS: DEC DECLARATIONS
    | CMNT DECLARATIONS
    | INSTRUCTIONS
;

INSTRUCTIONS: INST INSTRUCTIONS
    | CMNT INSTRUCTIONS
    |
;

CMNT: indent CMNT dedent
    | cmnt eol
; 

DEC: LISTE_DEC
    | DEC_VAR
    | DEC_TAB
;

LISTE_DEC: TYPE LISTE_IDF eol 
;
TYPE: mc_int
    | mc_float 
    | mc_char 
    | mc_bool
;
LISTE_IDF: idf virg LISTE_IDF
    | idf
;

DEC_VAR: idf op_aff CST eol
;
CST: cst_bool
    | cst_char
    | cst_float
    | CSTI
;

DEC_TAB: TYPE idf co unsigned_cst_int cf eol
;

INST: INST_AFF
    | INST_FOR
    | INST_WHILE
    | INST_IF
;

OP_ARITH: op_add
    | op_div
    | op_mul
    | op_sous
;

OP_COMP: op_diff
    | op_eg
    | op_inf
    | op_inf_eg
    | op_sup
    | op_sup_eg
;

OP_LOG: op_and
    | op_or
;

INST_AFF: idf op_aff EXP eol
;

INST_IF: mc_if po EXP pf deux_points eol indent INSTRUCTIONS dedent PARTIE_ELSE 
;

PARTIE_ELSE: mc_else deux_points eol indent INSTRUCTIONS dedent
    |
;

INST_WHILE: mc_while po EXP pf deux_points eol indent INSTRUCTIONS dedent
;

INST_FOR: mc_for idf mc_in EXP_FOR deux_points eol indent INSTRUCTIONS dedent
;

EXP_FOR: mc_range po unsigned_cst_int virg unsigned_cst_int pf
    | idf
;

EXP: EXP OP_COMP EXPA
    | EXPA
;

EXPA: EXPA OP_ARITH EXPB
    | EXPB
;

EXPB: EXPB OP_LOG EXPC
    | EXPC
;

EXPC: op_not EXPC 
    | EXPD
;
EXPD: po EXP pf
    | idf
    | CST
;

CSTI: signed_cst_int
    | unsigned_cst_int
;  

%%
main()
{
    initialisation();
    yyparse();
    afficher();
}
yywrap(){}
int yyerror(char *msg)
{ 
    printf("Erreur syntaxique, ligne %d, colonne %d\n", nb_lignes, nb_col);
    return 1;  
}