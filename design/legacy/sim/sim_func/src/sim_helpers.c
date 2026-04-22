#include "sim_helpers.h"
#include "Assert_Common.h"
#include "ForLoop.h"
#include "LOG.h"
#include "common.h"

#include <stdlib.h>
#include <string.h>

static const char* cmd_delims = " \t\r\n";

static int InsertToken(const char* pTokStart, size_t tokenLen, Tokenized_Cmd_t* pTCmd) {
    ASSERT_COMMON_NOT_NULL(pTokStart);
    ASSERT_COMMON_NOT_NULL(pTCmd);
    ASSERT_COMMON(tokenLen > 0 && tokenLen <= MAX_CMD_LEN, "invalid token length");

    // grow token list if needed
    if (pTCmd->tokenCount == pTCmd->capacity) {
        size_t newCapacity = pTCmd->capacity * TOKENIZER_MULTIPLIER;
        ASSERT_COMMON(newCapacity > pTCmd->capacity, "token capacity did not grow");

        cmd_token_t* resized = realloc(pTCmd->tokens, newCapacity * sizeof(cmd_token_t));
        ASSERT_COMMON_ALLOC(resized);

        pTCmd->tokens = resized;
        pTCmd->capacity = newCapacity;
    }

    // allocate and copy token
    char* tokenBuf = (char*)malloc(tokenLen + 1);
    ASSERT_COMMON_ALLOC(tokenBuf);

    memcpy(tokenBuf, pTokStart, tokenLen);
    tokenBuf[tokenLen] = '\0';

    pTCmd->tokens[pTCmd->tokenCount++].tok = tokenBuf;
    return EXIT_SUCCESS;
}

int TokenizedCMD_Init(char* cmdIn, Tokenized_Cmd_t** pTCmd_Out) {
    ASSERT_COMMON_NOT_NULL(cmdIn);
    ASSERT_COMMON_NOT_NULL(pTCmd_Out);

    Tokenized_Cmd_t* pTCmd = malloc(sizeof(Tokenized_Cmd_t));
    ASSERT_COMMON_ALLOC(pTCmd);

    pTCmd->capacity = MAX_STARTING_TOKENS;
    pTCmd->tokenCount = 0;
    pTCmd->tokens = malloc(pTCmd->capacity * sizeof(cmd_token_t));
    ASSERT_COMMON_ALLOC(pTCmd->tokens);

    // tokenize in-place
    char* currToken = strtok(cmdIn, cmd_delims);
    while (currToken != NULL) {
        ASSERT_COMMON_POSIX(InsertToken(currToken, strlen(currToken), pTCmd),
                            "failed to insert token");
        currToken = strtok(NULL, cmd_delims);
    }

    *pTCmd_Out = pTCmd;
    return EXIT_SUCCESS;
}

int TokenizedCMD_Dtr(Tokenized_Cmd_t* pTokCmd) {
    ASSERT_COMMON_NOT_NULL(pTokCmd);
    ASSERT_COMMON_NOT_NULL(pTokCmd->tokens);
    ASSERT_COMMON(pTokCmd->capacity > 0, "invalid tokenizer state");

    FOR_LOOP_COMMON(i, pTokCmd->tokenCount) {
        free(pTokCmd->tokens[i].tok);
    }

    free(pTokCmd->tokens);
    free(pTokCmd);
    return EXIT_SUCCESS;
}

