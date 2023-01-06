%{
    int nb_lignes = 1, nb_col = 1, nb_indent = 0; nb_indent_crt = 0;
    char save_type[25];
    char type[10];
    int qc = 0;
    int nT = 0;
    char tmp[30], tmp2[20];
    int save_fin_and[20];
    int save_fin_or[20];
    int save_deb_else[20];
    int save_fin_if[20];
    int i_and = 0, i_else = 0, i_if = 0;
    int i_or = 0;
    int j, deb_else, fin_if, deb_while, cond_for;
%}

%union{
    char * str;
    int entier;
    float reel;
    struct {char type[20]; char res[50];}NT;
}

%token eol mc_int mc_float mc_char mc_bool mc_if mc_else mc_for mc_in mc_range mc_while
    op_aff op_sup op_sup_eg op_eg op_diff op_inf_eg op_inf op_add op_sous op_mul op_div op_and op_or op_not
    po pf virg deux_points co cf cst_bool cmnt indent dedent
%token<str> idf cst_char
%token<str> signed_cst_int unsigned_cst_int
%token<str> signed_cst_float unsigned_cst_float

%start S

%left op_add op_sous
%left op_sup op_sup_eg op_eg op_diff op_inf_eg op_inf
%left op_mul op_div

%type <NT> EXP EXPA EXPB EXPC EXPE EXP_LOG EXP_AND EXP_AND__ EXP_OR EXP_NOT CONDITION

%type <str> CST

%%
S: DECLARATIONS INSTRUCTIONS    {
                                    printf("Programme syntaxiquement correct\n");
                                    YYACCEPT;
                                }

DECLARATIONS: DEC DECLARATIONS {printf("\n____________declaration____________\n");}
    | CMNT DECLARATIONS
    |  INSTRUCTIONS
;

INSTRUCTIONS: INST INSTRUCTIONS {printf("\n____________instruction____________\n");}
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
                                        printf("Erreur semantique: double declaration, ligne %d\n", nb_lignes-1);
                                    else
                                    { 
                                        inserer_type($1, save_type);
                                    }
                                }
    | idf   {
                if(double_declaration($1)) 
                    printf("Erreur semantique: double declaration de %s, ligne %d\n", $1, nb_lignes-1);
                else 
                {
                    inserer_type($1, save_type);
                }
            }
;

DEC_VAR: idf op_aff CST eol {
                                if(double_declaration($1)) 
                                {
                                    printf("Erreur semantique: double declaration, ligne %d\n", nb_lignes-1);
                                }
                                else 
                                {   
                                    quadr("=", $3, "", $1);
                                    inserer_type($1, save_type);
                                }
                            }
;

CST: cst_bool               {
                                // strcpy($$, $1);
                                strcpy(save_type, "bool");
                            }
    | cst_char              {
                                strcpy($$, strdup($1));
                                strcpy(save_type, "char");
                            }
    | unsigned_cst_float    {
                                strcpy($$, strdup($1));
                                strcpy(save_type, "float");
                            }
    | po signed_cst_float pf    {
                                    strcpy($$, strdup($2));
                                    strcpy(save_type, "float");
                                    inserer_type($2, "float");
                                }
    | unsigned_cst_int      {
                                strcpy($$, strdup($1));
                                strcpy(save_type, "int");
                            }
    | po signed_cst_int pf  {
                                strcpy($$, strdup($2));
                                strcpy(save_type, "int");
                                inserer_type($2, "int");
                            }
;

DEC_TAB: TYPE idf co unsigned_cst_int cf eol    {
                                                    sprintf(tmp, "tableau de %s", save_type);
                                                    inserer_type($2, tmp);
                                                }
;

INST: INST_AFF
    | INST_FOR
    | INST_WHILE
    | INST_IF
;


INST_AFF: idf op_aff EXPA eol   {
                                    if(!double_declaration($1))
                                    {
                                        printf("Erreur semantique: idf %s non declare, ligne %d\n", $1, nb_lignes-1);
                                    }
                                    else
                                    {
                                        type_element($1, type);
                                        if(strcmp(type, $3.type))
                                        {
                                            printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes-1);
                                        }
                                        else
                                        {
                                            quadr("=", $3.res, "", $1);
                                        }
                                    }
                                }
