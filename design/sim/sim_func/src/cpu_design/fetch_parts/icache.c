#include <stdlib.h>
#include "Fetch.h"
#include <stdint.h>
#include <stdbool.h>

#define ICACHE_LINE_SIZE 16
#define ICACHE_LINES 32



void icache(int SPC,int valid_req, //CPU to ICache
            uint8_t* cache_line[ICACHE_LINE_SIZE], bool* valid_line, //ICache to CPU
            uint32_t* mem_addr, bool* mem_req, //ICache to mem
            uint32_t mem_data, bool mem_valid, //mem to ICache
            bool reset){
    
    static uint8_t cache[ICACHE_LINES][ICACHE_LINE_SIZE];
    static bool valid[ICACHE_LINES];
    static uint32_t tags[ICACHE_LINES];
    static bool filling_flag;
    static uint8_t fill_index;
    static int beat_count;
    
    if(reset){
        for(int i = 0; i < ICACHE_LINES; i++){
            valid[i] = false;
        }
        return;
    }

    //CPU to Icache interface 
    int offset = SPC & 0xF;
    int index = (SPC >> 4) & 0x1F;
    int tag = SPC >> 9;
    if(valid_req){
        if(valid[index] && tags[index] == tag){
            //Cache hit
            for(int i = 0; i < ICACHE_LINE_SIZE; i++){
                (*cache_line)[i] = cache[index][i];
            }
            *valid_line = true;
        } else {
            //Cache miss
            *mem_addr = SPC;
            *mem_req = true;
            *valid_line = false;
            filling_flag = true;
            fill_index = index;
            beat_count = 0;
        }
    } else {
        *valid_line = false;
    }

    //Mem to Icache interface (updating cache line)
    if(mem_valid && filling_flag){
        cache[fill_index][3 - beat_count] = (mem_data >> (beat_count * 8)) & 0xFF;
        if(beat_count == 3){
            valid[fill_index] = true;
            tags[fill_index] = SPC >> 9;
            filling_flag = false;
        } else {
            beat_count++;
        }
    }
} 
