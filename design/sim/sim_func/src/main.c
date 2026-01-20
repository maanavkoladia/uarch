/* ================================================== */
/*                      INCLUDES                      */
/* ================================================== */
#include <readline/chardefs.h>
#include <stdlib.h>
#include "LOG.h"
#include <stdbool.h>
#include "ForLoop.h"
#include "cpu_design/RISC_FETCH.h"
#include "sim_types.h"
#include "Assert_Common.h"
#include <readline/readline.h>
#include <string.h>
#include "cpu_design/RISC_FETCH.h"
#include "sim_helpers.h"

/* ================================================== */
/*                      DEFINES                       */
/* ================================================== */

/* ================================================== */
/*                    enums & types                   */
/* ================================================== */

/* ================================================== */
/*            GLOBAL VARIABLE DEFINITIONS             */
/* ================================================== */
const char* sim_prompt = "cmd_here_monkey > ";

//insteatiate all of the regs and cross stage wires and debug stuff
sim_state_t sim_state;

uint SIM_CYCLES;
sim_latches_t latches, new_latches;


/* ================================================== */
/*            FUNCTION PROTOTYPES (DECLARATIONS)      */
/* ================================================== */

/* ================================================== */
/*                 MACRO FUNC  DEFINITIONS            */
/* ================================================== */
#define CMD_CHK(cmdIn, cmdExp) if(strcmp((cmdIn), (cmdExp)) == 0)

/* ================================================== */
/*                 FUNCTION DEFINITIONS               */
/* ================================================== */

void help(void){ 
    //print usage
    printf("Not written Yet\n");
}

void PrintLatches(void){
    printf("Not written Yet\n");
}

bool ProgramDead_Check(void){
    //i think needs to check if rax == 60 and rdi for the return 
    //value, which we dint care about i think
    return false;
}

void cycle(void){
    //new latches onto old
    new_latches = latches;
    //run cycle per stage
    RISC_FETCH_Cycle();
    //old latches onto new 
    latches = new_latches;
    SIM_CYCLES++;
}

void run(uint cycles){
    FOR_LOOP_COMMON(i, cycles){
        cycle();
        if(ProgramDead_Check()){
            sim_state = SIM_DEAD;
            return;
        }
    }
    sim_state = SIM_HALTED;
    LOG("Ran %u cycles", cycles);
}

void go(void){
    ASSERT_COMMON(sim_state == SIM_HALTED, "Sim in invalid state");
    while(!ProgramDead_Check()){
        cycle();
    }
}

void Sim_Init(void){
    sim_state = SIM_HALTED;
    RISC_FETCH_Init();
}

void ServeCMD(char* pCMD){
    Tokenized_Cmd_t* pTokCmd = NULL;
    TokenizedCMD_Init(pCMD, &pTokCmd);
    ASSERT_COMMON_NOT_NULL(pTokCmd);

    if(pTokCmd->tokenCount == 0){
        return;
    }

    CMD_CHK(pTokCmd->tokens[0].tok, "q"){
        sim_state = SIM_DEAD;
        return;
    }

    CMD_CHK(pTokCmd->tokens[0].tok, "h"){
        help();
        return;
    }

    CMD_CHK(pTokCmd->tokens[0].tok, "go"){
        go();
        return;
    }


    CMD_CHK(pTokCmd->tokens[0].tok, "run"){
        run(strtol(pTokCmd->tokens[1].tok, NULL, 10));
        return;
    }

    CMD_CHK(pTokCmd->tokens[0].tok, "idump"){
        PrintLatches();
        return;
    }
    TokenizedCMD_Dtr(pTokCmd);
}

int main(int argc, char** argv){
    LOG("Starting Sim");
    Sim_Init();
    while(sim_state != SIM_DEAD){
        char* cmd = readline(sim_prompt);
        if(!cmd){
            continue;
        }
        ServeCMD(cmd);
        free(cmd);
    }

    LOG("Exiting Sim");
    return EXIT_SUCCESS;
}