;

BLOC : indent DECLARATIONS INSTRUCTIONS dedent
;


//INSTRUCTION IF
INST_IF: B PARTIE_ELSE  {
                            // printf("routine 3\n");
                            sprintf(tmp, "%d", qc);
                            ajour_quad(fin_if, 1, tmp);
                        }
;

B: A BLOC   {
                // printf("routine 2\n");
                fin_if = qc;
                quadr("BR", "","", ""); //généré quand il y a un else aussi (solve it)
                sprintf(tmp, "%d", qc);
                ajour_quad(deb_else, 1, tmp);
            }
;

A: mc_if po CONDITION pf deux_points eol    {
                                                // printf("routine 1\n");
                                                deb_else = qc;
                                                quadr("BZ", "", "", $3.res);
                                            }
;

PARTIE_ELSE: mc_else deux_points eol BLOC
    |
;

//INSTRUCTION WHILE
INST_WHILE: C BLOC  {
                        sprintf(tmp, "%d", deb_while);
                        quadr("BR", tmp, "", "");
                        sprintf(tmp, "%d", qc);
                        ajour_quad(deb_while, 1, tmp);
                    }
;

C: mc_while po CONDITION pf deux_points eol {
                                                deb_while = qc;
                                                quadr("BZ", "", "", $3.res);
                                            }
;

//INSTRUCTION FOR 
INST_FOR: mc_for EXP_FOR deux_points eol BLOC {
                                                            sprintf(tmp, "T%d", nT); nT++;
                                                            quadr("+", tmp2, "1", tmp);
                                                            quadr("=", tmp, "", tmp2);
                                                            sprintf(tmp, "%d", cond_for);
                                                            quadr("BR", tmp, "", "");
                                                            sprintf(tmp, "%d", qc);
                                                            ajour_quad(cond_for, 1, tmp);
                                                        }
;

EXP_FOR: idf mc_in mc_range po unsigned_cst_int virg unsigned_cst_int pf  {
                                                                    strcpy(tmp2, $1);
                                                                    quadr("=", $5, "", tmp2);
                                                                    cond_for = qc;
                                                                    quadr("BGE", "", tmp2, $7);
                                                                }
    | idf mc_in idf
;



//EXPRESSIONS
CONDITION: EXP
        | EXP_LOG
;
//EXPRESSION DE COMPARAISON
EXP: EXPA op_diff EXPA      {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    sprintf(tmp, "%d", qc+3);
                                    quadr("BE", tmp, $1.res, $3.res);
                                    quadr("=", "0", "", $$.res);
                                    sprintf(tmp, "%d", qc+2);
                                    quadr("BR", tmp, "", "");
                                    quadr("=", "1", "", $$.res);                                   
                                    strcpy($$.type, $1.type);
                                }
                            }
    | EXPA op_eg EXPA       {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    sprintf(tmp, "%d", qc+3);
                                    quadr("BNE", tmp, $1.res, $3.res);
                                    quadr("=", "0", "", $$.res);
                                    sprintf(tmp, "%d", qc+2);
                                    quadr("BR", tmp, "", "");
                                    quadr("=", "1", "", $$.res);                                   
                                    strcpy($$.type, $1.type);
                                }
                            }
    | EXPA op_inf EXPA      {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    sprintf(tmp, "%d", qc+3);
                                    quadr("BL", tmp, $1.res, $3.res);
                                    quadr("=", "0", "", $$.res);
                                    sprintf(tmp, "%d", qc+2);
                                    quadr("BR", tmp, "", "");
                                    quadr("=", "1", "", $$.res);                                   
                                    strcpy($$.type, $1.type);
                                }
                            }
    | EXPA op_inf_eg EXPA   {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    sprintf(tmp, "%d", qc+3);
                                    quadr("BLE", tmp, $1.res, $3.res);
                                    quadr("=", "0", "", $$.res);
                                    sprintf(tmp, "%d", qc+2);
                                    quadr("BR", tmp, "", "");
                                    quadr("=", "1", "", $$.res);                                   
                                    strcpy($$.type, $1.type);
                                }
                            }
    | EXPA op_sup EXPA      {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    sprintf(tmp, "%d", qc+3);
                                    quadr("BG", tmp, $1.res, $3.res);
                                    quadr("=", "0", "", $$.res);
                                    sprintf(tmp, "%d", qc+2);
                                    quadr("BR", tmp, "", "");
                                    quadr("=", "1", "", $$.res);                                   
                                    strcpy($$.type, $1.type);
                                }
                            }
    | EXPA op_sup_eg EXPA   {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    sprintf(tmp, "%d", qc+3);
                                    quadr("BGE", tmp, $1.res, $3.res);
                                    quadr("=", "0", "", $$.res);
                                    sprintf(tmp, "%d", qc+2);
                                    quadr("BR", tmp, "", "");
                                    quadr("=", "1", "", $$.res);                                   
                                    strcpy($$.type, $1.type);
                                }
                            }                                              
