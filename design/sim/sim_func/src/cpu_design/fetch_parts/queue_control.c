#include <stdlib.h>
#include "Fetch.h"
#include <stdint.h>
#include <stdbool.h>

void queue_control(uint8_t cache_line[16], bool valid_line, //ICache to Control
                   uint8_t slots_open, uint8_t* tail_ptr, //Control to Queue
                   uint32_t head_ptr, uint8_t* queue_mem[32],
                   uint32_t br_locations, bool pend_br, 
                   bool reset){
    
    /*if slots open is greater than 16 than we should add the next cache line if it is valid
    For branches
     - On our current branch if we see that the EIP and br location are the same then we need to reset the queue
        then add the next cache line into the queue if it is valid if the cahce line is not ready then we should not change the queue.
        Probably means I need to send a reset to the head pointer to predecode. 
        - How does this work combinationally?
          - So if EIP + instruction length matches a branch location and there is a pending branch then
             - reset pending branch flag
             - tell predecode to reset head pointer 
             - place in new cache lines
        
    
    */

}