grammar ApplEdible;
tokens {STUDY_ID}
@parser::members {
String studyId;
public ApplParser(TokenStream input, String studyId) {
    this(input);
    this.studyId = studyId;
    }}
prog [String domVar]: suite? ;
suite: header? only_when? only_where? stmt+  tailer? ;
stmt : (simple_stmt | compound_stmt) '.'? ;
simple_stmt
    : (SET CDISC_DOMAIN_VARIABLE? ('to' | 'as' 'following:'?))? expr_rhs                                
    | (SET CDISC_DOMAIN_VARIABLE? ('to' | 'as' 'following:'?))? expr_rhs ','? IF condition_list
        ((','|'.')? ELSE (SET CDISC_DOMAIN_VARIABLE? ('to' | 'as' 'following:'?))? expr_rhs ','? IF condition_list)*
        ((','|'.')? ELSE (SET CDISC_DOMAIN_VARIABLE? ('to' | 'as' 'following:'?))? expr_rhs)?           
    | if_stmt                   
    | ('do'|'Do') 'nothing'     
    ;
only_when: ONLY WHEN CDISC_DOMAIN_VARIABLE comp_op val_string '.';
only_where: ONLY WHERE condition_list '.';
compound_stmt
    : (IF condition_list (THEN | ',') simple_stmt)+                         
    | SET 'to' extractor? picker ('in' order_op 'order')? (group_member_)+  
    ;
group_member_
    : '(' NUMBER ('.' NUMBER)?')' simple_stmt '.'? tailer?
    ;
if_stmt: IF condition_list ','? THEN? simple_stmt ((','|'.')? ELSE if_stmt)* ((','|'.')? ELSE simple_stmt)? ;
if_impute_stmt: IF condition_list ','? THEN? IMPUTE ( DATE_UNIT | TIME_UNIT )? WITH expr_imputation '.'?;
condition_list: condition (','? venn_op condition)* ;
condition
    : '(' condition_list ')'    
    | selective_test            
    | quantified_test           
    ;
selective_test
    : selective_test (venn_op comp_op expr_rhs)+ 
    | sel_expr comp_op expr_rhs                  
    | sel_expr comp_op partial_term              
    | sel_expr comp_op expr_rhs ('per' peror)+   
    | sel_expr ('per' peror)+ comp_op expr_rhs   
    | reflective_test                            
    ;
reflective_test
    : self_expr comp_op expr_rhs                 
    | self_expr comp_op partial_term             
    ;
quantified_test
    : ('there' BE)? 'at' 'most' NUMBER OBSERVATION? rear_selector       
    | ('there' BE)? 'at' 'least' NUMBER OBSERVATION? rear_selector      
    | 'all' OBSERVATION? 'of'? rear_selector                            
    | 'any' OBSERVATION? 'of'? rear_selector                            
    | 'there'? ('exists' | 'exist') rear_selector                       
    | front_selector 'any' CDISC_DOMAIN OBSERVATION?                    
    | front_selector 'all' CDISC_DOMAIN OBSERVATION?                    
    ;
rear_selector
    : ('from' | 'in')? CDISC_DOMAIN (WHERE selective_test)?             
    | selective_test                                                    
    ;
front_selector
    : selective_test 'for'      
    ;
peror
    : CDISC_DOMAIN_VARIABLE     
    | ('subject' | 'patient')   
    ;
self_expr
    : extractor    
    ;
expr_rhs
    : '(' expr_rhs ')'           
    | sel_expr      
    | prim_expr     
    | exprlist      
    | term          
    ;
expr_imputation
    : val_time      
    | val_number    
    | val_month     
    | val_date      
    | expr_rhs      
    ;
exprlist
    : prim_expr (',' prim_expr)*
    | '[' exprlist  ']'
    ;
prim_expr
    : prim_expr (calc_op prim_expr)+    
    | comp_op_uni prim_expr             
    | val_number                        
    | val_string                        
    | 'True'                            
    | 'False'                           
    ;
term: val_month                         
    | 'None'                            
    | 'NULL'                            
    | 'null'                            
    | 'blank'                           
    | 'empty'                           
    | 'missing'                         
    | 'nonmissing'                      
    | 'non-missing'                     
    | USER_DEFINED                      
    ;
partial_term
    : 'a'? 'complete' ('date'| 'dates')?                        
    | 'a'? 'partial'  ('date'| 'dates')?                        
    | 'a'? 'complete' ('datetime'| 'datetimes' | 'date time')?  
    | 'a'? 'partial'  ('datetime'| 'datetimes' | 'date time')?  
    ;
comp_op_uni
    : BE? 'not'             
    | 'does' 'not'          
    | 'do' 'not'            
    ;
