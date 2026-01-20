#pragma once

#include <stdint.h>
#include <stdlib.h>
#include "sim_common.h"

#define MAX_CMD_LEN (1 << 11)

// setting 2048 to max num, this is sa guess bc 1 cahr token, 1 space so 1 << 12 / 2
#define MAX_STARTING_TOKENS (1 << 10)

#define TOKENIZER_MULTIPLIER (1.5)

typedef struct {
    char* tok;
} cmd_token_t;

typedef struct {
    size_t capacity;
    size_t tokenCount;
    cmd_token_t* tokens;
} Tokenized_Cmd_t;



int TokenizedCMD_Init(char* cmdIn, Tokenized_Cmd_t** pTCmd_Out);

int TokenizedCMD_Dtr(Tokenized_Cmd_t* pTokCmd);
