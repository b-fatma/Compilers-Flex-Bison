%{
    int nb_lignes = 1, nb_col = 1, nb_indent = 0; nb_indent_crt = 0;
    char save_type[25];
    char type[10];
    int qc = 0;
    int nT = 0;
    char tmp[30], tmp2[20];
    int i_and = 0, i_or = 0;
    int err = 0;
    int j, cond_for;
    int range = 0;
%}

%union{
    char * str;
    struct {char type[20]; char res[50];}NT;
}

%token eol mc_int mc_float mc_char mc_bool mc_if mc_else mc_for mc_in mc_range mc_while
    op_aff op_sup op_sup_eg op_eg op_diff op_inf_eg op_inf op_add op_sous op_mul op_div op_and op_or op_not
    po pf virg deux_points co cf cmnt indent dedent
%token<str> idf cst_char cst_bool
%token<str> signed_cst_int unsigned_cst_int
%token<str> signed_cst_float unsigned_cst_float

%start S

%left op_add op_sous
%left op_sup op_sup_eg op_eg op_diff op_inf_eg op_inf
%left op_mul op_div

%type <NT> EXP EXPA EXPB EXPC EXPE EXP_AND EXP_AND__ EXP_OR EXP_NOT EXP_COMP

%type <NT> CST

%%

/* remarques:
le compilateur ne gère pas: 
    - dedents multiples
    - generation des quadruplets dans le cas de blocs imbriqués
    - la declaration non typée pose problème puiceque elle a la même syntaxe que 
    l'instruction d'affectation, ça aurait été plus simple si le pgm n'était pas 
    divisé en déclarations/instructions.
    - manipulation des tableaux: remplissage, accès aux éléments */




S: DECLARATIONS                 {
                                    printf("\n\nProgramme syntaxiquement correct\n\n");
                                    YYACCEPT;
                                }
;

DECLARATIONS: DEC DECLARATIONS 
    |  INSTRUCTIONS  
;

INSTRUCTIONS: INST INSTRUCTIONS 
    |                            
; 

CMNT: indent CMNT dedent
    | cmnt eol
; 

DEC: LISTE_DEC
    | DEC_VAR
    | DEC_TAB
    | CMNT
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
                                    {
                                        printf("Erreur semantique: double declaration, ligne %d\n", nb_lignes-1);
                                        err = 1;
                                    }
                                    else
                                    { 
                                        inserer_type($1, save_type);
                                    }
                                }
    | idf   {
                if(double_declaration($1)) 
                {
                    printf("Erreur semantique: double declaration de %s, ligne %d\n", $1, nb_lignes-1);
                    err = 1;
                }
                else 
                {
                    printf("__declaration typee\n\n"); 
                    inserer_type($1, save_type);
                }
            }
;


DEC_VAR: idf op_aff CST eol {
                                if(double_declaration($1)) 
                                {
                                    printf("Erreur semantique: double declaration, ligne %d\n", nb_lignes-1);
                                    err = 1;
                                }
                                else 
                                {  
                                    printf("__declaration non typee\n\n"); 
                                    quadr("=", $3.res, "", $1);
                                    inserer_type($1, $3.type);
                                }
                            }
;


CST: cst_bool               {
                                strcpy($$.res, $1);
                                strcpy($$.type, "bool");
                            }
    | cst_char              {
                                strcpy($$.res, $1);
                                strcpy($$.type, "char");
                            }
    | unsigned_cst_float    {
                                strcpy($$.res, $1);
                                strcpy($$.type, "float");
                            }
    | po signed_cst_float pf    {
                                    strcpy($$.res, $2);
                                    strcpy($$.type, "float");
                                    inserer_type($2, "float");
                                }
    | unsigned_cst_int      {
                                strcpy($$.res, $1);
                                strcpy($$.type, "int");
                            }
    | po signed_cst_int pf  {
                                strcpy($$.res, $2);
                                strcpy($$.type, "int");
                                inserer_type($2, "int");
                            }
