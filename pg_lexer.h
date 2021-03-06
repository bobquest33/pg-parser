typedef void * Pg__Parser__Lexer__Token;
typedef void * Pg__Parser__Lexer;

extern void init_lexer(void);

/* Lexer instances */
extern Pg__Parser__Lexer create_lexer(const char *);
extern void destroy_lexer(Pg__Parser__Lexer);
extern void set_lexer_ignore_whitespace(Pg__Parser__Lexer, bool);
extern Pg__Parser__Lexer__Token next_lexer_token(Pg__Parser__Lexer);

/* Token stuff */
extern const char *token_type(Pg__Parser__Lexer__Token);
extern const char *token_src(Pg__Parser__Lexer__Token);
extern bool token_is_operator(Pg__Parser__Lexer__Token);
extern int token_offset(Pg__Parser__Lexer__Token);
extern int token_line(Pg__Parser__Lexer__Token);
extern int token_column(Pg__Parser__Lexer__Token);
extern void destroy_token(Pg__Parser__Lexer__Token);