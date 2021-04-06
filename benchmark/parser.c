#define  _POSIX_C_SOURCE 200809L
#include <stdbool.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>    // strcmp, strdup
#include <ctype.h>     // isblank
#include "parser.h"

struct parser_state {
        void * callback_ctx;
        variables_callback_t vcallback;  
        monomial_callback_t mcallback; 
        polynomial_callback_t pcallback;
        finalization_callback_t fcallback;
        bool read_variables;

        // buffer
        FILE *istream;
        char *buffer;
        int capacity;     // buffer capacity
        int lo;           // next available byte in buffer
        int hi;           // last available byte in buffer
        int lineno;
        int col;
        bool eof;
        char current;     // current byte

	// variables
        struct var_list *vars_head, *vars_tail;
        int nvars;
};

struct var_list {
        char *name;
        struct var_list *next;
};

static void advance(struct parser_state * s)
{
        if (s->lo == s->hi)  {
                s->lo = 0;
                s->hi = fread(s->buffer, 1, s->capacity, s->istream);
                if (s->hi == 0) {
                        if (ferror(s->istream))
                                err(1, "error while reading input");
                        if (feof(s->istream)) {
                                s->eof = true;
                                return;
                        }
                }
        }
        if (s->current == '\n') {
                s->col = 0;
                s->lineno += 1;
        } else {
                s->col += 1;
        }
        s->current = s->buffer[s->lo];
        s->lo += 1;
        if (isblank(s->current))
                advance(s);
}

static int find_variable(struct parser_state *s, char *name)
{
        int i = 0;
        struct var_list * head = s->vars_head->next;
        while (head != NULL) {
                if (strcmp(name, head->name) == 0)
                        return i;
                i += 1;
                head = head->next;
        }
        return -1;
}

static bool read_variable(struct parser_state *s, char *buffer)
{
        int i = 0;
        while (true) {
                char c = s->current;
                if (s->eof || c == '+' || c == ',' || c == '*' || c == '\n')
                        break;
                if (i == 128) {
                        buffer[128] = '\0';
                        errx(1, "variable name %s too long on line %d, column %d\n", buffer, s->lineno, s->col);
                }
                buffer[i] = c;
                i++;
                advance(s);
        }
        buffer[i] = '\0';
        return (i != 0);
}

static void read_variables(struct parser_state *s)
{
        char name[129];
        int n = 0;
        while (read_variable(s, name)) {
                struct var_list *new = malloc(sizeof(*new));
                if (find_variable(s, name) >= 0)
                        errx(1, "duplicate variable name %s\n", name);
                new->name = strdup(name);
                new->next = NULL;
                s->vars_tail->next = new;
                s->vars_tail = new;
                n += 1;
                if (s->current == ',')
                        advance(s);
        }
        if (s->current != '\n')
                errx(1, "parse error line %d col %d: expected newline, got %c\n", s->lineno, s->col, s->current);
        advance(s);     // skip newline
        char ** allvars = malloc(n * sizeof(*allvars));
        // TODO : error checking
        struct var_list * v = s->vars_head;
        for (int i = 0; i < n; i++) {
                v = v->next;
                allvars[i] = v->name;
        }
        if (s->vcallback != NULL)
                (*s->vcallback)(s->callback_ctx, n, (const char **) allvars);
        free(allvars);
        s->nvars = n;
        s->read_variables = true;
}

static bool read_term(struct parser_state *s)
{
        char buffer[129];
        int variables[s->nvars];
        int degree = 0;
        bool something = false;
        bool forget = false;
        while (read_variable(s, buffer)) {
                something = true;
                if (s->current == '*')
                        advance(s);
                if (strcmp(buffer, "1") == 0)
                        continue;
                if (strcmp(buffer, "0") == 0) {
                        forget = true;
                        continue;
                }
                int x = find_variable(s, buffer);
                if (x < 0)
                        errx(1, "unknown variable %s on line %d col %d\n", buffer, s->lineno, s->col);
                variables[degree] = x;
                degree += 1;
        }
        if (forget)
                return true;
        if (!something)
                return false;
        if (s->mcallback != NULL)
                (*s->mcallback)(s->callback_ctx, s->lineno, s->col, degree, variables);
        return true;
}

static void read_poly(struct parser_state *s)
{
        while (read_term(s)) {
                if (s->current == '+')
                        advance(s);
        }
        if (!s->eof && s->current != '\n')
                errx(1, "parser error : unexpected stuff (%c) on line %d, col %d\n", s->current, s->lineno, s->col);
        advance(s);         // skip \n
        if (s->pcallback != NULL)
                (*s->pcallback)(s->callback_ctx, s->lineno);
}

static void parser_setup(struct parser_state *s)
{
        s->capacity = 1000000;
        s->buffer = malloc(s->capacity);
        if (s->buffer == NULL)
                err(1, "cannot allocate buffer");
        s->lo = 0;
        s->hi = 0;
        s->lineno = -1;
        s->col = 0;
        s->eof = false;
        s->current = '\n';
        struct var_list * dummy = malloc(sizeof(*dummy));
        dummy->name = NULL;
        s->vars_head = dummy;
        s->vars_tail = dummy;
        advance(s);	
}

static void parser_finish(struct parser_state *s)
{
	free(s->buffer);
        if (s->fcallback != NULL)
                (*s->fcallback)(s->callback_ctx);
        struct var_list *head = s->vars_head;
        while (head != NULL) {
                struct var_list *next = head->next;
                free(head->name);
                free(head);
                head = next;
        }
}

void parser(FILE * istream, void * callback_ctx, variables_callback_t v, 
                monomial_callback_t m, polynomial_callback_t p, finalization_callback_t f)
{
        struct parser_state s;
        s.istream = istream;
        s.callback_ctx = callback_ctx;
        s.vcallback = v;
        s.mcallback = m;
        s.pcallback = p;
        s.fcallback = f;
        s.read_variables = false;
        parser_setup(&s);

        while (true) {
                if (s.eof)
                        break;
                if (s.current == '#') {
                        while (!s.eof && s.current != '\n')
                                advance(&s);
                        advance(&s);       // skip the \n

                } else if (!s.read_variables) {
                        read_variables(&s);
                } else {
                        read_poly(&s);
                }
        }
        parser_finish(&s);
}