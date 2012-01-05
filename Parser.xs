#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <postgres.h>
#include <parser/parser.h>

#include "parser_nodes.h"
#include "node_types.h"
#include "lexer.h"

static void init() {
    MemoryContextInit();
}

static const char *DEFAULT_NODE_TYPE = "Node";

static SV *parse_node_to_sv(Node *node) {
    SV *sv = newSV(0);
    const char *type = NodeTypes[nodeTag(node)];
    if (type == NULL) {
        type = DEFAULT_NODE_TYPE;
    }
    
    sv_setref_pv(sv, Perl_form("Pg::Parser::Pg::%s", type), node);
    return sv;
}

static SV *parse(const char *src) {
    AV          *parsed_statements;
    List        *raw_parsetree_list;
    ListCell    *parsetree_item;

    raw_parsetree_list = raw_parser(src);

    parsed_statements = newAV();
    
    if (raw_parsetree_list == NULL) {
        return &PL_sv_undef;
    }
    
	foreach(parsetree_item, raw_parsetree_list) {
        Node *parsetree = (Node *) lfirst(parsetree_item);
        
        av_push(parsed_statements, parse_node_to_sv(parsetree));
    }
    
    return newRV((SV *) parsed_statements);
}

static SV *pg_list_to_av(List *list) {
    AV          *perl_list;
    ListCell    *item;
    
    if (list == NULL) {
        return &PL_sv_undef;
    }

    perl_list = newAV();
    
	foreach(item, list) {
        Node *node = (Node *) lfirst(item);
        
        av_push(perl_list, parse_node_to_sv(node));
    }
    
    return newRV((SV *) perl_list);    
}

MODULE = Pg::Parser     PACKAGE = Pg::Parser::Lexer

Pg::Parser::Lexer
lex(pkg,src)
    SV *pkg;
    const char *src;
    CODE:
        RETVAL = create_lexer(src);
    OUTPUT:
        RETVAL

int
next_token(self)
    Pg::Parser::Lexer self;
    CODE:
        RETVAL = next_lexer_token(self);
    OUTPUT:
        RETVAL
        
void
DESTROY(self)
    Pg::Parser::Lexer self;
    CODE:
        destroy_lexer(self);

INCLUDE: ParserNodes.xsh
        
MODULE = Pg::Parser     PACKAGE = Pg::Parser

SV *
parse(pkg,src)
    const char *pkg;
    const char *src; 
    CODE:
        RETVAL = parse(src);
    OUTPUT:
        RETVAL
        
BOOT:
    init();    
    