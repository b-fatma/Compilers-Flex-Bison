%{
    int nb_lignes = 1, nb_col = 1, nb_indent = 0; nb_indent_crt = 0;
    char save_type[25];
%}

%union{
    char * str;
    int entier;
    float reel;
}

%token eol mc_int mc_float mc_char mc_bool mc_if mc_else mc_for mc_in mc_range mc_while
    op_aff op_sup op_sup_eg op_eg op_diff op_inf_eg op_inf op_add op_sous op_mul op_div op_and op_or op_not
    po pf virg deux_points co cf cst_char cst_bool cmnt indent dedent
%token<str> idf
%token<str> signed_cst_int unsigned_cst_int
%token<str> signed_cst_float unsigned_cst_float
%start S
%left op_add op_sous
%left op_sup op_sup_eg op_eg op_diff op_inf_eg op_inf
%left op_mul op_div

%%
S: DECLARATIONS INSTRUCTIONS    {
                                    printf("Programme syntaxiquement correct\n");
                                    YYACCEPT;
                                }

DECLARATIONS: DEC DECLARATIONS
    | CMNT DECLARATIONS
    | 
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
TYPE: mc_int    {
                    strcpy(save_type, "int");
                }
    | mc_float  {
                    strcpy(save_type, "float");
                }
    | mc_char   {
                    strcpy(save_type, "char");
                }
    | mc_bool   {
                    strcpy(save_type, "bool");
                }
;
LISTE_IDF: idf virg LISTE_IDF   {
                                    if(double_declaration($1))
                                        printf("Erreur semantique: double declaration de %s, ligne %d\n", $1, nb_lignes-1);
                                    else 
                                        inserer_type($1, save_type);
                                }
    | idf   {
                if(double_declaration($1)) 
                    printf("Erreur semantique: double declaration de %s, ligne %d\n", $1, nb_lignes-1);
                else 
                    inserer_type($1, save_type);
            }
;

DEC_VAR: idf op_aff CST eol {
                                if(double_declaration($1)) 
                                    printf("Erreur semantique: double declaration de %s, ligne %d\n", $1, nb_lignes-1);
                                else 
                                    inserer_type($1, save_type);
                            }
;
CST: cst_bool               {
                                strcpy(save_type, "bool");
                            }
    | cst_char              {
                                strcpy(save_type, "char");
                            }
    | unsigned_cst_float    {
                                strcpy(save_type, "float");
                            }
    | po signed_cst_float pf    {
                                    strcpy(save_type, "float");
                                    inserer_type($2, "float");
                                }
    | unsigned_cst_int      {
                                strcpy(save_type, "int");
                            }
    | po signed_cst_int pf  {
                                strcpy(save_type, "int");
                                inserer_type($2, "int");
                            }
;

DEC_TAB: TYPE idf co unsigned_cst_int cf eol    {
                                                    char tmp[30];
                                                    sprintf(tmp, "tableau de %s", save_type);
                                                    inserer_type($2, tmp);
                                                }
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

INST_AFF: idf op_aff EXP eol    {
                                    if(!double_declaration($1))
                                    {
                                        printf("Erreur semantique: idf %s non declare, ligne %d\n", $1, nb_lignes-1);
                                    }
                                }
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
    | idf   {
                if(!double_declaration($1)) 
                    printf("Erreur semantique: idf %s non declare, ligne %d\n", $1, nb_lignes);
            }
    | CST
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