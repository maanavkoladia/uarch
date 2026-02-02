#define ICACHE_LINE_SIZE 16

void icache(int SPC,int valid_req, //CPU to ICache
            uint8_t cache_line[ICACHE_LINE_SIZE], bool valid_line, //ICache to CPU
            uint32_t mem_addr, bool mem_req, //ICache to mem
            uint32_t mem_data, bool mem_valid, //mem to ICache
            bool reset){

    
} 