comp_op
    : '='                   
    | '=='                  
    | BE ('equal' 'to')?    
    | BE? 'equal' 'to'      
    | 'equals' 'to'?        
    | 'Equals'              
    | '<'                   
    | '>'                   
    | '>='                  
    | '<='                  
    | BE? 'less' 'than' OP_OR 'equal' 'to'        
    | BE? 'greater' 'than' OP_OR 'equal' 'to'     
    | BE? 'equal' 'to' OP_OR 'greater' 'than'     
    | BE? 'less' 'than'                           
    | BE? 'greater' 'than'                        
    | '!='                                        
    | BE 'not'                                    
    | BE? 'not' 'equal' 'to'?                     
    | 'not' 'equals' 'to'?                        
    | 'ne'                                        
    | BE 'after'                                  
    | BE 'before'                                 
    | OP_CONTAINS                                 
    | OP_STARTS_WITH                              
    | OP_HAS ('values'| 'value')? 'of'?           
    | BE? 'in'                                    
    | BE? 'not' 'in'                              
    ;
venn_op
    : OP_AND                        
    | OP_OR                         
    ;
agger
    : 'the'? 'number' 'of' 'unique'    
    | 'the'? 'number' 'of'             
    | 'the'? 'total' 'number' 'of'     
    | 'the'? 'total' 'count' 'of'      
    | 'the'? 'largest'                 
    | 'the'? 'maximum'                 
    | 'the'? 'minimum'                 
    | 'the'? 'first' 'difference' 'of' 
    ;
picker
    : picker picker                    
    | 'the'? 'first' 'of'?             
    | 'the'? 'last' 'of'?              
    | 'the'? 'most' 'recent'           
    | 'the'? 'latest' 'of'?            
    | 'the'? 'earliest' 'of'?          
    | 'the'? 'earlier' 'of'?           
    ;
order_op
    : ('asc'  | 'ascending')          
    | ('dsc'  | 'decending')          
    ;
calc_op
    : '+'                            
    | '-'                            
    | ('–' | 'minus')                
    | '*'                            
    | '/'                            
    ;
sel_expr
    : '(' sel_expr ')'                    
    | sel_expr ((','|OP_AND) sel_expr)+   
    | sel_expr transformer                
    | sel_expr WHERE condition_list       
    | picker sel_expr (ORDER_BY selection ('in' order_op 'order')?)?                 
    | picker sel_expr 'when'? 'sorted' 'in' ('date/time' | 'chronological') 'order'  
    | extractor sel_expr         
    | agger sel_expr             
    | selection                  
    | SUPP_DOMAIN_VARIABLE WHERE SUPP_DOMAIN_VARIABLE (BE | '=') val_string 
    | sel_expr calc_op sel_expr  
    | sel_expr calc_op expr_rhs  
    ;
selection
    : CDISC_DOMAIN_VARIABLE         
    ;
extractor
    : 'the'? ('date'|'Date') 'part'? 'of'?       
    | 'the'? 'datepart' 'of'?                    
    | 'the'? 'datetime' 'of'?                    
    | 'the'? 'day' 'part'? 'of'?                 
    | 'the'? 'month' 'part'? 'of'?               
    | 'the'? 'time' 'part'? 'of'?                
    | 'the'? ('hour' 'part'|'hours') 'of'?       
    | 'the'? ('minute' 'part'|'minutes') 'of'?   
    | 'the'? ('second' 'part'|'seconds') 'of'?   
    | 'the'? 'cycle' 'number'? 'of'?             
    | 'the'? 'cycle' 'day' 'of'?                 
    | 'the'? 'integer' 'part' 'of'               
    | 'the' 'part' 'after' STRING+ ('in'|'of')   
    | 'the' 'part' 'before' STRING+ ('in'|'of')  
    ;
transformer
    : converter                                  
    | 'upcase'                                   
    | 'uppercase'                                
    ;
converter
    : 'converted' 'to' 'numeric' 'date'          
    | 'converted' 'to' 'numeric' 'datetime'      
    | 'converted' 'to' 'character'               
    ;
val_string: ('the'? ('text' | 'texts'))? STRING+;
val_date: DATE;
val_time: TIME;
val_number: NUMBER ;
val_month
    : 'June'    
    ;
header
    : 'Option' ('('? .*? ')'?)? ':'              
    ;
tailer
    : 'Missing' 'Data' 'Handling' 'Rule'    (ONLY WHERE reflective_test)? ':' ('-'? tailer_item)+ 
    | ('Imputation' | 'Imputation' 'rules') (ONLY WHERE reflective_test)? ':' ('-'? tailer_item)+ 
    ;
tailer_item
    : (ONLY WHERE condition_list)? if_impute_stmt '.'?
    ;