;


// EXPRESSION ARITHMETIQUE 
EXPA: EXPA op_add EXPB      {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    quadr("+", $1.res, $3.res, $$.res);
                                    strcpy($$.type, $1.type);
                                }
                            }
    | EXPA op_sous EXPB     {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    quadr("-", $1.res, $3.res, $$.res);
                                    strcpy($$.type, $1.type);
                                }
                            }
    | EXPB                  {
                                strcpy($$.res, $1.res);
                                strcpy($$.type, $1.type);
                            }
;


EXPB: EXPB op_mul EXPC      {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    quadr("*", $1.res, $3.res, $$.res);
                                    strcpy($$.type, $1.type);
                                }
                            }
    | EXPB op_div EXPC      {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                }
                                else
                                {
                                    sprintf(tmp, "T%d", nT); nT++;
                                    strcpy($$.res, tmp);
                                    quadr("/", $1.res, $3.res, $$.res);
                                    strcpy($$.type, $1.type);
                                }
                            }
    |EXPC                   {
                                strcpy($$.res, $1.res);
                                strcpy($$.type, $1.type);
                            }
;

EXPC: po EXPA pf            {
                                strcpy($$.res, $2.res);
                                strcpy($$.type, $2.type);
                            }
    | idf                   {
                                if(!double_declaration($1)) 
                                    printf("Erreur semantique: idf %s non declare, ligne %d\n", $1, nb_lignes);
                                else
                                {
                                    strcpy($$.res, $1);
                                    type_element($1, type); strcpy($$.type, type);
                                }
                            }
    | CST                   {
                                if(!double_declaration($1)) 
                                    printf("Erreur semantique: idf %s non declare, ligne %d\n", $1, nb_lignes);
                                else
                                {
                                    strcpy($$.res, $1);
                                    type_element($1, type); strcpy($$.type, type);
                                }
                            }
;


//EXPRESSION LOGIQUE yet to do
EXP_LOG: EXP_OR op_or EXP_LOG   {
                                    printf("boucle\n");
                                    if(strcmp($1.type, $3.type))
                                    {
                                        printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                    }
                                    else
                                    {
                                        strcpy($$.res, $1.res);
                                        strcpy($$.type, $1.type);
                                    }
                                }
        | EXP_OR op_or EXP_AND  {
                                    printf("fin\n");
                                    printf("%s, %s\n", $1.type, $3.type);
                                    if(strcmp($1.type, $3.type))
                                    {
                                        printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                    }
                                    else
                                    {
                                        sprintf(tmp, "T%d", nT); 
                                        strcpy($$.res, tmp);
                                        sprintf(tmp, "%d", qc+3);
                                        quadr("BNZ", tmp, "", $3.res);
                                        quadr("=", "0", "", $$.res);
                                        sprintf(tmp, "%d", qc+2);
                                        quadr("BR", tmp, "", "");
                                        sprintf(tmp, "%d", qc);
                                        for(j = 0; j < i_or; j++)
                                            ajour_quad(save_fin_or[j], 1, tmp);
                                        quadr("=", "1", "", $$.res);
                                        strcpy($$.type, $1.type);
                                        nT++; i_or=0;
                                    }
                                }
        | EXP_AND               {
                                    strcpy($$.res, $1.res);
                                    strcpy($$.type, $1.type);
                                }