;

/*  declaration de tableau:
	accepte les constantes entières non signées seulement */
DEC_TAB: TYPE idf co unsigned_cst_int cf eol    {
                                                    if(atoi($4) == 0)
                                                    {
                                                        printf("Erreur semantique, ligne %d\n", nb_lignes-1);
                                                        err = 1;
                                                    }
                                                    else
                                                    {
                                                        printf("__declaration d'un tableau\n\n"); 
                                                        sprintf(tmp, "tableau de %s", save_type);
                                                        inserer_type($2, tmp);
                                                    }
                                                }
;

INST: INST_AFF  {printf("__fin_instruction: affectation\n\n"); }
    | INST_FOR  {printf("__fin_instruction: for\n\n"); }
    | INST_WHILE    {printf("__fin_instruction: while\n\n"); }
    | INST_IF   {printf("__fin_instruction: if\n\n"); }
    | CMNT
;


INST_AFF: idf op_aff EXP eol    {
                                    if(!double_declaration($1))
                                    {
                                        printf("Erreur semantique: idf %s non declare, ligne %d\n", $1, nb_lignes-1);
                                        err = 1;
                                    }
                                    else
                                    {
                                        type_element($1, type);
                                        if(strcmp(type, $3.type))
                                        {
                                            printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes-1);
                                            err = 1;
                                        }
                                        else
                                        {
                                            quadr("=", $3.res, "", $1);
                                        }
                                    }
                                }
;

BLOC : indent DECLARATIONS dedent
;


//INSTRUCTION IF
INST_IF: B PARTIE_ELSE  {
                            // routine 3
                            sprintf(tmp, "%d", qc);
                            // MAJ fin_if
                            ajour_quad(pop(), 1, tmp);
                        }
;

B: A BLOC   {
                // routine 2
                //généré même quand il n'y a pas de else
                quadr("BR", "","", "");
                sprintf(tmp, "%d", qc);
                ajour_quad(pop(), 1, tmp);
                // fin_if
                push(qc-1);
            }
;

A: mc_if po EXP pf deux_points eol  {
                                        // routine 1
                                        // deb_else 
                                        push(qc);
                                        quadr("BZ", "", "", $3.res);
                                    }
;

PARTIE_ELSE: mc_else deux_points eol BLOC
    |
;

//INSTRUCTION WHILE
INST_WHILE: C BLOC  {
                        // MAJ save_fin
                        sprintf(tmp, "%d", qc+1);
                        ajour_quad(pop(), 1, tmp);
                        // debut_while
                        sprintf(tmp, "%d", pop());
                        quadr("BR", tmp, "", "");
                    }
;

C: D EXP pf deux_points eol     {
                                    // save_fin
                                    push(qc);
                                    quadr("BZ", "", "", $2.res);
                                }
;

D: mc_while po  {
                    // debut_while
                    push(qc);
                }
; 

//INSTRUCTION FOR 
INST_FOR: mc_for EXP_FOR deux_points eol BLOC       {
                                                        if(range)
                                                        {
                                                            sprintf(tmp, "T%d", nT); nT++;
                                                            quadr("+", tmp2, "1", tmp);
                                                            quadr("=", tmp, "", tmp2);
                                                            cond_for = pop();
                                                            sprintf(tmp, "%d", cond_for);
                                                            quadr("BR", tmp, "", "");
                                                            sprintf(tmp, "%d", qc);
                                                            ajour_quad(cond_for, 1, tmp);
                                                        }
                                                    }
;

EXP_FOR: idf mc_in mc_range po unsigned_cst_int virg unsigned_cst_int pf    {
                                                                                range = 1;
                                                                                strcpy(tmp2, $1);
                                                                                quadr("=", $5, "", tmp2);
                                                                                push(qc);
                                                                                //cond_for = qc;
                                                                                quadr("BGE", "", tmp2, $7);
                                                                            }
    | idf mc_in idf //cas non traité
