grammar Toml;

@lexer::members {
    boolean in_value = false;
}

toml : NL* pair* object+;
object: HEADER NL+ pair* NL*;

HEADER: { !in_value }? '[' ~[\]]+ ']';

value: STRING | NUMBER | ISO8601 | array | BOOLEAN;

ISO8601 : YEAR '-' MONTH '-' DAY 'T' HOUR ':' MINUTE ':' SECOND ZULU;
fragment ZULU : [zZ] ;
fragment YEAR: DIGIT DIGIT DIGIT DIGIT;
fragment MONTH: DIGIT DIGIT ;
fragment DAY : DIGIT DIGIT ;
fragment HOUR : DIGIT DIGIT ;
fragment MINUTE : DIGIT DIGIT ;
fragment SECOND : DIGIT DIGIT ;

pair: ID ASSIGN value NL+;

ASSIGN: '=' { in_value = true; };

// TODO if i remove namechar, lots of test documents fail. why?
ID:  { !in_value }? NameChar ~[ \t=]*;

array: '[' NL* value ( NL* ',' NL* value)* NL* ','?  NL* ']'
    | '[' NL* ']'
    ;

NL : '\r'? '\n' { in_value = false; };
STRING: '"' (ESC | ~["\\])* '"' ;
BOOLEAN: 'true' | 'false';

fragment DIGIT: [0-9] ;
fragment ESC: '\\' (["\\/0bfnrt] | UNICODE);
fragment UNICODE: 'u' HEX HEX HEX HEX;
fragment HEX: [0-9a-fA-F];

fragment INT: '0' | [1-9] [0-9]*;
fragment EXP: [Ee] [+\-]? INT ; // \- since - means "range" inside [...]
NUMBER:  '-'? INT '.' INT EXP? // 1.35, 1.35E-9, 0.3, -4.5
       | '-'? INT EXP          // 1e10 -3e4
       | '-'? INT              // -3, 45
;

fragment NameChar: NameStartChar
   | '0'..'9'
   | '_'
   | '\u00B7'
   | '\u0300'..'\u036F'
   | '\u203F'..'\u2040'
   ;
fragment NameStartChar: 'A'..'Z' | 'a'..'z'
   | '\u00C0'..'\u00D6'
   | '\u00D8'..'\u00F6'
   | '\u00F8'..'\u02FF'
   | '\u0370'..'\u037D'
   | '\u037F'..'\u1FFF'
   | '\u200C'..'\u200D'
   | '\u2070'..'\u218F'
   | '\u2C00'..'\u2FEF'
   | '\u3001'..'\uD7FF'
   | '\uF900'..'\uFDCF'
   | '\uFDF0'..'\uFFFD'
   ;

// Skip whitespace and comments
WS: [ \t]+ -> skip;
COMMENT: '#' ~[\r\n]* -> skip;