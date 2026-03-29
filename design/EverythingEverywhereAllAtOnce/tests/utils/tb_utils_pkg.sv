package test_utils_pkg;

    // LOWER (layer 0)
    `define ICACHE_PRINT_LINE_LOWER(ROW) \
        $display("Lower Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
            ROW, \
            /*u_icache.icache_TagStore_unit.validStore[\ROW]*/ \
            u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.mem[\ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.mem[\ROW] \
        );

    // UPPER (layer 1)
    `define ICACHE_PRINT_LINE_UPPER(ROW) \
        $display("Upper Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
            ROW, \
            u_icache.icache_TagStore_unit.tag_store_ramCell_Upper.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.mem[ROW], \
            u_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.mem[ROW] \
        );

    task automatic display_icache_contents();

        $display("==== ICache Contents ====");
        $display("Valid Bits:");
        for(int i = 0; i < 16; i++ ) $display("IDX: %d, V: %d", i,u_icache.icache_TagStore_unit.tag_store_ramCell_Lower.mem[i]);
        $display("==========================================================");
            

        // Lower (0–7)
        `ICACHE_PRINT_LINE_LOWER(0)
        `ICACHE_PRINT_LINE_LOWER(1)
        `ICACHE_PRINT_LINE_LOWER(2)
        `ICACHE_PRINT_LINE_LOWER(3)
        `ICACHE_PRINT_LINE_LOWER(4)
        `ICACHE_PRINT_LINE_LOWER(5)
        `ICACHE_PRINT_LINE_LOWER(6)
        `ICACHE_PRINT_LINE_LOWER(7)

        // Upper (0–7)
        `ICACHE_PRINT_LINE_UPPER(0)
        `ICACHE_PRINT_LINE_UPPER(1)
        `ICACHE_PRINT_LINE_UPPER(2)
        `ICACHE_PRINT_LINE_UPPER(3)
        `ICACHE_PRINT_LINE_UPPER(4)
        `ICACHE_PRINT_LINE_UPPER(5)
        `ICACHE_PRINT_LINE_UPPER(6)
        `ICACHE_PRINT_LINE_UPPER(7)

    endtask

endpackage