OP_CONTAINS : 'contains';
OP_STARTS_WITH: 'starts with';
OP_HAS : 'has';
OP_AND : 'and' | 'And' ;
OP_OR : 'or' | 'Or' ;
DATE_UNIT: 'day' | 'month';
TIME_UNIT: TIME_HOUR_UNIT | TIME_MINUTE_UNIT | TIME_SECOND_UNIT ;
fragment TIME_HOUR_UNIT: 'hour' | 'hours';
fragment TIME_MINUTE_UNIT: 'minute' | 'minutes';
fragment TIME_SECOND_UNIT: 'second' | 'seconds';
SUPP_DOMAIN_VARIABLE : 'S' 'U' 'P' 'P' CDISC_DOMAIN '.' CDISC_VARIABLE_START CDISC_VARIABLE_START CDISC_VARIABLE_CONTINUE+ ;
CDISC_DOMAIN_VARIABLE : '['? (CDISC_DOMAIN '.')? CDISC_VARIABLE_START CDISC_VARIABLE_START CDISC_VARIABLE_CONTINUE+ ']'?;
CDISC_DOMAIN : CDISC_DOMAIN_LETTER CDISC_DOMAIN_LETTER
                (CDISC_DOMAIN_LETTER
                 (CDISC_DOMAIN_LETTER
                  (CDISC_DOMAIN_LETTER
                   (CDISC_DOMAIN_LETTER)?)?)?)?;
fragment CDISC_DOMAIN_ITEM : CDISC_DOMAIN_ITEM_LETTER CDISC_DOMAIN_ITEM_LETTER
                    (CDISC_DOMAIN_ITEM_LETTER
                     (CDISC_DOMAIN_ITEM_LETTER
                      (CDISC_DOMAIN_ITEM_LETTER
                       (CDISC_DOMAIN_ITEM_LETTER)?)?)?)?;
STRING : '\'' ~[\\\r\n\f']* '\'' | '"'~[\\\r\n\f"]* '"' ;
fragment INTEGER : NON_ZERO_DIGIT DIGIT* ;
fragment FLOAT_NUMBER : POINT_FLOAT | EXPONENT_FLOAT ;
NUMBER : INTEGER | FLOAT_NUMBER | NUMBER_ONE | NUMBER_ZERO;
fragment NUMBER_ONE : 'one' | 'One';
fragment NUMBER_ZERO: [0] | 'zero' ;
TIME : DIGIT DIGIT ':' DIGIT DIGIT (':' DIGIT DIGIT)? ;
DATE : [012] DIGIT ;
WHITESPACE : (' ' | '\t')+ -> skip ;
NEWLINE : ('\r'? '\n' | '\r')+ -> skip ;
COMMENT_BLOCK : '/*' .*? '*/' -> skip ;
COMMENT_LINE : ('
COMMENT_PARTIAL : '#' ~[\r\n\f#]* '#'? -> skip ;
STUDY_SPECIFIC : ('Study specific' | 'study specific') '.'? -> skip;
USER_DEFINED : 'user' 'defined' | 'User' 'defined' | 'user-defined' ;
MISC : 'Please' -> skip ;
SEMICOLON : ';' -> skip ;
IF : 'if' | 'If' | 'In case' 'of'?;
THEN : 'then' | 'Then' ;
ELSE : 'else' | 'Else' | 'otherwise' | 'Otherwise';
SET : 'set' | 'Set' ;
IMPUTE: 'impute' | 'Impute' ;
BE: 'is' | 'are' ;
TO : 'to' | 'To' ;
AS : 'as' | 'As' ;
WITH : 'with' ;
WHERE : 'where' | 'Where' ;
OBSERVATION : 'observation' | 'observations' | 'record' | 'records' ;
ONLY : 'Only' | 'only' ;
WHEN : 'when' | 'When' ;
ORDER_BY: 'order by' | 'sorted by' ;
NAME : ID_START ID_CONTINUE* ;
fragment CDISC_DOMAIN_LETTER
 : [\p{Lu}] ; 
fragment CDISC_DOMAIN_ITEM_LETTER
 : [\p{Ll}] ; 
fragment CDISC_VARIABLE_START
 : [A-Z] ;
fragment CDISC_VARIABLE_CONTINUE
 : [\p{Letter}] 
 | DIGIT
 ;
fragment NON_ZERO_DIGIT
 : [1-9]
 ;
fragment DIGIT
 : [0-9]
 ;
fragment POINT_FLOAT
 : INT_PART? FRACTION
 ;
fragment INT_PART
 : DIGIT+
 ;
fragment FRACTION
 : '.' DIGIT+
 ;
fragment EXPONENT_FLOAT
 : ( INT_PART | POINT_FLOAT ) EXPONENT
 ;
fragment EXPONENT
 : [eE^] [+-]? DIGIT+
 ;
fragment ID_START
 : [\p{Lu}]     
 | [\p{N}]      
;
fragment ID_CONTINUE
 : ID_START
 | [\p{Mn}] 	
 | [\p{Mc}]     
 | [\p{Nd}]     
 | [\p{Pc}]     
 ;