;
EXP_OR: EXP_AND                 {
                                    sprintf(tmp, "T%d", nT); 
                                    strcpy($$.res, tmp);
                                    //jump au and suivant si l'exp est vraie
                                    sprintf(tmp, "%d", qc+3);
                                    quadr("BZ", tmp, "", $1.res);
                                    //and faux => toute l'expression est fausse
                                    quadr("=", "1", "", $$.res);
                                    save_fin_or[i_or] = qc; i_or++;
                                    quadr("BR", "", "", "");
                                    strcpy($$.type, $1.type);
                                }
;

EXP_AND: EXP_AND__ op_and EXP_AND  {
                                    if(strcmp($1.type, $3.type))
                                    {
                                        printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                    }
                                    else
                                    {
                                        strcpy($$.res, $1.res);
                                        strcpy($$.type, $1.type);
                                    }
                                }
    | EXP_AND__ op_and EXP_NOT  {
                                    if(strcmp($1.type, $3.type))
                                    {
                                        printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                    }
                                    else
                                    {
                                        sprintf(tmp, "T%d", nT); 
                                        strcpy($$.res, tmp);
                                        sprintf(tmp, "%d", qc+3);
                                        quadr("BZ", tmp, "", $3.res);
                                        quadr("=", "1", "", $$.res);
                                        sprintf(tmp, "%d", qc+2);
                                        quadr("BR", tmp, "", "");
                                        sprintf(tmp, "%d", qc);
                                        for(j = 0; j < i_and; j++)
                                            ajour_quad(save_fin_and[j], 1, tmp);
                                        quadr("=", "0", "", $$.res);
                                        strcpy($$.type, $1.type);
                                        nT++; i_and=0;
                                    }
                                }
    | EXP_NOT               {
                                strcpy($$.res, $1.res);
                                strcpy($$.type, $1.type);
                            }
;

EXP_AND__: EXP_NOT  {  
                        sprintf(tmp, "T%d", nT); 
                        strcpy($$.res, tmp);
                        //jump au and suivant si l'exp est vraie
                        sprintf(tmp, "%d", qc+3);
                        quadr("BNZ", tmp, "", $1.res);
                        //and faux => toute l'expression est fausse
                        quadr("=", "0", "", $$.res);
                        save_fin_and[i_and] = qc; i_and++;
                        quadr("BR", "", "", "");
                        strcpy($$.type, $1.type);
                    }
;

EXP_NOT: op_not EXP_NOT     {
                                sprintf(tmp, "T%d", nT); 
                                strcpy($$.res, tmp); nT++;
                                //jump au and suivant si l'exp est vraie
                                sprintf(tmp, "%d", qc+3);
                                quadr("BNZ", tmp, "", $2.res);
                                //and faux => toute l'expression est fausse
                                quadr("=", "1", "", $$.res);
                                sprintf(tmp, "%d", qc+2);
                                quadr("BR", tmp, "", "");
                                quadr("=", "0", "", $$.res);
                                strcpy($$.type, $2.type);
                            }
    | EXPE                  {
                                strcpy($$.res, $1.res);
                                strcpy($$.type, $1.type);
                            }
;
EXPE: po EXP_LOG pf         {
                                strcpy($$.res, $2.res);
                                strcpy($$.type, $2.type);
                            }
    
    | EXP                  {
                                strcpy($$.res, $1.res);
                                strcpy($$.type, $1.type);
                            }
;
 

%%
main()
{
    initialisation();
    yyparse();
    afficher();
    afficher_qdr();
}
yywrap(){}
int yyerror(char *msg)
{ 
    printf("Erreur syntaxique, ligne %d, colonne %d\n", nb_lignes, nb_col);
    return 1;  
}