;



//EXPRESSIONS

//EXPRESSION LOGIQUE (moins prioritaire)
EXP: EXP_OR op_or EXP           {
                                    if(strcmp($1.type, $3.type))
                                    {
                                        printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                        err = 1;
                                    }
                                    else
                                    {
                                        strcpy($$.res, $1.res);
                                        strcpy($$.type, $1.type);
                                    }
                                }
        | EXP_OR op_or EXP_AND  {
                                    if(strcmp($1.type, $3.type))
                                    {
                                        printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                        err = 1;
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
                                            ajour_quad(pop(), 1, tmp);
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
                                    sprintf(tmp, "%d", qc+3);
                                    quadr("BZ", tmp, "", $1.res);
                                    quadr("=", "1", "", $$.res);
                                    push(qc); i_or++;
                                    quadr("BR", "", "", "");
                                    strcpy($$.type, $1.type);
                                }
;

EXP_AND: EXP_AND__ op_and EXP_AND  {
                                    if(strcmp($1.type, $3.type))
                                    {
                                        printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                        err = 1;
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
                                        err = 1;
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
                                            ajour_quad(pop(), 1, tmp);
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
                        sprintf(tmp, "%d", qc+3);
                        quadr("BNZ", tmp, "", $1.res);
                        quadr("=", "0", "", $$.res);
                        push(qc); i_and++;
                        quadr("BR", "", "", "");
                        strcpy($$.type, $1.type);
                    }
;

EXP_NOT: op_not EXP_NOT     {
                                sprintf(tmp, "T%d", nT); 
                                strcpy($$.res, tmp); nT++;
                                sprintf(tmp, "%d", qc+3);
                                quadr("BNZ", tmp, "", $2.res);
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
EXPE: po EXP pf         {
                            strcpy($$.res, $2.res);
                            strcpy($$.type, $2.type);
                        }
    
    | EXP_COMP              {
                                strcpy($$.res, $1.res);
                                strcpy($$.type, $1.type);
                            }
;

//EXPRESSION DE COMPARAISON
EXP_COMP: EXPA op_diff EXPA {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                    err = 1;
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
                                    err = 1;
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
                                    err = 1;
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
                                    err = 1;
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
                                    err = 1;
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
                                    err = 1;
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
    | EXPA                  {
                                strcpy($$.res, $1.res);
                                strcpy($$.type, $1.type);
                            }                                              
;


// EXPRESSION ARITHMETIQUE (plus prioritaire)
EXPA: EXPA op_add EXPB      {
                                if(strcmp($1.type, $3.type))
                                {
                                    printf("Erreur semantique: incompatibilite des types, ligne %d\n", nb_lignes);
                                    err = 1;
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
                                    err = 1;
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
                                    err = 1;
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
                                    err = 1;
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
                                { 
                                    printf("Erreur semantique: idf %s non declare, ligne %d\n", $1, nb_lignes);
                                    err = 1;
                                }
                                else
                                {
                                    strcpy($$.res, $1);
                                    type_element($1, type); strcpy($$.type, type);
                                }
                            }
    | CST                   {
                                if(!double_declaration($1.res))
                                { 
                                    printf("Erreur semantique: idf %s non declare, ligne %d\n", $1, nb_lignes);
                                    err = 1;
                                }
                                else
                                {
                                    strcpy($$.res, $1.res);
                                    strcpy($$.type, $1.type);
                                }
                            }
;

 
%%
main()
{
    init_stack();
    initialisation();
    yyparse();
    afficher();
    if(!err)
    {
        /* afficher les quadruplets s'il n'y a pas d'erreur sémantique */
        afficher_qdr();
    }
    free_stack();
}
yywrap(){}
int yyerror(char *msg)
{ 
    printf("Erreur syntaxique, ligne %d, colonne %d\n", nb_lignes, nb_col);
    return 1;  
}
